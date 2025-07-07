// Move bytecode v7
module aaa.utils {
use 0000000000000000000000000000000000000000000000000000000000000001::string;
use 0000000000000000000000000000000000000000000000000000000000000aaa::opcode;




native public address_of_signer(s: &signer): address /* def_idx: 0 */
native public bytes_of_address(a: address): vector<u8> /* def_idx: 1 */
native public name_of<T>(): String /* def_idx: 2 */
public retrieve_asset_id<AssetType>(): u64 /* def_idx: 3 */ {
L0:	name: String
L1:	len: u64
L2:	i: u64
L3:	$t5: u64
B0:
	0: Call name_of<AssetType>(): String
	1: StLoc[0](name: String)
	2: Call opcode::txn_NumAssets(): u64
	3: StLoc[1](len: u64)
	4: LdU64(0)
	5: StLoc[2](i: u64)
B1:
	6: CopyLoc[2](i: u64)
	7: CopyLoc[1](len: u64)
	8: Lt
	9: BrFalse(25)
B2:
	10: CopyLoc[2](i: u64)
	11: Call opcode::txnas_Assets(u64): u64
	12: StLoc[3]($t5: u64)
	13: CopyLoc[3]($t5: u64)
	14: Call opcode::asset_params_get_AssetName(u64): String
	15: CopyLoc[0](name: String)
	16: Eq
	17: BrFalse(20)
B3:
	18: MoveLoc[3]($t5: u64)
	19: Ret
B4:
	20: MoveLoc[2](i: u64)
	21: LdU64(1)
	22: Add
	23: StLoc[2](i: u64)
	24: Branch(6)
B5:
	25: Branch(28)
B6:
	26: LdU64(0)
	27: Ret
B7:
	28: LdU64(0)
	29: Abort
}
}