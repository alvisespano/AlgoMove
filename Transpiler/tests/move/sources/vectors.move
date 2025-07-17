module deploy_address::vectors {

    public fun f(x: u64) {
        x = x + 1;
    }

    public fun access(x: u64, v: vector<u64>): u64 {
        f(v[x]);
        v[x] + v[9]
    }

    public fun access2d(v: vector<vector<u8>>): u8 {
        let w = vector<u8>[1, 2, 3, 4, 5, 6, 7];
        (w[0] as u8) + v[11][23]
    }
}