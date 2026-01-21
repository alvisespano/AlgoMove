// Move bytecode v9
module aaa.mini_transfer {
use 0000000000000000000000000000000000000000000000000000000000000aaa::opcode;
use 0000000000000000000000000000000000000000000000000000000000000aaa::utils;


struct Asset<phantom T> has store {
	id: u64,
	amount: u64,
	owner: address
}
struct EUR {
	dummy_field: bool
}

public transfer(from: &signer, to: address, amount: u64) /* def_idx: 0 */ {
L3:	assets: Asset<EUR>
B0:
	0: MoveLoc[0](from: &signer)
	1: MoveLoc[2](amount: u64)
	2: Call withdraw<EUR>(&signer, u64): Asset<EUR>
	3: StLoc[3](assets: Asset<EUR>)
	4: MoveLoc[1](to: address)
	5: MoveLoc[3](assets: Asset<EUR>)
	6: Call deposit<EUR>(address, Asset<EUR>)
	7: Ret
}
public deposit<T>(to: address, assets: Asset<T>) /* def_idx: 1 */ {
L2:	amount: u64
B0:
	0: MoveLoc[1](assets: Asset<T>)
	1: UnpackGeneric[0](Asset<T>)
	2: Pop
	3: StLoc[2](amount: u64)
	4: Call opcode::itxn_begin()
	5: LdConst[0](Vector(U8): [5, 97, 120, 102, 101, 114])
	6: Call opcode::itxn_field_Type(vector<u8>)
	7: Call opcode::txn_Sender(): address
	8: Call opcode::itxn_field_Sender(address)
	9: Call opcode::itxn_field_XferAsset(u64)
	10: MoveLoc[0](to: address)
	11: Call opcode::itxn_field_AssetReceiver(address)
	12: MoveLoc[2](amount: u64)
	13: Call opcode::itxn_field_AssetAmount(u64)
	14: Call opcode::itxn_submit()
	15: Ret
}
public withdraw<T>(acc: &signer, amount: u64): Asset<T> /* def_idx: 2 */ {
L2:	id: u64
L3:	sender: address
L4:	$t8: address
B0:
	0: Call utils::retrieve_asset_id<T>(): u64
	1: StLoc[2](id: u64)
	2: MoveLoc[0](acc: &signer)
	3: Call utils::address_of_signer(&signer): address
	4: StLoc[3](sender: address)
	5: CopyLoc[1](amount: u64)
	6: CopyLoc[3](sender: address)
	7: CopyLoc[2](id: u64)
	8: Call opcode::asset_holding_get_AssetBalance(address, u64): u64
	9: Le
	10: BrFalse(30)
B1:
	11: Call opcode::global_CurrentApplicationAddress(): address
	12: StLoc[4]($t8: address)
	13: Call opcode::itxn_begin()
	14: LdConst[0](Vector(U8): [5, 97, 120, 102, 101, 114])
	15: Call opcode::itxn_field_Type(vector<u8>)
	16: MoveLoc[3](sender: address)
	17: Call opcode::itxn_field_Sender(address)
	18: CopyLoc[2](id: u64)
	19: Call opcode::itxn_field_XferAsset(u64)
	20: CopyLoc[4]($t8: address)
	21: Call opcode::itxn_field_AssetReceiver(address)
	22: CopyLoc[1](amount: u64)
	23: Call opcode::itxn_field_AssetAmount(u64)
	24: Call opcode::itxn_submit()
	25: MoveLoc[2](id: u64)
	26: MoveLoc[1](amount: u64)
	27: MoveLoc[4]($t8: address)
	28: PackGeneric[0](Asset<T>)
	29: Ret
B2:
	30: LdU64(1)
	31: Abort
}
}