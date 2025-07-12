// Move bytecode v7
module aaa.generics {
struct S<T: drop> has drop {
	a: u64,
	b: T
}

public f<T: drop>(x: T) /* def_idx: 0 */ {
B0:
	0: LdU64(23)
	1: MoveLoc[0](x: T)
	2: PackGeneric[0](S<T>)
	3: Call g<S<T>>(S<T>)
	4: Ret
}
public g<S: drop>(x: S) /* def_idx: 1 */ {
B0:
	0: Ret
}
public main() /* def_idx: 2 */ {
B0:
	0: LdU64(11)
	1: Call f<u64>(u64)
	2: Ret
}
}