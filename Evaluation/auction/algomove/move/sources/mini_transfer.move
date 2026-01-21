module algomove::mini_transfer {

	use algomove::opcode as op;
	use algomove::utils;


	struct Asset<phantom T> has store {
		id: u64,
		amount: u64,
		owner: address
	}
	
	public fun deposit<T>(to: address, assets: Asset<T>) {
		let Asset { id, amount, owner:_ } = assets;	
		op::itxn_begin();
		op::itxn_field_Type(b"axfer");
		op::itxn_field_Sender(op::txn_Sender());
		op::itxn_field_XferAsset(id);
		op::itxn_field_AssetReceiver(to);
		op::itxn_field_AssetAmount(amount);
		op::itxn_submit();
	}

	public fun withdraw<T>(acc: &signer, amount: u64): Asset<T> {
		let id = utils::retrieve_asset_id<T>();
		let sender = utils::address_of_signer(acc);
		assert!(amount <= op::asset_holding_get_AssetBalance(sender, id), 1);
		let escrow = op::global_CurrentApplicationAddress();
		op::itxn_begin();
		op::itxn_field_Type(b"axfer");
		op::itxn_field_Sender(sender);
		op::itxn_field_XferAsset(id);
		op::itxn_field_AssetReceiver(escrow);
		op::itxn_field_AssetAmount(amount);
		op::itxn_submit();
		Asset<T> { id, amount, owner: escrow }
	}

    struct EUR {}

	public fun transfer(from: &signer, to: address, amount: u64) {
        let assets = withdraw<EUR>(from, amount);
        deposit(to, assets);
    }

}
