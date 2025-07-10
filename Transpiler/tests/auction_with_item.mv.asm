// Move bytecode v7
module aaa.auction_with_item {
use 0000000000000000000000000000000000000000000000000000000000000aaa::asset;
use 0000000000000000000000000000000000000000000000000000000000000aaa::utils;


struct Auction<ItemType: store> has key {
	item: ItemType,
	auctioneer: address,
	top_bidder: address,
	expired: bool
}
struct Bid<phantom AssetType> has key {
	assets: Asset<AssetType>
}

public entry bid<AssetType, ItemType: store>(acc: &signer, auctioneer: address, assets: Asset<AssetType>) /* def_idx: 0 */ {
L3:	auction: &mut Auction<ItemType>
L4:	top_bid: Asset<AssetType>
B0:
	0: MoveLoc[1](auctioneer: address)
	1: MutBorrowGlobalGeneric[0](Auction<ItemType>)
	2: StLoc[3](auction: &mut Auction<ItemType>)
	3: CopyLoc[3](auction: &mut Auction<ItemType>)
	4: ImmBorrowFieldGeneric[0](Auction.top_bidder: address)
	5: ReadRef
	6: MoveFromGeneric[1](Bid<AssetType>)
	7: UnpackGeneric[1](Bid<AssetType>)
	8: StLoc[4](top_bid: Asset<AssetType>)
	9: CopyLoc[3](auction: &mut Auction<ItemType>)
	10: ImmBorrowFieldGeneric[1](Auction.expired: bool)
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
	19: CopyLoc[3](auction: &mut Auction<ItemType>)
	20: ImmBorrowFieldGeneric[0](Auction.top_bidder: address)
	21: ReadRef
	22: MoveLoc[4](top_bid: Asset<AssetType>)
	23: Call asset::deposit<AssetType>(address, Asset<AssetType>)
	24: CopyLoc[0](acc: &signer)
	25: Call utils::address_of_signer(&signer): address
	26: MoveLoc[3](auction: &mut Auction<ItemType>)
	27: MutBorrowFieldGeneric[0](Auction.top_bidder: address)
	28: WriteRef
	29: MoveLoc[0](acc: &signer)
	30: MoveLoc[2](assets: Asset<AssetType>)
	31: PackGeneric[1](Bid<AssetType>)
	32: MoveToGeneric[1](Bid<AssetType>)
	33: Ret
B3:
	34: MoveLoc[0](acc: &signer)
	35: Pop
	36: MoveLoc[3](auction: &mut Auction<ItemType>)
	37: Pop
	38: LdU64(2)
	39: Abort
B4:
	40: MoveLoc[0](acc: &signer)
	41: Pop
	42: MoveLoc[3](auction: &mut Auction<ItemType>)
	43: Pop
	44: LdU64(1)
	45: Abort
}
public entry finalize_auction<AssetType, ItemType: store>(acc: &signer) /* def_idx: 1 */ {
L1:	auctioneer: address
L2:	auction: &mut Auction<ItemType>
L3:	top_bid: Asset<AssetType>
B0:
	0: MoveLoc[0](acc: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[1](auctioneer: address)
	3: CopyLoc[1](auctioneer: address)
	4: MutBorrowGlobalGeneric[0](Auction<ItemType>)
	5: StLoc[2](auction: &mut Auction<ItemType>)
	6: CopyLoc[1](auctioneer: address)
	7: CopyLoc[2](auction: &mut Auction<ItemType>)
	8: ImmBorrowFieldGeneric[2](Auction.auctioneer: address)
	9: ReadRef
	10: Eq
	11: BrFalse(26)
B1:
	12: LdTrue
	13: CopyLoc[2](auction: &mut Auction<ItemType>)
	14: MutBorrowFieldGeneric[1](Auction.expired: bool)
	15: WriteRef
	16: MoveLoc[2](auction: &mut Auction<ItemType>)
	17: ImmBorrowFieldGeneric[0](Auction.top_bidder: address)
	18: ReadRef
	19: MoveFromGeneric[1](Bid<AssetType>)
	20: UnpackGeneric[1](Bid<AssetType>)
	21: StLoc[3](top_bid: Asset<AssetType>)
	22: MoveLoc[1](auctioneer: address)
	23: MoveLoc[3](top_bid: Asset<AssetType>)
	24: Call asset::deposit<AssetType>(address, Asset<AssetType>)
	25: Ret
B2:
	26: MoveLoc[2](auction: &mut Auction<ItemType>)
	27: Pop
	28: LdU64(3)
	29: Abort
}
public entry start_auction<AssetType, ItemType: store>(acc: &signer, base: Asset<AssetType>, item: ItemType) /* def_idx: 2 */ {
L3:	auctioneer: address
L4:	auction: Auction<ItemType>
B0:
	0: CopyLoc[0](acc: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[3](auctioneer: address)
	3: MoveLoc[2](item: ItemType)
	4: CopyLoc[3](auctioneer: address)
	5: MoveLoc[3](auctioneer: address)
	6: LdFalse
	7: PackGeneric[0](Auction<ItemType>)
	8: StLoc[4](auction: Auction<ItemType>)
	9: CopyLoc[0](acc: &signer)
	10: MoveLoc[4](auction: Auction<ItemType>)
	11: MoveToGeneric[0](Auction<ItemType>)
	12: MoveLoc[0](acc: &signer)
	13: MoveLoc[1](base: Asset<AssetType>)
	14: PackGeneric[1](Bid<AssetType>)
	15: MoveToGeneric[1](Bid<AssetType>)
	16: Ret
}
public entry retrieve_prize<AssetType, ItemType: store>(acc: &signer, auctioneer: address): ItemType /* def_idx: 3 */ {
L2:	self: address
L3:	expired: bool
L4:	top_bidder: address
L5:	auc: address
L6:	item: ItemType
B0:
	0: MoveLoc[0](acc: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[2](self: address)
	3: CopyLoc[1](auctioneer: address)
	4: MoveFromGeneric[0](Auction<ItemType>)
	5: UnpackGeneric[0](Auction<ItemType>)
	6: StLoc[3](expired: bool)
	7: StLoc[4](top_bidder: address)
	8: StLoc[5](auc: address)
	9: StLoc[6](item: ItemType)
	10: MoveLoc[1](auctioneer: address)
	11: MoveLoc[5](auc: address)
	12: Eq
	13: BrFalse(28)
B1:
	14: MoveLoc[2](self: address)
	15: MoveLoc[4](top_bidder: address)
	16: Eq
	17: BrFalse(26)
B2:
	18: MoveLoc[3](expired: bool)
	19: LdTrue
	20: Eq
	21: BrFalse(24)
B3:
	22: MoveLoc[6](item: ItemType)
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