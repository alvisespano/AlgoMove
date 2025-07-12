module algomove::generics {

    use algomove::asset::{ Self, Asset };
    use algomove::utils;
    
    struct S<T: drop> has drop {
        a: u64,
        b: T
    }

    public fun g<S: drop>(x: S) {
    }

    public fun f<T: drop>(x: T) {
        g(S<T> { a: 23, b: x})

	}

    public fun main() {
        f(11);
    }


}