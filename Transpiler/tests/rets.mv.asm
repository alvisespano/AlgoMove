// Move bytecode v7
module aaaa.rets {
struct MyStruct<T> {
	a: u64,
	b: T
}

public ret(x: u64, y: u64): u64 /* def_idx: 0 */ {
B0:
	0: MoveLoc[0](x: u64)
	1: MoveLoc[1](y: u64)
	2: Add
	3: Ret
}
entry public main(acc: &signer) /* def_idx: 1 */ {
L1:	b: bool
L2:	$t7: bool
B0:
	0: LdU64(11)
	1: MoveLoc[0](acc: &signer)
	2: Pop
	3: LdTrue
	4: Call triple<bool>(u64, bool): u64 * bool * MyStruct<bool>
	5: UnpackGeneric[0](MyStruct<bool>)
	6: StLoc[1](b: bool)
	7: Pop
	8: StLoc[2]($t7: bool)
	9: Pop
	10: MoveLoc[2]($t7: bool)
	11: BrFalse(18)
B1:
	12: MoveLoc[1](b: bool)
	13: StLoc[2]($t7: bool)
B2:
	14: MoveLoc[2]($t7: bool)
	15: BrTrue(17)
B3:
	16: Branch(17)
B4:
	17: Ret
B5:
	18: LdFalse
	19: StLoc[2]($t7: bool)
	20: Branch(14)
}
public no_ret(x: &mut u64, y: u64) /* def_idx: 2 */ {
B0:
	0: MoveLoc[1](y: u64)
	1: LdU64(1)
	2: Add
	3: MoveLoc[0](x: &mut u64)
	4: WriteRef
	5: Ret
}
public triple<T>(x: u64, y: T): u64 * bool * MyStruct<T> /* def_idx: 3 */ {
B0:
	0: CopyLoc[0](x: u64)
	1: CopyLoc[0](x: u64)
	2: LdU64(0)
	3: Gt
	4: MoveLoc[0](x: u64)
	5: MoveLoc[1](y: T)
	6: PackGeneric[1](MyStruct<T>)
	7: Ret
}
}