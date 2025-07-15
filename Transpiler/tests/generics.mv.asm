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
public locals<A: copy + drop, B: copy + drop, C: copy + drop>(a: A, b: B, n: u64, c: C): C /* def_idx: 5 */ {
L4:	z: Pair<C, u64>
L5:	w: Pair<Pair<B, B>, Pair<C, u64>>
B0:
	0: CopyLoc[1](b: B)
	1: MoveLoc[1](b: B)
	2: PackGeneric[3](Pair<B, B>)
	3: CopyLoc[3](c: C)
	4: CopyLoc[2](n: u64)
	5: PackGeneric[4](Pair<C, u64>)
	6: StLoc[4](z: Pair<C, u64>)
	7: MoveLoc[2](n: u64)
	8: ImmBorrowLoc[4](z: Pair<C, u64>)
	9: ImmBorrowFieldGeneric[1](Pair.snd: B)
	10: ReadRef
	11: Add
	12: StLoc[2](n: u64)
	13: MoveLoc[4](z: Pair<C, u64>)
	14: PackGeneric[5](Pair<Pair<B, B>, Pair<C, u64>>)
	15: StLoc[5](w: Pair<Pair<B, B>, Pair<C, u64>>)
	16: ImmBorrowLoc[5](w: Pair<Pair<B, B>, Pair<C, u64>>)
	17: ImmBorrowFieldGeneric[2](Pair.fst: A)
	18: ImmBorrowFieldGeneric[3](Pair.fst: A)
	19: ReadRef
	20: MoveLoc[0](a: A)
	21: MoveLoc[3](c: C)
	22: PackGeneric[6](Pair<A, C>)
	23: Pop
	24: MoveLoc[2](n: u64)
	25: PackGeneric[7](Pair<B, u64>)
	26: Pop
	27: ImmBorrowLoc[5](w: Pair<Pair<B, B>, Pair<C, u64>>)
	28: ImmBorrowFieldGeneric[4](Pair.snd: B)
	29: ImmBorrowFieldGeneric[5](Pair.fst: A)
	30: ReadRef
	31: Ret
}
}