module AlgoMove.Transpiler.RuntimeLib

let header_dispatcher = """
#pragma version 11

	txn NumApplicationArgs
	int 0
	>
	bnz startup.dispatcher
	err
"""

let header_no_dispatcher = """
#pragma version 11

"""

let epilogue = """
//
// ---- AlgoMove Runtime Library ----
//

PackField:	// assumes: 255 = counter, 254 = #field - 1
	proto 1 1
	frame_dig -1
    len
    dup
    load 255
    dup
    uncover 1
    +
    store 255
    itob
    extract 6 2    // lowest 16 bits
    swap
    itob
    extract 6 2
    swap
    concat 
    load 254
    pushint 1
    -
    pushint 0
    ==
	frame_bury 0
	retsub

PackTyParam:
	proto 1 1
	frame_dig -1
	pushint 7
	getbit
	pushint 1
	==
	bz PackTyParam.exit
	itob
PackTyParam.exit:
	frame_bury 0
	retsub

UnpackTyParam:
	proto 1 1
	frame_dig -1
	pushint 7
	getbit
	pushint 1
	==
	bz UnpackTyParam.exit
	btoi
UnpackTyParam.exit:
	frame_bury 0
	retsub


/////////////////////////////////

Deref:
	proto 0 0
	load 255
	extract 0 1		// get kind of ref
	btoi
	switch Deref.k0 Deref.k1

// kind 0x00: local
Deref.k0: 
	load 255
	extract 1 1		// get scratch space slot 
	btoi	
	loads			// read dereferenced data
	load 255
	pushint 2		// path offset
	b Deref.setup_path

// kind 0x01: global
Deref.k1:	
	load 255
	dup
	extract 2 32	// address
	swap
	extract 1 1		// key 
	app_local_get	// read dereferenced data
	load 255
	pushint 34		// path offset

// stack: offset, whole reference, dereferenced data 
Deref.setup_path:
	pushint 0
	extract3
	store 252		// 252 = path part
	len				
	store 254		// 254 = path size
	store 251		// 251 = dereferenced data

	pushint 0
	load 250		// 250 = index (loop increment)
	retsub


Deref.consume_path:
	proto 0 0
	load 252
	load 250
	pushint 1
	extract3				// extract field index
    pushint 4
	*
	load 251
	swap
	pushint 4
    extract3				// extract (offset, len) from data header
	dup
	extract 0 2
	dup
	store 253				// 253 = offset as []byte without clearing bit 15 (saved for later)
	pushbytes 0x7fff		// clear bit 15
	b&
	btoi					
	store 249				// 249 = offset as uint64

	pushint 2
	extract_uint16
	store 248				// 248 = len
	
	load 251
	load 249
	load 248
	extract3				
	store 251				// 251 = sliced data
	retsub

/////////////////////////////////


ReadRef:
	proto 1 1	
	frame_dig -1
	store 255		// 255 = whole reference (arg1)

	callsub Deref

ReadRef.consume_path_loop:
	load 250
	load 254
	>=
	bnz ReadRef.consume_path_quit

	callsub Deref.consume_path

	load 250
	pushint 1
	+
	store 250				// increment index
	b ReadRef.consume_path_loop
ReadRef.consume_path_quit:

// stack: []
ReadRef.deserialize:
	load 253				
	pushbytes 0x8000		// mask bit 15
	b&
	bz ReadRef.exit
	load 251
	btoi					// deserialize if bit 15 is set
ReadRef.exit:
	frame_bury 0
	retsub




WriteRef:
	proto 2 0
	frame_dig -2
	store 255		 // 255 = whole reference (arg1)
	frame_dig -1
	store 247		 // 247 = right value (arg2)

	callsub Deref
	// 251 = dereferenced data
	// 250 = index (loop increment)
	// 252 = path part
	// 254 = path size

	pushint 0
	store 246	// 246 = offset accumulator
WriteRef.consume_path_loop:
	load 250
	load 254
	>=
	bnz WriteRef.consume_path_quit

	callsub Deref.consume_path
	// 248 = len
	// 249 = offset as uint64
	// 251 = sliced data
	// 253 = offset as []byte without clearing bit 15 (saved for later)

	load 249
	load 246
	+
	store 246				// update offset accumulator

	load 250
	pushint 1
	+
	store 250				// increment index
	b WriteRef.consume_path_loop
WriteRef.consume_path_quit:

// stack: []
WriteRef.serialize:
	load 247				// arg2 (right value)
	load 253
	pushbytes 0x8000		// mask bit 15
	b&
	btoi
	bz WriteRef.serialize_exit
	itob					// serialize right value if bit 15 is set
	store 247
WriteRef.serialize_exit:

// stack: []
WriteRef.update:
	load 251
	load 246
	load 247
	replace3				// new serialized data with updated slice
	store 251				// 251 = updated serialized data

	load 255
	extract 0 1				// get kind of ref
	btoi
	switch WriteRef.k0_update WriteRef.k1_update
	
// kind 0x00: local
WriteRef.k0_update: 
	load 255				// load reference
	extract 1 1				// scratch space slot
	btoi					// index byte becomes uint64
	load 251
	stores					// push dereferenced value
	b WriteRef.exit	

// kind 0x01: global
WriteRef.k1_update: 
	load 255				// load reference
	dup
	extract 2 32			// address
	swap
	extract 1 1				// key = struct number
	uncover 2
	app_local_put			// push dereferenced value
 
WriteRef.exit:
	retsub
"""