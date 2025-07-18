module algomove::opcode {

	// transactions
	
	native public fun txn_Sender(): address;
	native public fun txn_CreatedAssetID(): u64;
	native public fun txn_NumAssets(): u64;
	native public fun txnas_Assets(i: u64): u64;
	
	// inner transactions

	native public fun itxn_begin();
	native public fun itxn_submit();
	// header fields
	native public fun itxn_field_Fee(x: u64);
	native public fun itxn_field_Type(x: vector<u8>);
	native public fun itxn_field_Sender(x: address);
	native public fun itxn_field_Receiver(x: address);
	native public fun itxn_field_GenesisID(x: vector<u8>);	// optional
	native public fun itxn_field_Amount(x: u64);
	// asset config and params
	native public fun itxn_field_Total(x: u64);
	native public fun itxn_field_Decimals(x: u64);
	native public fun itxn_field_DefaultFrozen(x: bool);
	native public fun itxn_field_UnitName(x: vector<u8>);	// optional
	native public fun itxn_field_Name(x: vector<u8>);	// optional
	// asset transfer
	native public fun itxn_field_XferAsset(x: u64);
	native public fun itxn_field_AssetAmount(x: u64);
	native public fun itxn_field_AssetSender(x: address);
	native public fun itxn_field_AssetReceiver(x: address);
	native public fun itxn_field_AssetCloseTo(x: address);	// optional

	// global instruction

	native public fun global_MinTxnFee(): u64;
	native public fun global_MinBalance(): u64;
	native public fun global_MaxTxnLife(): u64;
	native public fun global_GroupSize(): u64;
	native public fun global_CurrentApplicationAddress(): address;
	native public fun global_CurrentApplicationID(): u64;
	native public fun global_LatestTimestamp(): u64;

	// balance and assets

	native public fun balance(acc: address): u64;
	native public fun asset_holding_get_AssetBalance(addr: address, id: u64): u64;
	native public fun asset_holding_get_AssetFrozen(addr: address, id: u64): bool;
	native public fun asset_params_get_AssetName(id: u64): vector<u8>;

	// local state

	native public fun app_local_put<T: key>(addr: address, k: vector<u8>, data: T);
	native public fun app_local_put_bytes(addr: address, k: vector<u8>, data: vector<u8>);
	native public fun app_local_put_u64(addr: address, k: vector<u8>, data: u64);
	native public fun app_local_get<T: key>(addr: address, k: vector<u8>): T;
	native public fun app_local_get_bytes(addr: address, k: vector<u8>): vector<u8>;
	native public fun app_local_get_u64(addr: address, k: vector<u8>): u64;

	// global state

	native public fun app_global_put<T: key>(k: vector<u8>, data: T);
	native public fun app_global_put_bytes(k: vector<u8>, data: vector<u8>);
	native public fun app_global_put_u64(k: vector<u8>, data: u64);

	native public fun app_global_get<T: key>(k: vector<u8>): T;
	native public fun app_global_get_bytes(k: vector<u8>): vector<u8>;
	native public fun app_global_get_u64(k: vector<u8>): u64;

	// serialization

	public fun itob_bool(data: bool): vector<u8> {
		if (data) itob(1)
		else itob(0)
	}
	native public fun itob(data: u64): vector<u8>;

	public fun btoi_bool(data: vector<u8>): bool {
		btoi(data) == 1
	}
	native public fun btoi(data: vector<u8>): u64;

}