// Move bytecode v9
module aaa.auction_mono2 {
use 0000000000000000000000000000000000000000000000000000000000000aaa::asset;
use 0000000000000000000000000000000000000000000000000000000000000aaa::utils;


struct Auction has key {
	auctioneer: address,
	top_bidder: address,
	expired: bool
}
struct Bid<phantom AssetType> has key {
	assets: Asset<AssetType>
}

public bid<AssetType>(acc: &signer, auctioneer: address, assets: Asset<AssetType>) /* def_idx: 0 */ {
L3:	auction: &mut Auction
L4:	top_bid: Asset<AssetType>
B0:
	0: MoveLoc[1](auctioneer: address)
	1: MutBorrowGlobal[0](Auction)
	2: StLoc[3](auction: &mut Auction)
	3: CopyLoc[3](auction: &mut Auction)
	4: ImmBorrowField[0](Auction.top_bidder: address)
	5: ReadRef
	6: MoveFromGeneric[0](Bid<AssetType>)
	7: UnpackGeneric[0](Bid<AssetType>)
	8: StLoc[4](top_bid: Asset<AssetType>)
	9: CopyLoc[3](auction: &mut Auction)
	10: ImmBorrowField[1](Auction.expired: bool)
	11: ReadRef
	12: BrTrue(40)
B1:
	13: ImmBorrowLoc[2](assets: Asset<AssetType>)
	14: Call asset::value<AssetType>(&Asset<AssetType>): u64
	15: ImmBorrowLoc[4](top_bid: Asset<AssetType>)
	16: Call asset::value<AssetType>(&Asset<AssetType>): u64
	17: Gt
	18: BrFalse(34)
B2:
	19: CopyLoc[3](auction: &mut Auction)
	20: ImmBorrowField[0](Auction.top_bidder: address)
	21: ReadRef
	22: MoveLoc[4](top_bid: Asset<AssetType>)
	23: Call asset::deposit<AssetType>(address, Asset<AssetType>)
	24: CopyLoc[0](acc: &signer)
	25: Call utils::address_of_signer(&signer): address
	26: MoveLoc[3](auction: &mut Auction)
	27: MutBorrowField[0](Auction.top_bidder: address)
	28: WriteRef
	29: MoveLoc[0](acc: &signer)
	30: MoveLoc[2](assets: Asset<AssetType>)
	31: PackGeneric[0](Bid<AssetType>)
	32: MoveToGeneric[0](Bid<AssetType>)
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
public finalize_auction<AssetType>(acc: &signer) /* def_idx: 1 */ {
L1:	auctioneer: address
L2:	auction: &mut Auction
L3:	top_bid: Asset<AssetType>
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
	19: MoveFromGeneric[0](Bid<AssetType>)
	20: UnpackGeneric[0](Bid<AssetType>)
	21: StLoc[3](top_bid: Asset<AssetType>)
	22: MoveLoc[1](auctioneer: address)
	23: MoveLoc[3](top_bid: Asset<AssetType>)
	24: Call asset::deposit<AssetType>(address, Asset<AssetType>)
	25: Ret
B2:
	26: MoveLoc[2](auction: &mut Auction)
	27: Pop
	28: LdU64(3)
	29: Abort
}
public start_auction<AssetType>(acc: &signer, base: Asset<AssetType>) /* def_idx: 2 */ {
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
	12: MoveLoc[1](base: Asset<AssetType>)
	13: PackGeneric[0](Bid<AssetType>)
	14: MoveToGeneric[0](Bid<AssetType>)
	15: Ret
}
}