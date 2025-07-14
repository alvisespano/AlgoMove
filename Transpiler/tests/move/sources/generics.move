module deploy_address::generics {
    
    struct MyStruct<T: drop + copy> has drop, copy {
        a: u64,
        b: T
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

    public entry fun main() {
        f(11);
        h(77, MyStruct<u8> { a: 11, b: 35 });
    }


}