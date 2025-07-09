module AlgoMove.Transpiler.Gen

open AlgoMove.Transpiler.Absyn
open FSharp.Common
open System.Text.RegularExpressions

module M = Move
module T = Teal


// type augmentations
//

type M.Module with
    member P.struct_by_name id = P.structs.[int <| P.index_of_struct id]

    member P.index_of_struct id = List.findIndex (fun (s : M.Struct) -> s.id = id) P.structs |> byte

    member P.offset_of_field sid fid : uint16 =
        let S = P.struct_by_name sid
        let rec R = function
            | [] -> unexpected_case __SOURCE_FILE__ __LINE__ "Struct %s has no fields" sid
            | (id, ty) :: fields -> 
                if id = fid then 0us
                else P.len_of_ty ty + R fields 
        R S.fields |> uint16

    member P.len_of_ty ty : uint16 =
        match ty with
        | M.ty.Bool -> 1us
        | M.ty.U8 -> 1us
        | M.ty.U64 -> 8us
        | M.ty.U128 -> 16us
        | M.ty.Address -> 32us
        | M.ty.Typename s ->
            try
                let S = P.struct_by_name s
                List.sumBy (fun (_, ty) -> P.len_of_ty ty) S.fields |> uint16
            with _ -> Report.unsupported "typename %s is a generic type. Defaulting length to %d bytes" s Config.generic_field_default_length
                      uint16 Config.generic_field_default_length

        | _ -> unexpected_case __SOURCE_FILE__ __LINE__ "Type %A should not appear in structs" ty

    member P.find_main =
        match List.filter (fun (F : M.Fun) -> List.contains M.qual.Entry F.quals) P.funs with
        | [] ->
            let F = P.funs.Head
            Report.warn "no entry function found. Picking first available: %s" F.id
            F

        | [F] -> F

        | F1 :: _ as Fs -> 
            match List.tryFind (fun (F : M.Fun) -> F.id = "main") Fs with
            | Some F -> F
            | None -> F1

type M.Fun with
    member F.max_local_index =
        F.body 
        |> Array.choose (function 
            | M.MovLoc i
            | M.CpyLoc i
            | M.StLoc i -> Some i
            | _ -> None) 
        |> function [||] -> None 
                  | l -> Some (uint (Array.max l))


// context and labels
//
            
type ctx = {
    exit_label : T.label
    labels : T.label array
}

let touch_label (L : T.label) = ignore <| L.Force (); L
let qid_label mid fid = sprintf "%s%c%s" mid Config.teal_label_module_sep fid
let sublabel mid fid sub = sprintf "%s%c%s" (qid_label mid fid) Config.teal_sublabel_sep sub
let start_label mid fid = lazy (qid_label mid fid) |> touch_label
let exit_label mid fid = lazy (sublabel mid fid Config.teal_exit_sublabel)
let instr_label mid fid i = lazy (sublabel mid fid (string i)) 



// transpiler functions
//

let private ImportCache = System.Collections.Generic.Dictionary<M.id, M.Module * T.instr list>()

exception private UnsupportedNative

let private emit_call_native mid fid =

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
            Report.unsupported "native function %s.%s is not supported" mid fid
            yield T.UnsupportedNative (sprintf "%s::%s" mid fid)
    ]
     

let private emit_opcode ctx (P : M.Module) (op : M.opcode) =
        
    let branch cons l = cons (touch_label ctx.labels.[int l])

    let (|Native|NonNative|) (qid, fid) =
        let m = 
            match qid with
            | Some mid -> ImportCache.[mid] |> fst
            | None     -> P
        if List.exists (fun (F : M.Fun) -> F.id = fid && List.contains M.qual.Native F.quals) m.funs
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
        | M.VecLen _ -> yield T.Len
        
        | M.Ret ->  yield T.B ctx.exit_label
                
        | M.LdBool b -> yield T.PushInt (if b then 1UL else 0UL) 
        | M.LdU8 b -> yield T.PushBytes [|b|]
        | M.LdU64 u -> yield T.PushInt u
        | M.Br (None, l) -> yield branch T.B l
        | M.Br (Some true, l) -> yield branch T.Bnz l
        | M.Br (Some false, l) -> yield branch T.Bz l

        | M.Call (NonNative (mid, id), _, _) -> yield T.Callsub (start_label mid id)
        | M.Call (Native (mid, id), _, _) -> yield! emit_call_native mid id

        | M.ReadRef -> yield T.Callsub (lazy "ReadRef")         // TODO include read_ref/write_ref functions in emitted code
        | M.WriteRef -> yield T.Callsub (lazy "WriteRef")
        | M.FreezeRef -> ()

        | M.LdU128 n -> yield T.UnsupportedOpcode op

        | M.LdConst ((M.ty.Address | M.ty.Vector M.ty.U8), nums) ->
            yield T.PushBytes (Array.ofList <| List.map byte nums)

        | M.Pack id ->
            let S = P.struct_by_name id
            let n = uint S.fields.Length
            if n > 0u then
                for _, ty in S.fields do
                    yield T.Uncover (n - 1u)
                    if ty.IsTypename then yield T.Itob
                for i = 1u to n do
                    yield T.Concat

        | M.Unpack id -> 
            let S = P.struct_by_name id
            for x, ty in S.fields do
                yield T.Dup
                let d = P.offset_of_field id x
                let l = P.len_of_ty ty
                yield T.Extract (d, l)
                if ty.IsTypename then yield T.Btoi
                yield T.Swap
            yield T.Pop

        | M.BorrowField (sid, fid, fty) ->
            let d = P.offset_of_field sid fid ||| (if fty.IsTypename then 0us else 0x8000us)
            let l = P.len_of_ty fty
            let uint16_to_bytes (n : uint16) = [| byte (n >>> 8); byte (n &&& 0x00ffus) |]
            yield T.PushBytes [| yield! uint16_to_bytes d; yield! uint16_to_bytes l |]

        | M.BorrowGlobal id ->
            yield T.PushBytes [| byte 0x01; P.index_of_struct id |]
            yield T.Swap
            yield T.Concat

        | M.BorrowLoc i -> yield T.PushBytes [| byte 0x00; i |]
        
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

        | _ -> yield T.UnsupportedOpcode op 


    ]

let private emit_instrs ctx P (instrs : M.opcode array) =
    [
        for i = 0 to instrs.Length - 1 do
            let mop = instrs.[i]
            match emit_opcode ctx P mop with
            | [] -> ()
            | top1 :: tops ->
                yield Some ctx.labels.[i], top1
                for top in tops do
                    yield None, top
    ]

let private emit_fun (P : M.Module) (F : M.Fun) =
    [
        let n = F.args.Length
        let ctx = {
                exit_label = exit_label P.name F.id
                labels = [| for i = 0 to Array.length F.body - 1 do yield instr_label P.name F.id i |]
            }
        // preamble
        yield Some (start_label P.name F.id), T.Proto (uint n, 1u)
        let Mo = F.max_local_index
        match Mo with
        | None -> ()
        | Some M ->
            for i = 0u to M do 
                yield None, T.Load (byte i)
        for i = 0 to n - 1 do 
            yield None, T.FrameDig (-(i + 1))
            yield None, T.Store (byte i)
            
        // body            
        yield! emit_instrs ctx P F.body
 
        // epilogue
        match Mo with
        | None -> ()
        | Some M ->
            yield Some ctx.exit_label, T.Cover (M + 1u)
            for i = int M downto 0 do 
                yield None, T.Store (byte i)
        yield None, T.Retsub
    ]



let rec emit_module (P : M.Module) =           
    // do imports BEFORE
    for qid in P.imports do
        import_module qid
    [
        // functions
        for F in P.funs do
            yield! emit_fun P F
    ]

and import_module (_, id) =
    if not (ImportCache.ContainsKey id) then
        Report.info "importing disassembled module '%s'..." id
        let filename = sprintf "%s.mv.asm" id
        try
            let P = Parsing.load_and_parse_module filename
            ImportCache.[id] <- P, emit_module P
        with :? System.IO.FileNotFoundException as e ->
            Report.error "disassembled import file not found: %s.\nPlease disassemble all dependencies and put them in the same folder with the main module." filename

let emit_preamble (P : M.Module) =
    [
        yield Some (start_label P.name P.find_main.id), T.Txn "ApplicationArgs"
        // TODO emit TEAL preamble and epilogue
    ]


let emit_program (P : M.Module) : T.program =       
    [
        yield None, T.Callsub (start_label P.name P.find_main.id)
        yield None, T.PushInt 1UL
        yield None, T.Return 
        yield! emit_module P
        // append imports
        for p in ImportCache do
            yield! p.Value |> snd
    ]


// TODO emit preamble part:
(*
// Dispatch logic
dispatch_start:
txn ApplicationArgs 0
btoi
store 0          // index ← funzione selezionata

load 0
int 0
==
bnz funzione_0

load 0
int 1
==
bnz funzione_1

// ... aggiungi altri casi qui

err // se nessun caso matcha

// Funzione 0
funzione_0:
    // inserisci qui la logica della funzione 0
    int 1
    return

// Funzione 1
funzione_1:
    // inserisci qui la logica della funzione 1
    int 1
    return
    *)