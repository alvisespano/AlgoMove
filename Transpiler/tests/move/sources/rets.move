module deploy_address::rets {

    struct MyStruct<T> {
        a: u64,
        b: T
    }

    public fun no_ret(x: &mut u64, y: u64) {
        *x = y + 1
    }

    public fun ret(x: u64, y: u64): u64 {
        x + y
    }

    public fun triple<T>(x: u64, y: T): (u64, bool, MyStruct<T>) {
        (x, x > 0, MyStruct<T> { a: x, b: y })
    }

    public entry fun main(acc: &signer) {
        let (x, y, MyStruct { a, b }) = triple(11, true);
        if (y && b) {
            x = a + x;
        }
    }



}