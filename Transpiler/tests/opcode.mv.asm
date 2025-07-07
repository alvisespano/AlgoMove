// Move bytecode v7
module aaa.opcode {
use 0000000000000000000000000000000000000000000000000000000000000001::string;




native public balance(acc: address): u64 /* def_idx: 0 */
native public app_global_get<T: key>(k: vector<u8>): T /* def_idx: 1 */
native public app_global_get_bytes(k: vector<u8>): vector<u8> /* def_idx: 2 */
native public app_global_get_u64(k: vector<u8>): u64 /* def_idx: 3 */
native public app_global_put<T: key>(k: vector<u8>, data: T) /* def_idx: 4 */
native public app_global_put_bytes(k: vector<u8>, data: vector<u8>) /* def_idx: 5 */
native public app_global_put_u64(k: vector<u8>, data: u64) /* def_idx: 6 */
native public app_local_get<T: key>(addr: address, k: vector<u8>): T /* def_idx: 7 */
native public app_local_get_bytes(addr: address, k: vector<u8>): vector<u8> /* def_idx: 8 */
native public app_local_get_u64(addr: address, k: vector<u8>): u64 /* def_idx: 9 */
native public app_local_put<T: key>(addr: address, k: vector<u8>, data: T) /* def_idx: 10 */
native public app_local_put_bytes(addr: address, k: vector<u8>, data: vector<u8>) /* def_idx: 11 */
native public app_local_put_u64(addr: address, k: vector<u8>, data: u64) /* def_idx: 12 */
native public asset_holding_get_AssetBalance(addr: address, id: u64): u64 /* def_idx: 13 */
native public asset_holding_get_AssetFrozen(addr: address, id: u64): bool /* def_idx: 14 */
native public asset_params_get_AssetName(id: u64): String /* def_idx: 15 */
native public btoi(data: vector<u8>): u64 /* def_idx: 16 */
public btoi_bool(data: vector<u8>): bool /* def_idx: 17 */ {
B0:
	0: MoveLoc[0](data: vector<u8>)
	1: Call btoi(vector<u8>): u64
	2: LdU64(1)
	3: Eq
	4: Ret
}
native public global_CurrentApplicationAddress(): address /* def_idx: 18 */
native public global_CurrentApplicationID(): u64 /* def_idx: 19 */
native public global_GroupSize(): u64 /* def_idx: 20 */
native public global_LatestTimestamp(): u64 /* def_idx: 21 */
native public global_MaxTxnLife(): u64 /* def_idx: 22 */
native public global_MinBalance(): u64 /* def_idx: 23 */
native public global_MinTxnFee(): u64 /* def_idx: 24 */
native public itob(data: u64): vector<u8> /* def_idx: 25 */
public itob_bool(data: bool): vector<u8> /* def_idx: 26 */ {
L1:	return: vector<u8>
B0:
	0: MoveLoc[0](data: bool)
	1: BrFalse(7)
B1:
	2: LdU64(1)
	3: Call itob(u64): vector<u8>
	4: StLoc[1](return: vector<u8>)
B2:
	5: MoveLoc[1](return: vector<u8>)
	6: Ret
B3:
	7: LdU64(0)
	8: Call itob(u64): vector<u8>
	9: StLoc[1](return: vector<u8>)
	10: Branch(5)
}
native public itxn_begin() /* def_idx: 27 */
native public itxn_field_Amount(x: u64) /* def_idx: 28 */
native public itxn_field_AssetAmount(x: u64) /* def_idx: 29 */
native public itxn_field_AssetCloseTo(x: address) /* def_idx: 30 */
native public itxn_field_AssetReceiver(x: address) /* def_idx: 31 */
native public itxn_field_AssetSender(x: address) /* def_idx: 32 */
native public itxn_field_Decimals(x: u64) /* def_idx: 33 */
native public itxn_field_DefaultFrozen(x: bool) /* def_idx: 34 */
native public itxn_field_Fee(x: u64) /* def_idx: 35 */
native public itxn_field_GenesisID(x: String) /* def_idx: 36 */
native public itxn_field_Name(x: String) /* def_idx: 37 */
native public itxn_field_Receiver(x: address) /* def_idx: 38 */
native public itxn_field_Sender(x: address) /* def_idx: 39 */
native public itxn_field_Total(x: u64) /* def_idx: 40 */
native public itxn_field_Type(x: String) /* def_idx: 41 */
native public itxn_field_UnitName(x: String) /* def_idx: 42 */
native public itxn_field_XferAsset(x: u64) /* def_idx: 43 */
native public itxn_submit() /* def_idx: 44 */
native public txn_CreatedAssetID(): u64 /* def_idx: 45 */
native public txn_NumAssets(): u64 /* def_idx: 46 */
native public txn_Sender(): address /* def_idx: 47 */
native public txnas_Assets(i: u64): u64 /* def_idx: 48 */
}