// Move bytecode v7
module aaa.auction_test {
use 0000000000000000000000000000000000000000000000000000000000000aaa::asset;
use 0000000000000000000000000000000000000000000000000000000000000aaa::auction_with_item;


struct Car has store {
	name: vector<u8>,
	power: u64
}
struct EUR {
	dummy_field: bool
}
struct Prize has key {
	car: Car
}

entry public start(acc: &signer) /* def_idx: 0 */ {
L1:	item: Car
L2:	base: Asset<EUR>
B0:
	0: LdConst[0](Vector(U8): [5, 71, 111, 108, 102, 56])
	1: LdU64(160)
	2: Pack[0](Car)
	3: StLoc[1](item: Car)
	4: CopyLoc[0](acc: &signer)
	5: LdU64(20000)
	6: Call asset::withdraw<EUR>(&signer, u64): Asset<EUR>
	7: StLoc[2](base: Asset<EUR>)
	8: MoveLoc[0](acc: &signer)
	9: MoveLoc[2](base: Asset<EUR>)
	10: MoveLoc[1](item: Car)
	11: Call auction_with_item::start_auction<EUR, Car>(&signer, Asset<EUR>, Car)
	12: Ret
}
entry public bidder(acc: &signer, auc: address) /* def_idx: 1 */ {
L2:	a: Asset<EUR>
L3:	car: Car
B0:
	0: CopyLoc[0](acc: &signer)
	1: LdU64(20001)
	2: Call asset::withdraw<EUR>(&signer, u64): Asset<EUR>
	3: StLoc[2](a: Asset<EUR>)
	4: CopyLoc[0](acc: &signer)
	5: CopyLoc[1](auc: address)
	6: MoveLoc[2](a: Asset<EUR>)
	7: Call auction_with_item::bid<EUR, Car>(&signer, address, Asset<EUR>)
	8: Branch(0)
B1:
	9: CopyLoc[0](acc: &signer)
	10: MoveLoc[1](auc: address)
	11: Call auction_with_item::retrieve_prize<EUR, Car>(&signer, address): Car
	12: StLoc[3](car: Car)
	13: MoveLoc[0](acc: &signer)
	14: MoveLoc[3](car: Car)
	15: Pack[2](Prize)
	16: MoveTo[2](Prize)
	17: Ret
}
entry public finalize(acc: &signer) /* def_idx: 2 */ {
B0:
	0: MoveLoc[0](acc: &signer)
	1: Call auction_with_item::finalize_auction<EUR, Car>(&signer)
	2: Ret
}
}