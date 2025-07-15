// Move bytecode v7
module aaaa.struct_manipulation {
struct B has drop, store, key {
	a: bool,
	b: u64
}
struct A has drop, store, key {
	a: bool,
	b: u64
}
struct Nested has drop, key {
	a: A,
	b: B
}
struct Nested1 has drop {
	a: Simple,
	b: u64
}
struct Simple has drop {
	f: u64,
	g: bool
}

public borrow_manipulation(account: address): bool /* def_idx: 0 */ {
L1:	s2: &mut B
L2:	s3: &mut Nested
L3:	$t5: bool
B0:
	0: CopyLoc[0](account: address)
	1: MutBorrowGlobal[1](A)
	2: CopyLoc[0](account: address)
	3: MutBorrowGlobal[0](B)
	4: StLoc[1](s2: &mut B)
	5: MoveLoc[0](account: address)
	6: MutBorrowGlobal[2](Nested)
	7: StLoc[2](s3: &mut Nested)
	8: ImmBorrowField[0](A.b: u64)
	9: ReadRef
	10: MoveLoc[1](s2: &mut B)
	11: ImmBorrowField[1](B.b: u64)
	12: ReadRef
	13: Add
	14: CopyLoc[2](s3: &mut Nested)
	15: ImmBorrowField[2](Nested.a: A)
	16: ImmBorrowField[0](A.b: u64)
	17: ReadRef
	18: MoveLoc[2](s3: &mut Nested)
	19: ImmBorrowField[3](Nested.b: B)
	20: ImmBorrowField[1](B.b: u64)
	21: ReadRef
	22: Add
	23: Eq
	24: BrFalse(29)
B1:
	25: LdTrue
	26: StLoc[3]($t5: bool)
B2:
	27: MoveLoc[3]($t5: bool)
	28: Ret
B3:
	29: LdFalse
	30: StLoc[3]($t5: bool)
	31: Branch(27)
}
public make_A(): A /* def_idx: 1 */ {
B0:
	0: LdTrue
	1: LdU64(999)
	2: Pack[1](A)
	3: Ret
}
entry public manipulate1() /* def_idx: 2 */ {
L0:	s2: Nested1
B0:
	0: LdU64(5)
	1: LdFalse
	2: Pack[4](Simple)
	3: LdU64(78)
	4: Pack[3](Nested1)
	5: StLoc[0](s2: Nested1)
	6: ImmBorrowLoc[0](s2: Nested1)
	7: ImmBorrowField[4](Nested1.a: Simple)
	8: ImmBorrowField[5](Simple.f: u64)
	9: ReadRef
	10: ImmBorrowLoc[0](s2: Nested1)
	11: ImmBorrowField[6](Nested1.b: u64)
	12: ReadRef
	13: Add
	14: MutBorrowLoc[0](s2: Nested1)
	15: MutBorrowField[4](Nested1.a: Simple)
	16: MutBorrowField[5](Simple.f: u64)
	17: WriteRef
	18: Ret
}
public manipulate2(): u64 /* def_idx: 3 */ {
L0:	s2: B
L1:	s1: A
L2:	s3: Nested
B0:
	0: LdTrue
	1: LdU64(18)
	2: Pack[1](A)
	3: LdFalse
	4: LdU64(77)
	5: Pack[0](B)
	6: Pack[2](Nested)
	7: StLoc[2](s3: Nested)
	8: ImmBorrowLoc[2](s3: Nested)
	9: ImmBorrowField[2](Nested.a: A)
	10: ImmBorrowField[0](A.b: u64)
	11: ReadRef
	12: ImmBorrowLoc[2](s3: Nested)
	13: ImmBorrowField[3](Nested.b: B)
	14: ImmBorrowField[1](B.b: u64)
	15: ReadRef
	16: Add
	17: Ret
}
}