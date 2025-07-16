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

// TODO fix WriteRef with new pointer format 
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

ReadRef:
	proto 1 1	
	frame_dig -1
	store 255		// 255 = whole reference (arg1)

	load 255
	extract 0 1		// get kind of ref
	btoi
	switch ReadRef.k0 ReadRef.k1

// kind 0x00: local
ReadRef.k0: 
	load 255
	extract 1 1		// get scratch space slot 
	btoi	
	loads			// read dereferenced data
	load 255
	pushint 2		// path offset
	b ReadRef.setup_path

// kind 0x01: global
ReadRef.k1:	
	load 255
	dup
	extract 2 32	// address
	swap
	extract 1 1		// key 
	app_local_get	// read dereferenced data
	load 255
	pushint 34		// path offset

// stack: offset, whole reference, dereferenced data 
ReadRef.setup_path:
	pushint 0
	extract3
	store 252		// 252 = path part
	len				// path size = array len (1 byte per field)
	store 254		// 254 = path size used as counter
	store 251		// 251 = dereferenced data

// stack: []
ReadRef.consume_path:
	load 254
	bz ReadRef.consume_path_quit

	load 252
	extract 0 1				// extract field index
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
	dup
	store 251				// 251 = sliced data

	load 254
	pushint 1
	-
	store 254
	b ReadRef.consume_path
ReadRef.consume_path_quit:

// stack: data
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
	// preamble
	proto 2 0
	// slot 255 used: reference (arg1)
	// slot 254 used: counter
	// slot 253 used: deserialize flag
	// slot 252 used: new value (arg2)
	// slot 251 used: offset accumulator
	// slot 250 used: kind of ref
	frame_dig -2
	store 255		 // 255 = whole reference (arg1)
	frame_dig -1
	store 252		 // 252 = right value (arg2)

	load 255
	extract 0 1		// get kind of ref
	btoi
	dup
	store 250		// 250 = kind of ref
	switch WriteRef.k0 WriteRef.k1

// kind 0x00: local
WriteRef.k0: 
	load 255		 
	extract 1 1			// get scratch space slot
	btoi				// index byte becomes uint64
	loads				// read dereferenced value
	load 255
	pushint 2			// path offset
	b WriteRef.setup_path

// kind 0x01: global
WriteRef.k1:	
	load 255		 // load reference
	dup
	extract 2 32	// address
	swap
	extract 1 1	 // key = struct number
	app_local_get // push dereferenced value
	load 255
	pushint 34		// path offset

// stack: offset, whole reference, dereferenced data 
WriteRef.setup_path:
	pushint 0		// till end of array
	extract3		 // push path part
	dup				 
	len
	pushint 4
	/						// path size = array len / 4
	store 254		// save path size used as counter

// stack: path, data
WriteRef.consume_path:
	load 254		 // load loop counter
	bz WriteRef.consume_path_quit

	dup
	extract 0 2			// field offset as 2 bytes
	dup
	store 253				// save offset highest byte for later
	pushbytes 0x7fff // clear bit 15
	b&
	btoi
	load 251
	+
	store 251
	extract 4 0

	// decrement counter
	load 254
	pushint 1
	-
	store 254
	b WriteRef.consume_path
WriteRef.consume_path_quit:
	pop							// discard path and leave data on top 

// stack: data
WriteRef.serialize:
	load 252				 // load arg2
	load 253				 // recover offset as 2 bytes
	pushbytes 0x8000 // mask bit 15
	b&
	btoi
	bz WriteRef.update
	itob						 // serialize arg2 if bit 15 is set

// stack: arg2(bytes), data
WriteRef.update:
	load 251				// load offset accumulator
	swap
	replace3				// update the relevant part of data

	load 250				// load kind of ref
	switch WriteRef.k0_update WriteRef.k1_update
	
// kind 0x00: local
WriteRef.k0_update: 
	load 255				// load reference
	extract 1 1		 // scratch space slot
	btoi						// index byte becomes uint64
	swap
	stores					// push dereferenced value
	b WriteRef.exit	

// kind 0x01: global
WriteRef.k1_update: 
	load 255				// load reference
	dup
	extract 2 32		// address
	swap
	extract 1 1		 // key = struct number
	uncover 2
	app_local_put	 // push dereferenced value
 
WriteRef.exit:
	retsub
"""