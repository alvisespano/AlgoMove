// Move bytecode v7
module aaaa.vectors {


public access(x: u64, v: vector<u64>): u64 /* def_idx: 0 */ {
B0:
	0: ImmBorrowLoc[1](v: vector<u64>)
	1: MoveLoc[0](x: u64)
	2: VecImmBorrow(1)
	3: ReadRef
	4: ImmBorrowLoc[1](v: vector<u64>)
	5: LdU64(0)
	6: VecImmBorrow(1)
	7: ReadRef
	8: Add
	9: Ret
}
}