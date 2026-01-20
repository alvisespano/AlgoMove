// Move bytecode v7
module aaa.auction_with_item {
use 0000000000000000000000000000000000000000000000000000000000000aaa::asset;
use 0000000000000000000000000000000000000000000000000000000000000aaa::utils;


struct Auction<Ty0: store> has key {
	item: Ty0,
	auctioneer: address,
	top_bidder: address,
	expired: bool
}
struct Bid<phantom Ty0> has key {
	assets: Asset<Ty0>
}

public bid<Ty0, Ty1: store>(Arg0: &signer, Arg1: address, Arg2: Asset<Ty0>) /* def_idx: 0 */ {
L3:	loc0: &mut Auction<Ty1>
L4:	loc1: Asset<Ty0>
B0:
	0: MoveLoc[1](Arg1: address)
	1: MutBorrowGlobalGeneric[0](Auction<Ty1>)
	2: StLoc[3](loc0: &mut Auction<Ty1>)
	3: CopyLoc[3](loc0: &mut Auction<Ty1>)
	4: ImmBorrowFieldGeneric[0](Auction.top_bidder: address)
	5: ReadRef
	6: MoveFromGeneric[1](Bid<Ty0>)
	7: UnpackGeneric[1](Bid<Ty0>)
	8: StLoc[4](loc1: Asset<Ty0>)
	9: CopyLoc[3](loc0: &mut Auction<Ty1>)
	10: ImmBorrowFieldGeneric[1](Auction.expired: bool)
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
	19: CopyLoc[3](loc0: &mut Auction<Ty1>)
	20: ImmBorrowFieldGeneric[0](Auction.top_bidder: address)
	21: ReadRef
	22: MoveLoc[4](loc1: Asset<Ty0>)
	23: Call asset::deposit<Ty0>(address, Asset<Ty0>)
	24: CopyLoc[0](Arg0: &signer)
	25: Call utils::address_of_signer(&signer): address
	26: MoveLoc[3](loc0: &mut Auction<Ty1>)
	27: MutBorrowFieldGeneric[0](Auction.top_bidder: address)
	28: WriteRef
	29: MoveLoc[0](Arg0: &signer)
	30: MoveLoc[2](Arg2: Asset<Ty0>)
	31: PackGeneric[1](Bid<Ty0>)
	32: MoveToGeneric[1](Bid<Ty0>)
	33: Ret
B3:
	34: MoveLoc[0](Arg0: &signer)
	35: Pop
	36: MoveLoc[3](loc0: &mut Auction<Ty1>)
	37: Pop
	38: LdU64(2)
	39: Abort
B4:
	40: MoveLoc[0](Arg0: &signer)
	41: Pop
	42: MoveLoc[3](loc0: &mut Auction<Ty1>)
	43: Pop
	44: LdU64(1)
	45: Abort
}
public finalize_auction<Ty0, Ty1: store>(Arg0: &signer) /* def_idx: 1 */ {
L1:	loc0: address
L2:	loc1: &mut Auction<Ty1>
L3:	loc2: Asset<Ty0>
B0:
	0: MoveLoc[0](Arg0: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[1](loc0: address)
	3: CopyLoc[1](loc0: address)
	4: MutBorrowGlobalGeneric[0](Auction<Ty1>)
	5: StLoc[2](loc1: &mut Auction<Ty1>)
	6: CopyLoc[1](loc0: address)
	7: CopyLoc[2](loc1: &mut Auction<Ty1>)
	8: ImmBorrowFieldGeneric[2](Auction.auctioneer: address)
	9: ReadRef
	10: Eq
	11: BrFalse(26)
B1:
	12: LdTrue
	13: CopyLoc[2](loc1: &mut Auction<Ty1>)
	14: MutBorrowFieldGeneric[1](Auction.expired: bool)
	15: WriteRef
	16: MoveLoc[2](loc1: &mut Auction<Ty1>)
	17: ImmBorrowFieldGeneric[0](Auction.top_bidder: address)
	18: ReadRef
	19: MoveFromGeneric[1](Bid<Ty0>)
	20: UnpackGeneric[1](Bid<Ty0>)
	21: StLoc[3](loc2: Asset<Ty0>)
	22: MoveLoc[1](loc0: address)
	23: MoveLoc[3](loc2: Asset<Ty0>)
	24: Call asset::deposit<Ty0>(address, Asset<Ty0>)
	25: Ret
B2:
	26: MoveLoc[2](loc1: &mut Auction<Ty1>)
	27: Pop
	28: LdU64(3)
	29: Abort
}
public start_auction<Ty0, Ty1: store>(Arg0: &signer, Arg1: Asset<Ty0>, Arg2: Ty1) /* def_idx: 2 */ {
L3:	loc0: address
L4:	loc1: Auction<Ty1>
B0:
	0: CopyLoc[0](Arg0: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[3](loc0: address)
	3: MoveLoc[2](Arg2: Ty1)
	4: CopyLoc[3](loc0: address)
	5: MoveLoc[3](loc0: address)
	6: LdFalse
	7: PackGeneric[0](Auction<Ty1>)
	8: StLoc[4](loc1: Auction<Ty1>)
	9: CopyLoc[0](Arg0: &signer)
	10: MoveLoc[4](loc1: Auction<Ty1>)
	11: MoveToGeneric[0](Auction<Ty1>)
	12: MoveLoc[0](Arg0: &signer)
	13: MoveLoc[1](Arg1: Asset<Ty0>)
	14: PackGeneric[1](Bid<Ty0>)
	15: MoveToGeneric[1](Bid<Ty0>)
	16: Ret
}
public retrieve_prize<Ty0, Ty1: store>(Arg0: &signer, Arg1: address): Ty1 /* def_idx: 3 */ {
L2:	loc0: address
L3:	loc1: bool
L4:	loc2: address
L5:	loc3: address
L6:	loc4: Ty1
B0:
	0: MoveLoc[0](Arg0: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[2](loc0: address)
	3: CopyLoc[1](Arg1: address)
	4: MoveFromGeneric[0](Auction<Ty1>)
	5: UnpackGeneric[0](Auction<Ty1>)
	6: StLoc[3](loc1: bool)
	7: StLoc[4](loc2: address)
	8: StLoc[5](loc3: address)
	9: StLoc[6](loc4: Ty1)
	10: MoveLoc[1](Arg1: address)
	11: MoveLoc[5](loc3: address)
	12: Eq
	13: BrFalse(28)
B1:
	14: MoveLoc[2](loc0: address)
	15: MoveLoc[4](loc2: address)
	16: Eq
	17: BrFalse(26)
B2:
	18: MoveLoc[3](loc1: bool)
	19: LdTrue
	20: Eq
	21: BrFalse(24)
B3:
	22: MoveLoc[6](loc4: Ty1)
	23: Ret
B4:
	24: LdU64(5)
	25: Abort
B5:
	26: LdU64(4)
	27: Abort
B6:
	28: LdU64(3)
	29: Abort
}
}