// Move bytecode v7
module aaa.transaction {
use 0000000000000000000000000000000000000000000000000000000000000aaa::opcode;




public asset_config(sender: address, total: u64, decimals: u64, default_frozen: bool, name: vector<u8>, short_name: vector<u8>) /* def_idx: 0 */ {
B0:
	0: MoveLoc[0](sender: address)
	1: MoveLoc[1](total: u64)
	2: MoveLoc[2](decimals: u64)
	3: MoveLoc[3](default_frozen: bool)
	4: MoveLoc[4](name: vector<u8>)
	5: MoveLoc[5](short_name: vector<u8>)
	6: Call init_asset_config(address, u64, u64, bool, vector<u8>, vector<u8>)
	7: Call opcode::itxn_submit()
	8: Ret
}
public asset_optin(sender: address, id: u64, receiver: address) /* def_idx: 1 */ {
B0:
	0: MoveLoc[0](sender: address)
	1: MoveLoc[1](id: u64)
	2: MoveLoc[2](receiver: address)
	3: Call init_asset_transfer(address, u64, address)
	4: Call opcode::itxn_submit()
	5: Ret
}
public asset_transfer(sender: address, id: u64, amount: u64, receiver: address) /* def_idx: 2 */ {
B0:
	0: MoveLoc[0](sender: address)
	1: MoveLoc[1](id: u64)
	2: MoveLoc[3](receiver: address)
	3: Call init_asset_transfer(address, u64, address)
	4: LdConst[0](Address: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	5: Call opcode::itxn_field_AssetSender(address)
	6: MoveLoc[2](amount: u64)
	7: Call opcode::itxn_field_AssetAmount(u64)
	8: Call opcode::itxn_submit()
	9: Ret
}
public init_asset_config(sender: address, total: u64, decimals: u64, default_frozen: bool, name: vector<u8>, short_name: vector<u8>) /* def_idx: 3 */ {
B0:
	0: MoveLoc[0](sender: address)
	1: LdU64(100)
	2: LdConst[1](Vector(U8): [4, 97, 99, 102, 103])
	3: Call init_header(address, u64, vector<u8>)
	4: MoveLoc[1](total: u64)
	5: Call opcode::itxn_field_Total(u64)
	6: MoveLoc[2](decimals: u64)
	7: Call opcode::itxn_field_Decimals(u64)
	8: MoveLoc[3](default_frozen: bool)
	9: Call opcode::itxn_field_DefaultFrozen(bool)
	10: MoveLoc[4](name: vector<u8>)
	11: Call opcode::itxn_field_Name(vector<u8>)
	12: MoveLoc[5](short_name: vector<u8>)
	13: Call opcode::itxn_field_UnitName(vector<u8>)
	14: Ret
}
public init_asset_transfer(sender: address, id: u64, receiver: address) /* def_idx: 4 */ {
B0:
	0: MoveLoc[0](sender: address)
	1: LdU64(100)
	2: LdConst[2](Vector(U8): [5, 97, 120, 102, 101, 114])
	3: Call init_header(address, u64, vector<u8>)
	4: MoveLoc[1](id: u64)
	5: Call opcode::itxn_field_XferAsset(u64)
	6: MoveLoc[2](receiver: address)
	7: Call opcode::itxn_field_AssetReceiver(address)
	8: Ret
}
public init_header(sender: address, fee: u64, ty: vector<u8>) /* def_idx: 5 */ {
B0:
	0: Call opcode::itxn_begin()
	1: MoveLoc[1](fee: u64)
	2: Call opcode::itxn_field_Fee(u64)
	3: MoveLoc[2](ty: vector<u8>)
	4: Call opcode::itxn_field_Type(vector<u8>)
	5: MoveLoc[0](sender: address)
	6: Call opcode::itxn_field_Sender(address)
	7: Ret
}
public init_pay(sender: address, receiver: address, amount: u64) /* def_idx: 6 */ {
B0:
	0: MoveLoc[0](sender: address)
	1: LdU64(100)
	2: LdConst[3](Vector(U8): [3, 112, 97, 121])
	3: Call init_header(address, u64, vector<u8>)
	4: MoveLoc[1](receiver: address)
	5: Call opcode::itxn_field_Receiver(address)
	6: MoveLoc[2](amount: u64)
	7: Call opcode::itxn_field_Amount(u64)
	8: Ret
}
public pay(sender: address, receiver: address, amount: u64) /* def_idx: 7 */ {
B0:
	0: MoveLoc[0](sender: address)
	1: MoveLoc[1](receiver: address)
	2: MoveLoc[2](amount: u64)
	3: Call init_pay(address, address, u64)
	4: Call opcode::itxn_submit()
	5: Ret
}
}