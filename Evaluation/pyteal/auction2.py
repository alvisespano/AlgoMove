import pyteal as pt
from pyteal import (
    Seq,
    Assert,
    Txn,
    Global,
    TxnField,
    TxnType,
    InnerTxnBuilder,
    Int,
    If,
)
import beaker


# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------

class Expired:
    FALSE = Int(1)
    TRUE = Int(2)


# -----------------------------------------------------------------------------
# Application State
# -----------------------------------------------------------------------------

class AuctionState:
    # Address of the auctioneer (one auction per auctioneer)
    auctioneer = beaker.LocalStateValue(
        stack_type=pt.TealType.bytes,
        static=True,
        descr="Auctioneer address",
    )

    # Asset being auctioned:
    # 0  -> Algos
    # >0 -> ASA ID
    asset_id = beaker.LocalStateValue(
        stack_type=pt.TealType.uint64,
        descr="0 for Algos, otherwise ASA ID",
    )

    # Auction status flag
    expired = beaker.LocalStateValue(
        stack_type=pt.TealType.uint64,
        descr="Flag indicating whether the auction has ended",
    )

    # Highest bid amount so far
    highest_bid = beaker.LocalStateValue(
        stack_type=pt.TealType.uint64,
        descr="Current highest bid",
    )

    # Address of the current highest bidder
    highest_bidder = beaker.LocalStateValue(
        stack_type=pt.TealType.bytes,
        descr="Current highest bidder",
    )

    # Bid amount associated with each bidder
    bid = beaker.LocalStateValue(
        stack_type=pt.TealType.uint64,
        descr="Bid amount for each bidder",
    )


app = beaker.Application("Auction", state=AuctionState())


# -----------------------------------------------------------------------------
# Start auction
# -----------------------------------------------------------------------------

@app.external
def start_auction(
    starting_bid_: pt.abi.Transaction,
    asset_id: pt.abi.Uint64,
):
    """
    Starts a new auction for the sender (auctioneer).

    asset_id = 0  -> Algos auction
    asset_id > 0  -> ASA auction
    """
    return Seq(
        # Register auctioneer
        app.state.auctioneer[Txn.sender()].set(Txn.sender()),

        # Register asset being auctioned
        app.state.asset_id[Txn.sender()].set(asset_id.get()),

        # Initialize highest bid
        app.state.highest_bid[Txn.sender()].set(starting_bid_.get().amount()),

        # Auction starts as active
        app.state.expired[Txn.sender()].set(Expired.FALSE),
    )


# -----------------------------------------------------------------------------
# Place a bid
# -----------------------------------------------------------------------------

@app.external(
    method_config=pt.MethodConfig(
        opt_in=pt.CallConfig.CALL,
        no_op=pt.CallConfig.CALL,
    )
)
def bid(
    auctioneer: pt.abi.Address,
    deposit: pt.abi.Transaction,
):
    """
    Places a bid on an active auction.

    The bid payment can be either:
    - Algos (Payment transaction) if asset_id == 0
    - ASA (AssetTransfer transaction) otherwise

    On a successful overbid, the previous highest bidder
    is refunded atomically via an inner transaction.
    """

    asset = app.state.asset_id[auctioneer.get()]
    prev_bidder = app.state.highest_bidder[auctioneer.get()]
    prev_bid = app.state.bid[prev_bidder]

    return Seq(
        # Auction must still be active
        Assert(
            app.state.expired[auctioneer.get()] == Expired.FALSE,
            comment="Auction is not active",
        ),

        # ------------------------------------------------------------------
        # Payment / Asset type checks
        # ------------------------------------------------------------------
        If(asset == Int(0))
        .Then(
            # Algo bid
            Assert(
                deposit.get().type_enum() == TxnType.Payment,
                comment="Expected Algo payment",
            )
        )
        .Else(
            # ASA bid
            Seq(
                Assert(
                    deposit.get().type_enum() == TxnType.AssetTransfer,
                    comment="Expected ASA transfer",
                ),
                Assert(
                    deposit.get().xfer_asset() == asset,
                    comment="Wrong ASA ID",
                ),
                Assert(
                    deposit.get().asset_receiver()
                    == Global.current_application_address(),
                    comment="ASA must be sent to application address",
                ),
            )
        ),

        # Bid must exceed the current highest bid
        Assert(
            deposit.get().amount()
            > app.state.highest_bid[auctioneer.get()],
            comment="Bid too low",
        ),

        # ------------------------------------------------------------------
        # Refund previous highest bidder (if any)
        # ------------------------------------------------------------------
        pay_or_close(asset, prev_bidder, prev_bid),

        # ------------------------------------------------------------------
        # Update auction state
        # ------------------------------------------------------------------
        app.state.bid[Txn.sender()].set(deposit.get().amount()),
        app.state.highest_bidder[auctioneer.get()].set(Txn.sender()),
        app.state.highest_bid[auctioneer.get()].set(deposit.get().amount()),
    )


# -----------------------------------------------------------------------------
# End auction
# -----------------------------------------------------------------------------

@app.external
def finalize_auction():
    """
    Ends the auction and transfers the highest bid
    to the auctioneer.
    """

    asset = app.state.asset_id[Txn.sender()]

    return Seq(
        # Only the auctioneer can end the auction
        Assert(
            Txn.sender() == app.state.auctioneer[Txn.sender()],
            comment="Only auctioneer can end auction",
        ),

        # Auction must still be active
        Assert(
            app.state.expired[Txn.sender()] == Expired.FALSE,
            comment="Auction already ended",
        ),

        # Pay auctioneer the highest bid
        pay_or_close(
            asset,
            app.state.auctioneer[Txn.sender()],
            app.state.highest_bid[Txn.sender()],
        ),

        # Mark auction as expired
        app.state.expired[Txn.sender()].set(Expired.TRUE),
    )


# -----------------------------------------------------------------------------
# Payment helper (Algo / ASA)
# -----------------------------------------------------------------------------

@pt.Subroutine(pt.TealType.none)
def pay_or_close(asset_id, receiver, amt):
    """
    Sends funds to `receiver`.

    - For Algos:
        * Uses close_remainder_to if near MBR
        * Otherwise sends exact amount
    - For ASA:
        * Sends exact asset amount
    """

    return If(amt > Int(0)).Then(
        If(asset_id == Int(0))
        .Then(
            # -----------------------------
            # Algo payment
            # -----------------------------
            If(
                pt.Balance(Global.current_application_address()) - amt
                < Int(100_000)
            )
            .Then(
                InnerTxnBuilder.Execute(
                    {
                        TxnField.type_enum: TxnType.Payment,
                        TxnField.close_remainder_to: receiver,
                        TxnField.fee: Int(0),
                    }
                )
            )
            .Else(
                InnerTxnBuilder.Execute(
                    {
                        TxnField.type_enum: TxnType.Payment,
                        TxnField.receiver: receiver,
                        TxnField.amount: amt,
                        TxnField.fee: Int(0),
                    }
                )
            )
        )
        .Else(
            # -----------------------------
            # ASA transfer
            # -----------------------------
            InnerTxnBuilder.Execute(
                {
                    TxnField.type_enum: TxnType.AssetTransfer,
                    TxnField.xfer_asset: asset_id,
                    TxnField.asset_receiver: receiver,
                    TxnField.asset_amount: amt,
                    TxnField.fee: Int(0),
                }
            )
        )
    )


# -----------------------------------------------------------------------------
# Build artifacts
# -----------------------------------------------------------------------------

if __name__ == "__main__":
    app.build().export("artifacts")
