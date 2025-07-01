module algomove::utils {
    
    use algomove::opcode as op;
  	use std::string::{String};


    // misc stuff
    //

	public fun retrieve_asset_id<AssetType>(): u64 {
		let name = name_of<AssetType>();
		let len = op::txn_NumAssets();
		let i = 0;
		while (i < len) {
			let id = op::txnas_Assets(i);
			let s = op::asset_params_get_AssetName(id);
			if (s == name) return id;
			i = i + 1;
		};
		assert!(false, 0);
		0
	}

	// misc natives
	//

	native public fun name_of<T>(): String;
	native public fun address_of_signer(s: &signer) : address;
	native public fun bytes_of_address(a: address): vector<u8>;

}