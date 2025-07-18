// Move bytecode v7
module aaaa.vectors {


public f(x: u64) /* def_idx: 0 */ {
B0:
	0: MoveLoc[0](x: u64)
	1: LdU64(1)
	2: Add
	3: Pop
	4: Ret
}
public access2d(v: vector<vector<u8>>): u8 /* def_idx: 1 */ {
L1:	$t16: vector<u8>
B0:
	0: ImmBorrowLoc[0](v: vector<vector<u8>>)
	1: LdU64(11)
	2: VecImmBorrow(4)
	3: LdU64(23)
	4: VecImmBorrow(3)
	5: ReadRef
	6: MutBorrowLoc[0](v: vector<vector<u8>>)
	7: LdU64(1)
	8: VecMutBorrow(4)
	9: LdU64(2)
	10: VecMutBorrow(3)
	11: WriteRef
	12: LdConst[0](Vector(U8): [7, 1, 2, 3, 4, 5, 6, 7])
	13: StLoc[1]($t16: vector<u8>)
	14: ImmBorrowLoc[1]($t16: vector<u8>)
	15: LdU64(0)
	16: VecImmBorrow(3)
	17: ReadRef
	18: ImmBorrowLoc[0](v: vector<vector<u8>>)
	19: LdU64(11)
	20: VecImmBorrow(4)
	21: LdU64(23)
	22: VecImmBorrow(3)
	23: ReadRef
	24: Add
	25: Ret
}
public creation() /* def_idx: 2 */ {
L0:	v: vector<u64>
B0:
	0: VecPack(0, 0)
	1: StLoc[0](v: vector<u64>)
	2: MutBorrowLoc[0](v: vector<u64>)
	3: LdU64(10)
	4: VecPushBack(0)
	5: MutBorrowLoc[0](v: vector<u64>)
	6: LdU64(20)
	7: VecPushBack(0)
	8: ImmBorrowLoc[0](v: vector<u64>)
	9: VecLen(0)
	10: LdU64(2)
	11: Eq
	12: BrFalse(41)
B1:
	13: ImmBorrowLoc[0](v: vector<u64>)
	14: LdU64(0)
	15: VecImmBorrow(0)
	16: ReadRef
	17: LdU64(10)
	18: Eq
	19: BrFalse(39)
B2:
	20: ImmBorrowLoc[0](v: vector<u64>)
	21: LdU64(1)
	22: VecImmBorrow(0)
	23: ReadRef
	24: LdU64(20)
	25: Eq
	26: BrFalse(37)
B3:
	27: MutBorrowLoc[0](v: vector<u64>)
	28: VecPopBack(0)
	29: LdU64(20)
	30: Eq
	31: BrFalse(35)
B4:
	32: MoveLoc[0](v: vector<u64>)
	33: VecUnpack(0, 0)
	34: Ret
B5:
	35: LdU64(0)
	36: Abort
B6:
	37: LdU64(0)
	38: Abort
B7:
	39: LdU64(0)
	40: Abort
B8:
	41: LdU64(0)
	42: Abort
}
public creation_poly<T: drop>(x: T) /* def_idx: 3 */ {
L1:	v: vector<T>
B0:
	0: VecPack(6, 0)
	1: StLoc[1](v: vector<T>)
	2: MutBorrowLoc[1](v: vector<T>)
	3: MoveLoc[0](x: T)
	4: VecPushBack(6)
	5: MutBorrowLoc[1](v: vector<T>)
	6: VecPopBack(6)
	7: Pop
	8: Ret
}
}