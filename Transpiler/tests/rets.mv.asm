// Move bytecode v7
module aaaa.rets {


public ret(x: u64, y: u64): u64 /* def_idx: 0 */ {
B0:
	0: MoveLoc[0](x: u64)
	1: MoveLoc[1](y: u64)
	2: Add
	3: Ret
}
public no_ret(x: &mut u64, y: u64) /* def_idx: 1 */ {
B0:
	0: MoveLoc[1](y: u64)
	1: LdU64(1)
	2: Add
	3: MoveLoc[0](x: &mut u64)
	4: WriteRef
	5: Ret
}
}