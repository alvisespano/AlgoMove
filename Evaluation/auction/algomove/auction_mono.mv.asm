// Move bytecode v9
module aaa.auction_mono {
use 0000000000000000000000000000000000000000000000000000000000000aaa::asset;
use 0000000000000000000000000000000000000000000000000000000000000aaa::utils;


struct Auction has key {
	auctioneer: address,
	top_bidder: address,
	expired: bool
}
struct Bid has key {
	assets: Asset<Dollar>
}
struct Dollar has store {
	amount: u64
}

entry public start(acc: &signer) /* def_idx: 0 */ {
L1:	base: Asset<Dollar>
B0:
	0: CopyLoc[0](acc: &signer)
	1: LdU64(20000)
	2: Call asset::withdraw<Dollar>(&signer, u64): Asset<Dollar>
	3: StLoc[1](base: Asset<Dollar>)
	4: MoveLoc[0](acc: &signer)
	5: MoveLoc[1](base: Asset<Dollar>)
	6: Call start_auction(&signer, Asset<Dollar>)
	7: Ret
}
public bid(acc: &signer, auctioneer: address, assets: Asset<Dollar>) /* def_idx: 1 */ {
L3:	auction: &mut Auction
L4:	top_bid: Asset<Dollar>
B0:
	0: MoveLoc[1](auctioneer: address)
	1: MutBorrowGlobal[0](Auction)
	2: StLoc[3](auction: &mut Auction)
	3: CopyLoc[3](auction: &mut Auction)
	4: ImmBorrowField[0](Auction.top_bidder: address)
	5: ReadRef
	6: MoveFrom[1](Bid)
	7: Unpack[1](Bid)
	8: StLoc[4](top_bid: Asset<Dollar>)
	9: CopyLoc[3](auction: &mut Auction)
	10: ImmBorrowField[1](Auction.expired: bool)
	11: ReadRef
	12: BrTrue(40)
B1:
	13: ImmBorrowLoc[2](assets: Asset<Dollar>)
	14: Call asset::value<Dollar>(&Asset<Dollar>): u64
	15: ImmBorrowLoc[4](top_bid: Asset<Dollar>)
	16: Call asset::value<Dollar>(&Asset<Dollar>): u64
	17: Gt
	18: BrFalse(34)
B2:
	19: CopyLoc[3](auction: &mut Auction)
	20: ImmBorrowField[0](Auction.top_bidder: address)
	21: ReadRef
	22: MoveLoc[4](top_bid: Asset<Dollar>)
	23: Call asset::deposit<Dollar>(address, Asset<Dollar>)
	24: CopyLoc[0](acc: &signer)
	25: Call utils::address_of_signer(&signer): address
	26: MoveLoc[3](auction: &mut Auction)
	27: MutBorrowField[0](Auction.top_bidder: address)
	28: WriteRef
	29: MoveLoc[0](acc: &signer)
	30: MoveLoc[2](assets: Asset<Dollar>)
	31: Pack[1](Bid)
	32: MoveTo[1](Bid)
	33: Ret
B3:
	34: MoveLoc[0](acc: &signer)
	35: Pop
	36: MoveLoc[3](auction: &mut Auction)
	37: Pop
	38: LdU64(2)
	39: Abort
B4:
	40: MoveLoc[0](acc: &signer)
	41: Pop
	42: MoveLoc[3](auction: &mut Auction)
	43: Pop
	44: LdU64(1)
	45: Abort
}
entry public bidder(acc: &signer, auc: address) /* def_idx: 2 */ {
L2:	amt: u64
L3:	a: Asset<Dollar>
B0:
	0: LdU64(20001)
	1: StLoc[2](amt: u64)
B1:
	2: CopyLoc[2](amt: u64)
	3: LdU64(30000)
	4: Lt
	5: BrFalse(19)
B2:
	6: CopyLoc[0](acc: &signer)
	7: CopyLoc[2](amt: u64)
	8: Call asset::withdraw<Dollar>(&signer, u64): Asset<Dollar>
	9: StLoc[3](a: Asset<Dollar>)
	10: CopyLoc[0](acc: &signer)
	11: CopyLoc[1](auc: address)
	12: MoveLoc[3](a: Asset<Dollar>)
	13: Call bid(&signer, address, Asset<Dollar>)
	14: MoveLoc[2](amt: u64)
	15: LdU64(1000)
	16: Add
	17: StLoc[2](amt: u64)
	18: Branch(2)
B3:
	19: MoveLoc[0](acc: &signer)
	20: Pop
	21: Ret
}
entry public finalize(acc: &signer) /* def_idx: 3 */ {
B0:
	0: MoveLoc[0](acc: &signer)
	1: Call finalize_auction(&signer)
	2: Ret
}
public finalize_auction(acc: &signer) /* def_idx: 4 */ {
L1:	auctioneer: address
L2:	auction: &mut Auction
L3:	top_bid: Asset<Dollar>
B0:
	0: MoveLoc[0](acc: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[1](auctioneer: address)
	3: CopyLoc[1](auctioneer: address)
	4: MutBorrowGlobal[0](Auction)
	5: StLoc[2](auction: &mut Auction)
	6: CopyLoc[1](auctioneer: address)
	7: CopyLoc[2](auction: &mut Auction)
	8: ImmBorrowField[2](Auction.auctioneer: address)
	9: ReadRef
	10: Eq
	11: BrFalse(26)
B1:
	12: LdTrue
	13: CopyLoc[2](auction: &mut Auction)
	14: MutBorrowField[1](Auction.expired: bool)
	15: WriteRef
	16: MoveLoc[2](auction: &mut Auction)
	17: ImmBorrowField[0](Auction.top_bidder: address)
	18: ReadRef
	19: MoveFrom[1](Bid)
	20: Unpack[1](Bid)
	21: StLoc[3](top_bid: Asset<Dollar>)
	22: MoveLoc[1](auctioneer: address)
	23: MoveLoc[3](top_bid: Asset<Dollar>)
	24: Call asset::deposit<Dollar>(address, Asset<Dollar>)
	25: Ret
B2:
	26: MoveLoc[2](auction: &mut Auction)
	27: Pop
	28: LdU64(3)
	29: Abort
}
public start_auction(acc: &signer, base: Asset<Dollar>) /* def_idx: 5 */ {
L2:	auctioneer: address
L3:	auction: Auction
B0:
	0: CopyLoc[0](acc: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[2](auctioneer: address)
	3: CopyLoc[2](auctioneer: address)
	4: MoveLoc[2](auctioneer: address)
	5: LdFalse
	6: Pack[0](Auction)
	7: StLoc[3](auction: Auction)
	8: CopyLoc[0](acc: &signer)
	9: MoveLoc[3](auction: Auction)
	10: MoveTo[0](Auction)
	11: MoveLoc[0](acc: &signer)
	12: MoveLoc[1](base: Asset<Dollar>)
	13: Pack[1](Bid)
	14: MoveTo[1](Bid)
	15: Ret
}
}