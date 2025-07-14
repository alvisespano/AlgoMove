// Move bytecode v7
module aaaa.generics {
struct MyStruct<T: copy + drop> has copy, drop {
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
}