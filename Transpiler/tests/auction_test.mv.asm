// Move bytecode v7
module aaa.auction_test {
use 0000000000000000000000000000000000000000000000000000000000000aaa::utils;
use 0000000000000000000000000000000000000000000000000000000000000aaa::asset;
use 0000000000000000000000000000000000000000000000000000000000000aaa::auction_with_item;


struct Car has store {
	name: vector<u8>,
	power: u64
}
struct EUR {
	dummy_field: bool
}
struct Pair<A, B> {
	fst: A,
	snd: B
}
struct Prize has key {
	car: Car
}

public f<A, B>(): vector<u8> /* def_idx: 0 */ {
B0:
	0: Call utils::name_of<Pair<A, Pair<A, B>>>(): vector<u8>
	1: Ret
}
entry public start(acc: &signer) /* def_idx: 1 */ {
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
entry public bidder(acc: &signer, auc: address) /* def_idx: 2 */ {
L2:	amt: u64
L3:	a: Asset<EUR>
L4:	car: Car
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
	8: Call asset::withdraw<EUR>(&signer, u64): Asset<EUR>
	9: StLoc[3](a: Asset<EUR>)
	10: CopyLoc[0](acc: &signer)
	11: CopyLoc[1](auc: address)
	12: MoveLoc[3](a: Asset<EUR>)
	13: Call auction_with_item::bid<EUR, Car>(&signer, address, Asset<EUR>)
	14: MoveLoc[2](amt: u64)
	15: LdU64(1000)
	16: Add
	17: StLoc[2](amt: u64)
	18: Branch(2)
B3:
	19: CopyLoc[0](acc: &signer)
	20: MoveLoc[1](auc: address)
	21: Call auction_with_item::retrieve_prize<EUR, Car>(&signer, address): Car
	22: StLoc[4](car: Car)
	23: MoveLoc[0](acc: &signer)
	24: MoveLoc[4](car: Car)
	25: Pack[3](Prize)
	26: MoveTo[3](Prize)
	27: Ret
}
entry public finalize(acc: &signer) /* def_idx: 3 */ {
B0:
	0: MoveLoc[0](acc: &signer)
	1: Call auction_with_item::finalize_auction<EUR, Car>(&signer)
	2: Ret
}
}