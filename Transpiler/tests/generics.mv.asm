// Move bytecode v7
module aaaa.generics {
struct MyStruct<T: copy + drop> has copy, drop {
	a: u64,
	b: T
}
struct Pair<A: copy + drop, B: copy + drop> has copy, drop {
	fst: A,
	snd: B
}
struct Res<T: store> has key {
	a: u64,
	b: T
}

public f<T: copy + drop>(x: T): T /* def_idx: 0 */ {
B0:
	0: LdU64(23)
	1: MoveLoc[0](x: T)
	2: PackGeneric[0](MyStruct<T>)
	3: Call g<MyStruct<T>>(MyStruct<T>): MyStruct<T>
	4: UnpackGeneric[0](MyStruct<T>)
	5: StLoc[0](x: T)
	6: LdU64(1)
	7: Add
	8: Pop
	9: MoveLoc[0](x: T)
	10: Ret
}
public g<S: copy + drop>(x: S): S /* def_idx: 1 */ {
B0:
	0: MoveLoc[0](x: S)
	1: Ret
}
public h<T: copy + drop>(v: T, x: MyStruct<T>) /* def_idx: 2 */ {
L2:	$t2: &mut T
B0:
	0: MutBorrowLoc[1](x: MyStruct<T>)
	1: MutBorrowFieldGeneric[0](MyStruct.b: T)
	2: StLoc[2]($t2: &mut T)
	3: MoveLoc[0](v: T)
	4: MoveLoc[2]($t2: &mut T)
	5: WriteRef
	6: Ret
}
entry public main() /* def_idx: 3 */ {
B0:
	0: LdU64(11)
	1: Call f<u64>(u64): u64
	2: Pop
	3: LdU8(77)
	4: LdU64(11)
	5: LdU8(35)
	6: PackGeneric[1](MyStruct<u8>)
	7: Call h<u8>(u8, MyStruct<u8>)
	8: Ret
}
public borrow1<T: store>(a: address) /* def_idx: 4 */ {
L1:	x: &Res<T>
B0:
	0: MoveLoc[0](a: address)
	1: ImmBorrowGlobalGeneric[2](Res<T>)
	2: Pop
	3: Ret
}
public locals<A: copy + drop, B: copy + drop, C: copy + drop>(a: A, b: B, n: u64, c: C) /* def_idx: 5 */ {
L4:	x: Pair<B, B>
L5:	z: Pair<C, u64>
L6:	w: Pair<Pair<B, B>, Pair<C, u64>>
B0:
	0: CopyLoc[1](b: B)
	1: MoveLoc[1](b: B)
	2: PackGeneric[3](Pair<B, B>)
	3: StLoc[4](x: Pair<B, B>)
	4: CopyLoc[3](c: C)
	5: CopyLoc[2](n: u64)
	6: PackGeneric[4](Pair<C, u64>)
	7: StLoc[5](z: Pair<C, u64>)
	8: MoveLoc[2](n: u64)
	9: ImmBorrowLoc[5](z: Pair<C, u64>)
	10: ImmBorrowFieldGeneric[1](Pair.snd: B)
	11: ReadRef
	12: Add
	13: StLoc[2](n: u64)
	14: CopyLoc[4](x: Pair<B, B>)
	15: CopyLoc[5](z: Pair<C, u64>)
	16: PackGeneric[5](Pair<Pair<B, B>, Pair<C, u64>>)
	17: StLoc[6](w: Pair<Pair<B, B>, Pair<C, u64>>)
	18: ImmBorrowLoc[6](w: Pair<Pair<B, B>, Pair<C, u64>>)
	19: ImmBorrowFieldGeneric[2](Pair.fst: A)
	20: ImmBorrowFieldGeneric[3](Pair.fst: A)
	21: ReadRef
	22: MoveLoc[0](a: A)
	23: MoveLoc[3](c: C)
	24: PackGeneric[6](Pair<A, C>)
	25: Pop
	26: MoveLoc[2](n: u64)
	27: PackGeneric[7](Pair<B, u64>)
	28: Pop
	29: CopyLoc[4](x: Pair<B, B>)
	30: MoveLoc[4](x: Pair<B, B>)
	31: CopyLoc[6](w: Pair<Pair<B, B>, Pair<C, u64>>)
	32: MoveLoc[5](z: Pair<C, u64>)
	33: Call pairs<Pair<B, B>, Pair<Pair<B, B>, Pair<C, u64>>, Pair<C, u64>>(Pair<B, B>, Pair<B, B>, Pair<Pair<B, B>, Pair<C, u64>>, Pair<C, u64>): Pair<C, u64>
	34: Pop
	35: MoveLoc[6](w: Pair<Pair<B, B>, Pair<C, u64>>)
	36: Call g<Pair<Pair<B, B>, Pair<C, u64>>>(Pair<Pair<B, B>, Pair<C, u64>>): Pair<Pair<B, B>, Pair<C, u64>>
	37: Pop
	38: Ret
}
public pairs<A: copy + drop, B: copy + drop, C: copy + drop>(a1: A, a2: A, b: B, c: C): C /* def_idx: 6 */ {
B0:
	0: MoveLoc[3](c: C)
	1: Ret
}
}