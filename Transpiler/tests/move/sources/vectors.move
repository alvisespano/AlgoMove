module deploy_address::vectors {

    use 0x1::vector;

    public fun f(x: u64) {
        x = x + 1;
    }

    public fun creation() {
        let v = vector::empty<u64>();
        vector::push_back(&mut v, 10);
        vector::push_back(&mut v, 20);
 
        let length = vector::length(&v);
        assert!(length == 2, 0);
 
        let first_elem = vector::borrow(&v, 0);
        assert!(*first_elem == 10, 0);
 
        let second_elem = vector::borrow(&v, 1);
        assert!(*second_elem == 20, 0);
 
        let last_elem = vector::pop_back(&mut v);
        assert!(last_elem == 20, 0);
 
        vector::destroy_empty(v)
    }

    public fun creation_poly<T: drop>(x: T) {
        let v = vector::empty<T>();
        vector::push_back(&mut v, x);
        let _ = vector::pop_back(&mut v);
    }

    public fun access2d(v: vector<vector<u8>>): u8 {
        let w = vector<u8>[1, 2, 3, 4, 5, 6, 7];
        v[1][2] = v[11][23];
        (w[0] as u8) + v[11][23]
    }
}