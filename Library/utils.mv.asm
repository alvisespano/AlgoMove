// Move bytecode v9
module aaa.utils {
use 0000000000000000000000000000000000000000000000000000000000000aaa::opcode;




native public address_of_signer(s: &signer): address /* def_idx: 0 */
native public bytes_of_address(a: address): vector<u8> /* def_idx: 1 */
native public name_of<T>(): vector<u8> /* def_idx: 2 */
public retrieve_asset_id<AssetType>(): u64 /* def_idx: 3 */ {
L0:	name: vector<u8>
L1:	id: u64
L2:	$t5: u64
L3:	$t9: u64
B0:
	0: Call name_of<AssetType>(): vector<u8>
	1: StLoc[0](name: vector<u8>)
	2: CopyLoc[0](name: vector<u8>)
	3: Call opcode::app_global_get<u64>(vector<u8>): u64
	4: StLoc[1](id: u64)
	5: CopyLoc[1](id: u64)
	6: LdU64(0)
	7: Neq
	8: BrFalse(11)
B1:
	9: MoveLoc[1](id: u64)
	10: Ret
B2:
	11: Call opcode::txn_NumAssets(): u64
	12: StLoc[1](id: u64)
	13: LdU64(0)
	14: StLoc[2]($t5: u64)
B3:
	15: CopyLoc[2]($t5: u64)
	16: CopyLoc[1](id: u64)
	17: Lt
	18: BrFalse(34)
B4:
	19: CopyLoc[2]($t5: u64)
	20: Call opcode::txnas_Assets(u64): u64
	21: StLoc[3]($t9: u64)
	22: CopyLoc[3]($t9: u64)
	23: Call opcode::asset_params_get_AssetName(u64): vector<u8>
	24: CopyLoc[0](name: vector<u8>)
	25: Eq
	26: BrFalse(29)
B5:
	27: MoveLoc[3]($t9: u64)
	28: Ret
B6:
	29: MoveLoc[2]($t5: u64)
	30: LdU64(1)
	31: Add
	32: StLoc[2]($t5: u64)
	33: Branch(15)
B7:
	34: Branch(37)
B8:
	35: LdU64(0)
	36: Ret
B9:
	37: LdU64(0)
	38: Abort
}
}