// Move bytecode v7
module aaa.asset {
use 0000000000000000000000000000000000000000000000000000000000000aaa::utils;
use 0000000000000000000000000000000000000000000000000000000000000aaa::transaction;
use 0000000000000000000000000000000000000000000000000000000000000aaa::opcode;


struct Asset<phantom AssetType> has store {
	id: u64,
	amount: u64,
	owner: address
}

public value<AssetType>(asset: &Asset<AssetType>): u64 /* def_idx: 0 */ {
B0:
	0: MoveLoc[0](asset: &Asset<AssetType>)
	1: ImmBorrowFieldGeneric[0](Asset.amount: u64)
	2: ReadRef
	3: Ret
}
public create<AssetType>(acc: &signer, total: u64, decimals: u64, default_frozen: bool, short_name: vector<u8>): Asset<AssetType> /* def_idx: 1 */ {
L5:	sender: address
L6:	name: vector<u8>
B0:
	0: MoveLoc[0](acc: &signer)
	1: Call utils::address_of_signer(&signer): address
	2: StLoc[5](sender: address)
	3: Call utils::name_of<AssetType>(): vector<u8>
	4: StLoc[6](name: vector<u8>)
	5: CopyLoc[5](sender: address)
	6: CopyLoc[1](total: u64)
	7: MoveLoc[2](decimals: u64)
	8: MoveLoc[3](default_frozen: bool)
	9: MoveLoc[6](name: vector<u8>)
	10: MoveLoc[4](short_name: vector<u8>)
	11: Call transaction::asset_config(address, u64, u64, bool, vector<u8>, vector<u8>)
	12: Call opcode::txn_CreatedAssetID(): u64
	13: MoveLoc[1](total: u64)
	14: MoveLoc[5](sender: address)
	15: PackGeneric[0](Asset<AssetType>)
	16: Ret
}
public transfer<AssetType>(from: &signer, to: address, amount: u64) /* def_idx: 2 */ {
L3:	assets: Asset<AssetType>
B0:
	0: MoveLoc[0](from: &signer)
	1: MoveLoc[2](amount: u64)
	2: Call withdraw<AssetType>(&signer, u64): Asset<AssetType>
	3: StLoc[3](assets: Asset<AssetType>)
	4: MoveLoc[1](to: address)
	5: MoveLoc[3](assets: Asset<AssetType>)
	6: Call deposit<AssetType>(address, Asset<AssetType>)
	7: Ret
}
public deposit<AssetType>(receiver: address, assets: Asset<AssetType>) /* def_idx: 3 */ {
L2:	amount: u64
L3:	id: u64
B0:
	0: MoveLoc[1](assets: Asset<AssetType>)
	1: UnpackGeneric[0](Asset<AssetType>)
	2: Pop
	3: StLoc[2](amount: u64)
	4: StLoc[3](id: u64)
	5: Call opcode::txn_Sender(): address
	6: MoveLoc[3](id: u64)
	7: MoveLoc[2](amount: u64)
	8: MoveLoc[0](receiver: address)
	9: Call transaction::asset_transfer(address, u64, u64, address)
	10: Ret
}
public withdraw<AssetType>(acc: &signer, amount: u64): Asset<AssetType> /* def_idx: 4 */ {
L2:	id: u64
L3:	sender: address
L4:	$t8: address
B0:
	0: Call utils::retrieve_asset_id<AssetType>(): u64
	1: StLoc[2](id: u64)
	2: MoveLoc[0](acc: &signer)
	3: Call utils::address_of_signer(&signer): address
	4: StLoc[3](sender: address)
	5: CopyLoc[1](amount: u64)
	6: CopyLoc[3](sender: address)
	7: CopyLoc[2](id: u64)
	8: Call opcode::asset_holding_get_AssetBalance(address, u64): u64
	9: Le
	10: BrFalse(23)
B1:
	11: Call opcode::global_CurrentApplicationAddress(): address
	12: StLoc[4]($t8: address)
	13: MoveLoc[3](sender: address)
	14: CopyLoc[2](id: u64)
	15: CopyLoc[1](amount: u64)
	16: CopyLoc[4]($t8: address)
	17: Call transaction::asset_transfer(address, u64, u64, address)
	18: MoveLoc[2](id: u64)
	19: MoveLoc[1](amount: u64)
	20: MoveLoc[4]($t8: address)
	21: PackGeneric[0](Asset<AssetType>)
	22: Ret
B2:
	23: LdU64(1)
	24: Abort
}
public split<AssetType>(assets: Asset<AssetType>, amt: u64): Asset<AssetType> * Asset<AssetType> /* def_idx: 5 */ {
L2:	owner: address
L3:	old_amount: u64
L4:	id: u64
L5:	old: Asset<AssetType>
B0:
	0: MoveLoc[0](assets: Asset<AssetType>)
	1: UnpackGeneric[0](Asset<AssetType>)
	2: StLoc[2](owner: address)
	3: StLoc[3](old_amount: u64)
	4: StLoc[4](id: u64)
	5: CopyLoc[4](id: u64)
	6: CopyLoc[3](old_amount: u64)
	7: MoveLoc[1](amt: u64)
	8: Sub
	9: CopyLoc[2](owner: address)
	10: PackGeneric[0](Asset<AssetType>)
	11: MoveLoc[4](id: u64)
	12: MoveLoc[3](old_amount: u64)
	13: MoveLoc[2](owner: address)
	14: PackGeneric[0](Asset<AssetType>)
	15: Ret
}
}