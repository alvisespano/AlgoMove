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
        let MyStruct<T> { a, b } = g(MyStruct<T> { a: 23, b: x });
        a = a + 1;
        b
	}

    public fun h<T: drop + copy>(v: T, x: MyStruct<T>) {
        x.b = v;
    }

    public fun borrow1<T: store>(a: address) acquires Res {
        let x = borrow_global<Res<T>>(a);
    
    }

    public fun locals<A: copy + drop, B: copy + drop, C: copy + drop>(a: A, b: B, n: u64, c: C): C {
        let x = Pair<B, B> { fst: b, snd: b };
        let z = Pair<C, u64> { fst: c, snd: n };
        let k2 = n + z.snd;
        let w = Pair<Pair<B, B>, Pair<C, u64>> { fst: x, snd: z };
        let k1 = w.fst.fst;
        let y = Pair<A, C> { fst: a, snd: c };
        let v = Pair<B, u64> { fst: k1, snd: k2 };
        w.snd.fst        
    }

    public entry fun main() {
        f(11);
        h(77, MyStruct<u8> { a: 11, b: 35 });
    }




}