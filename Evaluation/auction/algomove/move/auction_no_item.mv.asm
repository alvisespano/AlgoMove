// Move bytecode v7
module aaa.auction {
use 0000000000000000000000000000000000000000000000000000000000000aaa::asset;
use 0000000000000000000000000000000000000000000000000000000000000aaa::utils;


struct Auction has key {
	auctioneer: address,
	top_bidder: address,
	expired: bool
}
struct Bid<phantom Ty0> has key {
	assets: Asset<Ty0>
}

public bid<Ty0>(Arg0: &signer, Arg1: address, Arg2: Asset<Ty0>) /* def_idx: 0 */ {
L3:	loc0: &mut Auction
L4:	loc1: Asset<Ty0>
B0:
	0: MoveLoc[1](Arg1: address)
	1: MutBorrowGlobal[0](Auction)
	2: StLoc[3](loc0: &mut Auction)
	3: CopyLoc[3](loc0: &mut Auction)
	4: ImmBorrowField[0](Auction.top_bidder: address)
	5: ReadRef
	6: MoveFromGeneric[0](Bid<Ty0>)
	7: UnpackGeneric[0](Bid<Ty0>)
	8: StLoc[4](loc1: Asset<Ty0>)
	9: CopyLoc[3](loc0: &mut Auction)
	10: ImmBorrowField[1](Auction.expired: bool)
	11: ReadRef
	12: BrTrue(40)
B1:
	13: ImmBorrowLoc[2](Arg2: Asset<Ty0>)
	14: Call asset::value<Ty0>(&Asset<Ty0>): u64
	15: ImmBorrowLoc[4](loc1: Asset<Ty0>)
	16: Call asset::value<Ty0>(&Asset<Ty0>): u64
	17: Gt
	18: BrFalse(34)
B2:
	19: CopyLoc[3](loc0: &mut Auction)
	20: ImmBorrowField[0](Auction.top_bidder: address)
	21: ReadRef
	22: MoveLoc[4](loc1: Asset<Ty0>)
	23: Call asset::deposit<Ty0>(address, Asset<Ty0>)
	24: CopyLoc[0](Arg0: &signer)
	25: Call utils::address_of_signer(&signer): address
	26: MoveLoc[3](loc0: &mut Auction)
	27: MutBorrowField[0](Auction.top_bidder: address)
	28: WriteRef
	29: MoveLoc[0](Arg0: &signer)
	30: MoveLoc[2](Arg2: Asset<Ty0>)
	31: PackGeneric[0](Bid<Ty0>)
	32: MoveToGeneric[0](Bid<Ty0>)
	33: Ret
B3:
	34: MoveLoc[0](Arg0: &signer)
	35: Pop
	36: MoveLoc[3](loc0: &mut Auction)
	37: Pop
	38: LdU64(2)
	39: Abort
B4:
	40: MoveLoc[0](Arg0: &signer)
	41: Pop
	42: MoveLoc[3](loc0: &mut Auction)
	43: Pop
	44: LdU64(1)
	45: Abort
}
public finalize_auction<Ty0>(Arg0: &signer) /* def_idx: 1 */ {
L1:	loc0: address
L2:	loc1: &mut Auction
L3:	loc2: Asset<Ty0>
B0:
	0: MoveLoc[0](Arg0: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[1](loc0: address)
	3: CopyLoc[1](loc0: address)
	4: MutBorrowGlobal[0](Auction)
	5: StLoc[2](loc1: &mut Auction)
	6: CopyLoc[1](loc0: address)
	7: CopyLoc[2](loc1: &mut Auction)
	8: ImmBorrowField[2](Auction.auctioneer: address)
	9: ReadRef
	10: Eq
	11: BrFalse(26)
B1:
	12: LdTrue
	13: CopyLoc[2](loc1: &mut Auction)
	14: MutBorrowField[1](Auction.expired: bool)
	15: WriteRef
	16: MoveLoc[2](loc1: &mut Auction)
	17: ImmBorrowField[0](Auction.top_bidder: address)
	18: ReadRef
	19: MoveFromGeneric[0](Bid<Ty0>)
	20: UnpackGeneric[0](Bid<Ty0>)
	21: StLoc[3](loc2: Asset<Ty0>)
	22: MoveLoc[1](loc0: address)
	23: MoveLoc[3](loc2: Asset<Ty0>)
	24: Call asset::deposit<Ty0>(address, Asset<Ty0>)
	25: Ret
B2:
	26: MoveLoc[2](loc1: &mut Auction)
	27: Pop
	28: LdU64(3)
	29: Abort
}
public start_auction<Ty0>(Arg0: &signer, Arg1: Asset<Ty0>) /* def_idx: 2 */ {
L2:	loc0: address
L3:	loc1: Auction
B0:
	0: CopyLoc[0](Arg0: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[2](loc0: address)
	3: CopyLoc[2](loc0: address)
	4: MoveLoc[2](loc0: address)
	5: LdFalse
	6: Pack[0](Auction)
	7: StLoc[3](loc1: Auction)
	8: CopyLoc[0](Arg0: &signer)
	9: MoveLoc[3](loc1: Auction)
	10: MoveTo[0](Auction)
	11: MoveLoc[0](Arg0: &signer)
	12: MoveLoc[1](Arg1: Asset<Ty0>)
	13: PackGeneric[0](Bid<Ty0>)
	14: MoveToGeneric[0](Bid<Ty0>)
	15: Ret
}
}