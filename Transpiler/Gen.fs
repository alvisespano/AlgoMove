module AlgoMove.Transpiler.Gen

open AlgoMove.Transpiler.Absyn
open FSharp.Common
open System.Text.RegularExpressions

module M = Move
module T = Teal


// type augmentations
//

type M.ty with
    member ty.is_integral =
        match ty with
        | M.ty.Bool
        | M.ty.U8 
        | M.ty.U16
        | M.ty.U32 
        | M.ty.U64 -> true
        | _ -> false

type M.Module with
    member P.struct_by_name id = P.structs.[int <| P.index_of_struct id]

    member P.index_of_struct id = List.findIndex (fun (s : M.Struct) -> s.id = id) P.structs |> byte

    member P.offset_of_struct_field sid fid = P.offset_of_field (P.struct_by_name sid).fields fid

    member P.offset_of_field fields fid : uint16 =
        let rec R = function
            | [] -> 0us
            | (id, ty) :: fields -> 
                if id = fid then 0us
                else P.len_of_ty ty + R fields 
        R fields |> uint16

    member P.len_of_ty ty : uint16 =
        match ty with
        | M.ty.Bool -> 1us
        | M.ty.U8 -> 1us
        | M.ty.U16 -> 2us
        | M.ty.U32 -> 4us
        | M.ty.U64 -> 8us
        | M.ty.Address -> 32us
        | M.ty.Cons (s, _) ->
            try
                let S = P.struct_by_name s
                List.sumBy (fun (_, ty) -> P.len_of_ty ty) S.fields |> uint16
            with _ -> Report.warn "typename %s is a generic type. Generics are not supported. Defaulting length to %d bytes" s Config.generic_field_default_length
                      uint16 Config.generic_field_default_length

        | M.ty.Ref _ | M.ty.MutRef _ | M.ty.Tuple _ -> unexpected_case __SOURCE_FILE__ __LINE__ "Type %A should not appear in structs" ty

type M.Fun with
    member F.max_local_index =
        F.body 
        |> Array.choose (function 
            | M.MovLoc i
            | M.CpyLoc i
            | M.StLoc i -> Some i
            | _ -> None) 
        |> function [||] -> None 
                  | l    -> Some (uint (Array.max l))


// context and labels
//
            
type context = {
    exit_label : T.label
    labels : T.label array
    ty_params : M.ty_param list
}

let touch_label (L : T.label) = ignore <| L.Force (); L
let qid_label_name mid fid = sprintf "%s%c%s" mid Config.teal_label_module_sep fid
let sublabel_name mid fid sub = sprintf "%s%c%s" (qid_label_name mid fid) Config.teal_sublabel_sep sub
let solid_label mid fid = lazy (qid_label_name mid fid) |> touch_label
let exit_label mid fid = lazy (sublabel_name mid fid Config.teal_exit_sublabel)
let instr_label mid fid i = lazy (sublabel_name mid fid (string i)) 



// transpiler functions
//

exception UnsupportedNative

let private ImportCache = System.Collections.Generic.Dictionary<M.id, _>()

let private TouchedFunCache = System.Collections.Generic.HashSet<M.id * M.id>()

let emit_call ty_params mid id (ty_args : M.ty list) =
    TouchedFunCache.Add (mid, id) |> ignore
    [ 
        let N = List.length ty_params
        for ty in ty_args do
            match ty with
            | M.ty.Cons (id, []) when List.contains id ty_params -> 
                let i = List.findIndex ((=) id) ty_params
                yield T.FrameDig (-(N - 1 - i) - 1)

            | _ -> yield T.PushBytes (sprintf "%O" ty |> Seq.map byte |> Array.ofSeq)
        yield T.Callsub (solid_label mid id) 
    ]

let emit_call_native ty_params mid fid ty_args =

    let (|Regex|_|) pattern input =
        let m = Regex.Match (input, pattern)
        if m.Success then Some (List.tail [ for g in m.Groups -> g.Value ])
        else None
    [
        try
            match mid with
            | "utils" ->
                match fid with 
                | "address_of_signer"
                | "bytes_of_address" -> ()
                | "name_of" -> yield T.FrameDig -1  // has 1 type parameter only, just return the type witness that is the typename already
                | _ -> raise UnsupportedNative

            | "opcode" ->
                match fid with
                | "itxn_begin" -> yield T.ITxnBegin
                | "itxn_submit" -> yield T.ITxnSubmit

                | Regex @"itxn_field_(\w+)" [field] -> yield T.ITxnField field
                | Regex @"global_(\w+)" [field] -> yield T.Global field
                | Regex @"txn_(\w+)" [field] -> yield T.Txn field
                | Regex @"txnas_(\w+)" [field] -> yield T.Txnas field
                | Regex @"asset_holding_get_(\w+)" [field] -> yield T.AssetHoldingGet field
                | Regex @"asset_params_get_(\w+)" [field] -> yield T.AssetParamsGet field

                | "balance"       -> yield T.Balance
                | "min_balance"   -> yield T.MinBalance
                | "app_local_get" -> yield T.AppLocalGet
                | "app_global_get"-> yield T.AppGlobalGet
                | "app_local_put" -> yield T.AppLocalPut
                | "app_global_put"-> yield T.AppGlobalPut
                | "assert"        -> yield T.Assert
                | "itob"          -> yield T.Itob
                | "btoi"          -> yield T.Btoi
                | "len"           -> yield T.Len
                | "concat"        -> yield T.Concat
                | "err"           -> yield T.Err

                | _ -> raise UnsupportedNative
            
            | _ -> raise UnsupportedNative

        with UnsupportedNative ->
            Report.error "native function %s.%s is not yet supported" mid fid
            yield T.UnsupportedNative (sprintf "%s::%s" mid fid)
    ]



let emit_opcode ctx (P : M.Module) (op : M.opcode) =
        
    let branch cons l = cons (touch_label ctx.labels.[int l])

    let (|Native|NonNative|) (qid, fid) =
        let m = 
            match qid with
            | Some mid -> ImportCache.[mid] |> fst
            | None     -> P
        if List.exists (fun (F : M.Fun) -> F.name = fid && List.contains M.qual.Native F.quals) m.funs
        then Native (m.name, fid)
        else NonNative (m.name, fid)
                
    [
        match op with
        | M.Nop -> ()

        | M.MovLoc i -> yield T.Load i
        | M.CpyLoc i -> yield T.Load i
        | M.StLoc i -> yield T.Store i
        | M.Add -> yield T.Add
        | M.Sub -> yield T.Sub
        | M.Mul -> yield T.Mul
        | M.Div -> yield T.Div
        | M.Mod -> yield T.Mod
        | M.BOr -> yield T.BOr
        | M.BAnd -> yield T.BAnd
        | M.Xor -> yield T.Xor
        | M.Shl -> yield T.Shl
        | M.Shr -> yield T.Shr
        | M.Not -> yield T.Not
        | M.And -> yield T.And
        | M.Or -> yield T.Or
        | M.Eq -> yield T.Eq
        | M.Neq -> yield T.Neq
        | M.Lt -> yield T.Lt
        | M.Le -> yield T.Le
        | M.Gt -> yield T.Gt
        | M.Ge -> yield T.Ge
        | M.Pop -> yield T.Pop
        | M.Abort -> yield T.Err
        
        | M.Ret ->  yield T.B ctx.exit_label
                
        | M.LdBool b -> yield T.PushInt (if b then 1UL else 0UL) 
        | M.LdU8 u  -> yield T.PushInt (uint64 u)
        | M.LdU16 u -> yield T.PushInt (uint64 u)
        | M.LdU32 u -> yield T.PushInt (uint64 u)
        | M.LdU64 u -> yield T.PushInt (uint64 u)

        | M.CastU8 
        | M.CastU16 
        | M.CastU32 
        | M.CastU64 -> ()

        | M.Br (None, l) -> yield branch T.B l
        | M.Br (Some true, l) -> yield branch T.Bnz l
        | M.Br (Some false, l) -> yield branch T.Bz l

        | M.Call (NonNative (mid, id), ty_args) -> yield! emit_call ctx.ty_params mid id ty_args
        | M.Call (Native (mid, id), ty_args) -> yield! emit_call_native ctx.ty_params mid id ty_args

        | M.ReadRef -> yield T.Callsub (lazy "ReadRef")        
        | M.WriteRef -> yield T.Callsub (lazy "WriteRef")
        | M.FreezeRef -> ()

        | M.LdConst ((M.ty.Address | M.ty.Cons ("vector", [M.ty.U8])), nums) ->
            yield T.PushBytes (Array.ofList <| List.map byte nums)

        | M.LdConst (ty, nums) ->
            Report.error "constants of type %A is not supported" op
            failwithf "unsupported constant type %A" ty

        | M.Pack id ->
            let S = P.struct_by_name id
            let n = uint S.fields.Length
            if n > 0u then
                for _, ty in S.fields do
                    yield T.Uncover (n - 1u)
                    if ty.is_integral then yield T.Itob
                for i = 1u to n do
                    yield T.Concat

        | M.Unpack id -> 
            let S = P.struct_by_name id
            for x, ty in S.fields do
                yield T.Dup
                let d = P.offset_of_struct_field id x
                let l = P.len_of_ty ty
                yield T.Extract (d, l)
                if ty.is_integral then yield T.Btoi
                yield T.Swap
            yield T.Pop

        | M.BorrowField (sid, fid, fty) ->
            let d = P.offset_of_struct_field sid fid ||| (if fty.is_integral then 0us else 0x8000us)   // set bit 15 is deserialization is needed
            let l = P.len_of_ty fty
            let uint16_to_bytes (n : uint16) = [| byte (n >>> 8); byte (n &&& 0x00ffus) |]
            yield T.PushBytes [| yield! uint16_to_bytes d; yield! uint16_to_bytes l |]

        | M.BorrowGlobal id ->
            yield T.PushBytes [| byte 0x01; P.index_of_struct id |]
            yield T.Swap
            yield T.Concat

        | M.BorrowLoc i -> yield T.PushBytes [| byte 0x00; byte i |]
        
        | M.Exists id -> 
            yield T.Txn "ApplicationID"
            yield T.PushBytes [| P.index_of_struct id |]
            yield T.AppLocalGetEx
            yield T.Uncover 1u
            yield T.Pop

        | M.MoveTo id ->
            yield T.PushBytes [| P.index_of_struct id |]
            yield T.Swap
            yield T.AppLocalPut

        | M.MoveFrom id -> 
            yield T.PushBytes [| P.index_of_struct id |]
            yield T.Dup2
            yield T.AppLocalGet
            yield T.Cover 2u
            yield T.AppLocalDel
    ]

let emit_instrs ctx P (instrs : M.opcode array) =
    [
        for i = 0 to instrs.Length - 1 do
            let mop = instrs.[i]
            match emit_opcode ctx P mop with
            | [] -> ()
            | top1 :: tops ->
                yield T.Label ctx.labels.[i]
                yield top1
                for top in tops do
                    yield top
    ]

let emit_fun (P : M.Module) (F : M.Fun) =
    F.name, [
            let N = F.paramss.Length
            let TN = F.ty_params.Length
            let ctx = {
                    exit_label = exit_label P.name F.name
                    labels = [| for i = 0 to Array.length F.body - 1 do yield instr_label P.name F.name i |]
                    ty_params = F.ty_params
                }
            // preamble
            yield T.Label (solid_label P.name F.name)
            yield T.Proto (uint (N + TN), 1u)
            let M = 
                match F.max_local_index with
                | None -> -1
                | Some M -> max (int M) (N - 1)
            for i = 0 to M do 
                yield T.Load (uint i)
            for i = 0 to N - 1 do 
                yield T.FrameDig (-i - (TN + 1))
                yield T.Store (uint <| N - i - 1)
            
            // body            
            yield! emit_instrs ctx P F.body
 
            // epilogue
            yield T.Label ctx.exit_label
            yield T.Cover (uint <| M + 1)
            for i = int M downto 0 do 
                yield T.Store (uint i)
            yield T.Retsub
        ]


let rec emit_module (P : M.Module) =           
    // process imports BEFORE
    for qid in P.imports do
        import_module qid
    [
        // functions
        for F in P.funs do
            yield emit_fun P F
    ]

and import_module (_, id) =
    if not (ImportCache.ContainsKey id) then
        Report.info "importing disassembled module '%s'..." id
        let filename = sprintf "%s.mv.asm" id
        try
            let P = Parsing.load_and_parse_module filename
            ImportCache.[id] <- P, emit_module P
        with :? System.IO.FileNotFoundException as e ->
            Report.error "disassembled import file not found: %s.\nPlease disassemble all dependencies and put them in the same folder with the main disassembled module." filename

let (|Signer|_|) (ty : M.ty) =
    match ty with
    | M.ty.Ref (M.ty.Cons ("signer", [])) -> Some ()
    | _ -> None

let emit_preamble (P : M.Module) =
    let funs = List.filter (fun (F : M.Fun) -> List.contains M.qual.Entry F.quals) P.funs
    if funs.Length = 0 then
        Report.warn "no entry function found in module '%s'. Library modules include no dispatcher in the preamble." P.name
        false, []
    else
        Report.info "found %d entry functions in module '%s'" funs.Length P.name
        true, [
                yield T.Label (solid_label "startup" "dispatcher")
                // shorten ApplicationArgs byte array by removing the head
                yield T.Txn "ApplicationArgs"
                yield T.Len
                yield T.PushInt 1UL
                yield T.Swap
                yield T.Extract3 
                yield T.Store 0u
                // dispatch function
                yield T.Txna ("ApplicationArgs", 0u)
                yield T.Btoi
                let labels = [ for F in funs do yield solid_label "startup" (qid_label_name P.name F.name) ]
                yield T.Switch labels
                yield T.Err
                for l, F in List.zip labels funs do
                    yield T.Label l
                    // deserialize application arguments
                    let args_no_signer = List.filter (function _, Signer -> false | _ -> true) F.paramss
                    for i = 0 to F.paramss.Length - 1 do
                        match F.paramss.[i] with
                        | _, Signer -> yield T.Txn "Sender"
                        | x, ty -> 
                            yield T.Load 0u
                            let d = P.offset_of_field args_no_signer x
                            let l = P.len_of_ty ty
                            yield T.Extract (d, l)
                            if ty.is_integral then yield T.Btoi
                    // call the entry function
                    yield! emit_call [] P.name F.name []
                    yield T.Return
              ]

let emit_program (P : M.Module) : T.program =
    [
        // emit entire main module
        for _, f in emit_module P do yield! f
        // emit only touched functions in imports
        for kv in ImportCache do
            let mid, (_, fs) = kv.Key, kv.Value
            for fid, f in fs do
                if TouchedFunCache.Contains (mid, fid) then
                    yield! f
                else 
                    Report.debug "function %s::%s is never called and will not be emitted" mid fid
    ]

let generate_program (P : M.Module) : string =
    let has_dispatcher, preamble = emit_preamble P
    let main = emit_program P
    (if has_dispatcher then TealLib.header_dispatcher else TealLib.header_no_dispatcher) + T.pretty_program preamble + T.pretty_program main + TealLib.epilogue
