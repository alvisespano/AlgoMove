import pyteal as pt
from pyteal import Seq, Assert, Txn, Global, TxnField, TxnType, InnerTxnBuilder, Int
import beaker

class Expired:
    FALSE = Int(1)
    TRUE = Int(2)


class AuctionState:
    auctioneer = beaker.LocalStateValue(
        stack_type=pt.TealType.bytes,
        static=True,
        descr="auctioneer of the object",
    )
    expired = beaker.LocalStateValue(
        stack_type=pt.TealType.uint64,
        descr="Flag indicating if the auction has expired",
    )
    highest_bid = beaker.LocalStateValue(
        stack_type=pt.TealType.uint64,
        descr="The current winning bid",
    )
    highest_bidder = beaker.LocalStateValue(
        stack_type=pt.TealType.bytes,
        descr="The current winning bidder",
    )
    bid = beaker.LocalStateValue(
        stack_type=pt.TealType.uint64,
        descr="Bid of an actor",
    )

app = beaker.Application("Auction", state=AuctionState())

@app.external
def start(
    starting_bid_: pt.abi.PaymentTransaction,
):
    return Seq(
        app.state.auctioneer[Txn.sender()].set(Txn.sender()),
        app.state.highest_bid[Txn.sender()].set(starting_bid_.get().amount()),
        # Set auction end time
        app.state.expired[Txn.sender()].set(Expired.FALSE),
    )

@app.external(method_config=pt.MethodConfig(
    opt_in=pt.CallConfig.CALL,
    no_op=pt.CallConfig.CALL,
))
def bid(
    auctioneer: pt.abi.Address,
    deposit: pt.abi.PaymentTransaction,
    
):
    return Seq(
        Assert(app.state.expired[auctioneer.get()] == Expired.FALSE,
               comment="Bids can only be placed before expiration"),
        Assert(deposit.get().amount() > app.state.highest_bid[auctioneer.get()],
               comment="Bid must be higher than previous bid"),

        # Send back to the highest bidder their previous bid (0 at first bid)
        pay_or_close(app.state.highest_bidder[auctioneer.get()].get(), app.state.bid[app.state.highest_bidder[auctioneer.get()].get()]),

        # Update bid and highest bid info
        app.state.bid[Txn.sender()].set(deposit.get().amount()),
        app.state.highest_bidder[Txn.sender()].set(Txn.sender()),
        app.state.highest_bid[Txn.sender()].set(deposit.get().amount()),
    )

@app.external
def end():
    return Seq(
        Assert(Txn.sender() == app.state.auctioneer[Txn.sender()],
               comment="Only the auctioneer can close the contract"),
        Assert(app.state.expired[Txn.sender()] == Expired.FALSE,
               comment="Auction must be running"),

        # Pay auctioneer the highest bid
        pay_or_close(app.state.auctioneer[Txn.sender()], app.state.highest_bid[Txn.sender()]),

        # Transition to end state
        app.state.expired[Txn.sender()].set(Expired.TRUE),
    )

@pt.Subroutine(pt.TealType.none)
def pay_or_close(receiver, amt):
    return (
        # Only do something if an amount > 0 is being sent
        pt.If(amt > Int(0)).Then(
            # If it is the full balance (minus some < MBR amount), send all
            # Note that any amount < MBR must have been sent outside of the contracts logic, as the starting
            # bid is at least the MBR
            pt.If(pt.Balance(Global.current_application_address()) - amt < Int(100000)).Then(
                InnerTxnBuilder.Execute({
                    TxnField.type_enum: TxnType.Payment,
                    TxnField.close_remainder_to: receiver,
                    TxnField.fee: Int(0),
                })
            # Otherwise, just send the specified amount
            ).Else(
                InnerTxnBuilder.Execute({
                    TxnField.type_enum: TxnType.Payment,
                    TxnField.receiver: receiver,
                    TxnField.amount: amt,
                    TxnField.fee: Int(0),
                })
            )
        )
    )


if __name__ == "__main__":
    app.build().export("artifacts")
