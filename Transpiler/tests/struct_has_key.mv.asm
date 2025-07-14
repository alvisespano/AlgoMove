// Move bytecode v7
module aaaa.struct_has_key {
struct Nested1 has store, key {
	a: Simple,
	b: u64
}
struct Nested2<T: store> has key {
	a: T,
	b: u64
}
struct Nested3 has store, key {
	a: Simple,
	b: u64,
	c: Simple
}
struct Simple has copy, drop, store, key {
	f: u64,
	g: bool
}

entry public main(account: &signer) /* def_idx: 0 */ {
B0:
	0: CopyLoc[0](account: &signer)
	1: Call moveto2(&signer)
	2: MoveLoc[0](account: &signer)
	3: Call moveto2(&signer)
	4: Ret
}
public borrow1(account: address): u64 /* def_idx: 1 */ {
L1:	s1: &mut Simple
B0:
	0: MoveLoc[0](account: address)
	1: MutBorrowGlobal[3](Simple)
	2: StLoc[1](s1: &mut Simple)
	3: CopyLoc[1](s1: &mut Simple)
	4: ImmBorrowField[0](Simple.f: u64)
	5: ReadRef
	6: LdU64(2)
	7: Add
	8: CopyLoc[1](s1: &mut Simple)
	9: MutBorrowField[0](Simple.f: u64)
	10: WriteRef
	11: MoveLoc[1](s1: &mut Simple)
	12: ImmBorrowField[0](Simple.f: u64)
	13: ReadRef
	14: Ret
}
public borrow2(account: address): u64 /* def_idx: 2 */ {
L1:	u: &mut u64
B0:
	0: MoveLoc[0](account: address)
	1: MutBorrowGlobal[3](Simple)
	2: MutBorrowField[0](Simple.f: u64)
	3: StLoc[1](u: &mut u64)
	4: CopyLoc[1](u: &mut u64)
	5: ReadRef
	6: CopyLoc[1](u: &mut u64)
	7: WriteRef
	8: CopyLoc[1](u: &mut u64)
	9: ReadRef
	10: LdU64(2)
	11: Add
	12: CopyLoc[1](u: &mut u64)
	13: WriteRef
	14: MoveLoc[1](u: &mut u64)
	15: ReadRef
	16: Ret
}
public borrow3(account: address): u64 /* def_idx: 3 */ {
L1:	s1: &Nested3
L2:	n: u64
L3:	$t5: &u64
L4:	$t8: Simple
B0:
	0: MoveLoc[0](account: address)
	1: ImmBorrowGlobal[2](Nested3)
	2: StLoc[1](s1: &Nested3)
	3: CopyLoc[1](s1: &Nested3)
	4: ImmBorrowField[1](Nested3.a: Simple)
	5: MoveLoc[1](s1: &Nested3)
	6: ImmBorrowField[2](Nested3.b: u64)
	7: ReadRef
	8: StLoc[2](n: u64)
	9: ImmBorrowLoc[2](n: u64)
	10: StLoc[3]($t5: &u64)
	11: ReadRef
	12: StLoc[4]($t8: Simple)
	13: ImmBorrowLoc[4]($t8: Simple)
	14: ImmBorrowField[0](Simple.f: u64)
	15: ReadRef
	16: MoveLoc[3]($t5: &u64)
	17: ReadRef
	18: Add
	19: Ret
}
public borrow4(account: address) /* def_idx: 4 */ {
L1:	$t2: Simple
L2:	s1: &mut Simple
B0:
	0: MoveLoc[0](account: address)
	1: MutBorrowGlobal[3](Simple)
	2: LdU64(1)
	3: LdTrue
	4: Pack[3](Simple)
	5: StLoc[1]($t2: Simple)
	6: StLoc[2](s1: &mut Simple)
	7: MoveLoc[1]($t2: Simple)
	8: MoveLoc[2](s1: &mut Simple)
	9: WriteRef
	10: Ret
}
public borrow5(account: address): bool /* def_idx: 5 */ {
L1:	s2: &mut Nested1
L2:	s3: &mut Nested3
L3:	s4: &mut Nested2<Nested1>
L4:	$t18: bool
B0:
	0: CopyLoc[0](account: address)
	1: MutBorrowGlobal[3](Simple)
	2: CopyLoc[0](account: address)
	3: MutBorrowGlobal[0](Nested1)
	4: StLoc[1](s2: &mut Nested1)
	5: CopyLoc[0](account: address)
	6: MutBorrowGlobal[2](Nested3)
	7: StLoc[2](s3: &mut Nested3)
	8: MoveLoc[0](account: address)
	9: MutBorrowGlobalGeneric[0](Nested2<Nested1>)
	10: StLoc[3](s4: &mut Nested2<Nested1>)
	11: ImmBorrowField[0](Simple.f: u64)
	12: ReadRef
	13: MoveLoc[1](s2: &mut Nested1)
	14: ImmBorrowField[3](Nested1.b: u64)
	15: ReadRef
	16: Add
	17: MoveLoc[2](s3: &mut Nested3)
	18: ImmBorrowField[2](Nested3.b: u64)
	19: ReadRef
	20: Add
	21: MoveLoc[3](s4: &mut Nested2<Nested1>)
	22: ImmBorrowFieldGeneric[0](Nested2.a: T)
	23: ImmBorrowField[3](Nested1.b: u64)
	24: ReadRef
	25: Add
	26: LdU64(100)
	27: Lt
	28: BrFalse(33)
B1:
	29: LdTrue
	30: StLoc[4]($t18: bool)
B2:
	31: MoveLoc[4]($t18: bool)
	32: Ret
B3:
	33: LdFalse
	34: StLoc[4]($t18: bool)
	35: Branch(31)
}
public moveto1(account: signer, n: u64) /* def_idx: 6 */ {
B0:
	0: ImmBorrowLoc[0](account: signer)
	1: MoveLoc[1](n: u64)
	2: LdU64(39)
	3: Add
	4: LdTrue
	5: Pack[3](Simple)
	6: MoveTo[3](Simple)
	7: Ret
}
public moveto2(account: &signer) /* def_idx: 7 */ {
L1:	s1: Simple
L2:	s2: Nested1
B0:
	0: LdU64(5)
	1: LdFalse
	2: Pack[3](Simple)
	3: StLoc[1](s1: Simple)
	4: CopyLoc[1](s1: Simple)
	5: LdU64(78)
	6: Pack[0](Nested1)
	7: StLoc[2](s2: Nested1)
	8: CopyLoc[0](account: &signer)
	9: MoveLoc[1](s1: Simple)
	10: MoveTo[3](Simple)
	11: MoveLoc[0](account: &signer)
	12: MoveLoc[2](s2: Nested1)
	13: MoveTo[0](Nested1)
	14: Ret
}
public moveto3(account: &signer) /* def_idx: 8 */ {
L1:	s3: Nested2<Nested1>
B0:
	0: LdU64(5)
	1: LdFalse
	2: Pack[3](Simple)
	3: LdU64(34)
	4: Pack[0](Nested1)
	5: LdU64(9099)
	6: PackGeneric[0](Nested2<Nested1>)
	7: StLoc[1](s3: Nested2<Nested1>)
	8: MoveLoc[0](account: &signer)
	9: MoveLoc[1](s3: Nested2<Nested1>)
	10: MoveToGeneric[0](Nested2<Nested1>)
	11: Ret
}
public moveto4(account: &signer) /* def_idx: 9 */ {
L1:	s1: Simple
L2:	s2: Nested3
B0:
	0: LdU64(5)
	1: LdFalse
	2: Pack[3](Simple)
	3: StLoc[1](s1: Simple)
	4: CopyLoc[1](s1: Simple)
	5: LdU64(88)
	6: MoveLoc[1](s1: Simple)
	7: Pack[2](Nested3)
	8: StLoc[2](s2: Nested3)
	9: MoveLoc[0](account: &signer)
	10: MoveLoc[2](s2: Nested3)
	11: MoveTo[2](Nested3)
	12: Ret
}
}