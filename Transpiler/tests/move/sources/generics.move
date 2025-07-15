module deploy_address::generics {
    
    struct MyStruct<T: drop + copy> has drop, copy {
        a: u64,
        b: T
    }

    struct Res<T: store> has key {
        a: u64,
        b: T
    }

    struct Pair<A: copy + drop, B: copy + drop> has copy, drop {
        fst: A,
        snd: B
    }

    public fun g<S: drop + copy>(x: S): S {
        x
    }

    public fun f<T: drop + copy>(x: T): T {
        let MyStruct<T> { a:_a, b } = g(MyStruct<T> { a: 23, b: x });
        _a = _a + 1;
        b
	}

    public fun h<T: drop + copy>(v: T, x: MyStruct<T>) {
        x.b = v;
    }

    public fun borrow1<T: store>(a: address) acquires Res {
        let _x = borrow_global<Res<T>>(a);
    
    }

    public fun pairs<A: copy + drop, B: copy + drop, C: copy + drop>(_a1: A, a2: A, _b: B, c: C): C {
        _a1 = a2;
        c
    }

    public fun locals<A: copy + drop, B: copy + drop, C: copy + drop>(a: A, b: B, n: u64, c: C) {
        let x = Pair<B, B> { fst: b, snd: b };
        let z = Pair<C, u64> { fst: c, snd: n };
        let k2 = n + z.snd;
        let w = Pair<Pair<B, B>, Pair<C, u64>> { fst: x, snd: z };
        let k1 = w.fst.fst;
        let _y = Pair<A, C> { fst: a, snd: c };
        let _v = Pair<B, u64> { fst: k1, snd: k2 };
        let _ = pairs(x, x, w, z);
        let _ = g(w);
    }

    public entry fun main() {
        f(11);
        h(77, MyStruct<u8> { a: 11, b: 35 });
    }




}