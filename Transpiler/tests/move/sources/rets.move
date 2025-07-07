module deploy_address::rets {

    public fun no_ret(x: &mut u64, y: u64) {
        *x = y + 1
    }

    public fun ret(x: u64, y: u64): u64 {
        x + y
    }

}