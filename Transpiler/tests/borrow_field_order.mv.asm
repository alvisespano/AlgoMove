// Move bytecode v7
module aaaa.borrow_field_order {
struct B has drop, store, key {
	b: bool,
	u: u64
}
struct A has copy, drop, store, key {
	b: bool,
	u: u64
}
struct C has drop, key {
	x: A,
	y: B
}

public borrow_manipulation(account: address): bool /* def_idx: 0 */ {
L1:	a: &mut A
L2:	b: &mut B
L3:	c: &mut C
L4:	$t5: bool
B0:
	0: CopyLoc[0](account: address)
	1: MutBorrowGlobal[1](A)
	2: StLoc[1](a: &mut A)
	3: CopyLoc[0](account: address)
	4: MutBorrowGlobal[0](B)
	5: StLoc[2](b: &mut B)
	6: MoveLoc[0](account: address)
	7: MutBorrowGlobal[2](C)
	8: StLoc[3](c: &mut C)
	9: CopyLoc[3](c: &mut C)
	10: ImmBorrowField[0](C.x: A)
	11: ImmBorrowField[1](A.u: u64)
	12: ReadRef
	13: MoveLoc[3](c: &mut C)
	14: ImmBorrowField[2](C.y: B)
	15: ImmBorrowField[3](B.u: u64)
	16: ReadRef
	17: Add
	18: MoveLoc[1](a: &mut A)
	19: ImmBorrowField[1](A.u: u64)
	20: ReadRef
	21: MoveLoc[2](b: &mut B)
	22: ImmBorrowField[3](B.u: u64)
	23: ReadRef
	24: Add
	25: Eq
	26: BrFalse(31)
B1:
	27: LdTrue
	28: StLoc[4]($t5: bool)
B2:
	29: MoveLoc[4]($t5: bool)
	30: Ret
B3:
	31: LdFalse
	32: StLoc[4]($t5: bool)
	33: Branch(29)
}
entry public manipulation() /* def_idx: 1 */ {
L0:	$t1: u64
L1:	m: &u64
L2:	b: B
L3:	a: A
L4:	c: C
L5:	$t4: u64
L6:	$t3: bool
L7:	a_b: A
B0:
	0: LdU64(5)
	1: StLoc[0]($t1: u64)
	2: ImmBorrowLoc[0]($t1: u64)
	3: Pop
	4: LdFalse
	5: LdU64(5)
	6: Pack[1](A)
	7: LdTrue
	8: LdU64(18)
	9: Pack[0](B)
	10: Pack[2](C)
	11: StLoc[4](c: C)
	12: ImmBorrowLoc[4](c: C)
	13: ImmBorrowField[0](C.x: A)
	14: ImmBorrowField[1](A.u: u64)
	15: ReadRef
	16: ImmBorrowLoc[4](c: C)
	17: ImmBorrowField[2](C.y: B)
	18: ImmBorrowField[3](B.u: u64)
	19: ReadRef
	20: Add
	21: StLoc[5]($t4: u64)
	22: ImmBorrowLoc[4](c: C)
	23: ImmBorrowField[0](C.x: A)
	24: ImmBorrowField[4](A.b: bool)
	25: ReadRef
	26: BrFalse(51)
B1:
	27: ImmBorrowLoc[4](c: C)
	28: ImmBorrowField[2](C.y: B)
	29: ImmBorrowField[5](B.b: bool)
	30: ReadRef
	31: StLoc[6]($t3: bool)
B2:
	32: MoveLoc[6]($t3: bool)
	33: MoveLoc[5]($t4: u64)
	34: Pack[1](A)
	35: StLoc[7](a_b: A)
	36: ImmBorrowLoc[4](c: C)
	37: ImmBorrowField[2](C.y: B)
	38: ImmBorrowField[3](B.u: u64)
	39: ReadRef
	40: ImmBorrowLoc[7](a_b: A)
	41: ImmBorrowField[1](A.u: u64)
	42: ReadRef
	43: Mul
	44: ImmBorrowLoc[4](c: C)
	45: ImmBorrowField[0](C.x: A)
	46: ImmBorrowField[1](A.u: u64)
	47: ReadRef
	48: Add
	49: Pop
	50: Ret
B3:
	51: LdFalse
	52: StLoc[6]($t3: bool)
	53: Branch(32)
}
public read_ref1(r: &u64): u64 /* def_idx: 2 */ {
B0:
	0: MoveLoc[0](r: &u64)
	1: ReadRef
	2: LdU64(1)
	3: Add
	4: Ret
}
public read_ref2(r: &A): u64 /* def_idx: 3 */ {
B0:
	0: MoveLoc[0](r: &A)
	1: ImmBorrowField[1](A.u: u64)
	2: ReadRef
	3: Ret
}
public read_ref_caller(a: address) /* def_idx: 4 */ {
L1:	a1: A
L2:	$t10: u64
L3:	b: B
L4:	c: C
B0:
	0: LdTrue
	1: LdU64(78)
	2: Pack[1](A)
	3: StLoc[1](a1: A)
	4: MoveLoc[0](a: address)
	5: MutBorrowGlobal[1](A)
	6: ImmBorrowLoc[1](a1: A)
	7: ImmBorrowField[1](A.u: u64)
	8: Call read_ref1(&u64): u64
	9: Pop
	10: LdU64(56)
	11: StLoc[2]($t10: u64)
	12: ImmBorrowLoc[2]($t10: u64)
	13: Call read_ref1(&u64): u64
	14: Pop
	15: LdTrue
	16: LdU64(18)
	17: Pack[0](B)
	18: StLoc[3](b: B)
	19: CopyLoc[1](a1: A)
	20: MoveLoc[3](b: B)
	21: Pack[2](C)
	22: StLoc[4](c: C)
	23: ImmBorrowLoc[4](c: C)
	24: ImmBorrowField[0](C.x: A)
	25: ImmBorrowField[1](A.u: u64)
	26: Call read_ref1(&u64): u64
	27: Pop
	28: ImmBorrowLoc[1](a1: A)
	29: Call read_ref2(&A): u64
	30: Pop
	31: FreezeRef
	32: Call read_ref2(&A): u64
	33: Pop
	34: Ret
}
}