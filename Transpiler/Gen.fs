module AlgoMove.Transpiler.Gen

open AlgoMove.Transpiler.Absyn
open FSharp.Common
open System.Text.RegularExpressions

module M = Move
module T = Teal


// type augmentations
//

let (|TyIntegral|_|) = function
    | M.ty.Bool
    | M.ty.U8 
    | M.ty.U16
    | M.ty.U32 
    | M.ty.U64 -> Some ()
    | _ -> None

type M.ty with
    member self.is_integral =
        match self with
        | TyIntegral _ -> true
        | _ -> false

    member self.raw =
            match self with
            | M.ty.Cons (id, _) -> id
            | _ -> unexpected_case __SOURCE_FILE__ __LINE__ "raw type of non-struct '%A'" self

    member self.apply_subst θ = 
        match self with
        | M.ty.Cons (s, []) when Map.containsKey s θ -> Map.find s θ
        | τ -> τ


type M.Struct with
    member self.instantiate τs =
        let θ = Map.ofList <| List.zip self.ty_params τs
        { self with fields = [ for x, τ in self.fields do yield x, τ.apply_subst θ ] }


type M.Module with

    member P.struct_by_name id = P.structs.[int <| P.index_of_struct id]

    member P.index_of_struct id = List.findIndex (fun (s : M.Struct) -> s.id = id) P.structs |> byte

    member P.instantiate_struct τ =
            match τ with
            | M.ty.Cons (s, τs) -> (P.struct_by_name s).instantiate τs
            | _ -> unexpected_case __SOURCE_FILE__ __LINE__ "type %O must be a struct" τ

    member P.offset_of_struct_field sid fid = P.offset_of_field (P.struct_by_name sid).fields fid

    member P.offset_of_field fields fid : uint =
        let rec R = function
            | [] -> 0u
            | (id, τ) :: fields -> 
                if id = fid then 0u
                else P.len_of_ty τ + R fields
        R fields

    member P.len_of_ty τ : uint =
        match τ with
        | TyIntegral _ -> 8u
        | M.ty.Cons (s, _) ->
            try
                let S = P.struct_by_name s
                List.sumBy (fun (_, τ) -> P.len_of_ty τ) S.fields |> uint
            with :? System.ArgumentException -> unexpected "typename %s is a generic type" __SOURCE_FILE__ __LINE__ s

        | _ -> unexpected_case __SOURCE_FILE__ __LINE__ "type %O should not appear in structs" τ

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


// context and misc stuff
//
            
type context = {
    labels : T.label array
    ty_params : M.ty_param list
    P : M.Module
    F : M.Fun
}
with
    member self.is_type_parameter s = List.contains s self.ty_params

let touch_label (L : T.label) = ignore <| L.Force (); L
let qid_label_name mid fid = sprintf "%s%c%s" mid Config.teal_label_module_sep fid
let sublabel_name mid fid sub = sprintf "%s%c%s" (qid_label_name mid fid) Config.teal_sublabel_sep sub
let solid_label mid fid = lazy (qid_label_name mid fid) |> touch_label
let exit_label mid fid = lazy (sublabel_name mid fid Config.teal_exit_sublabel)
let instr_label mid fid i = lazy (sublabel_name mid fid (string i)) 

let bytes_of_string = Seq.map byte >> Seq.toArray

//type type_tag = { is_integral: bool; name: string }
//with
//    static member of_ty (P : M.Module) (τ : M.ty) = { is_integral = τ.is_integral; name = sprintf "%O" τ }

//    member self.as_bytes = sprintf "%1d%O" (if self.is_integral then 1 else 0) self.name |> bytes_of_string




// transpiler functions
//

exception UnsupportedNative

let private ImportCache = System.Collections.Generic.Dictionary<M.id, _>()

let private TouchedFunCache = System.Collections.Generic.HashSet<M.id * M.id>()

let emit_opcode (ctx : context) (op : M.opcode) =
        
    let branch cons l = cons (touch_label ctx.labels.[int l])
    let fresh_label () = lazy (sublabel_name ctx.P.name ctx.F.name (fresh_int () |> string)) |> touch_label

    let (|Native|NonNative|) (qid, fid) =
        let m = 
            match qid with
            | Some mid -> ImportCache.[mid] |> fst
            | None     -> ctx.P
        if List.exists (fun (F : M.Fun) -> F.name = fid && List.contains M.qual.Native F.quals) m.funs
        then Native (m.name, fid)
        else NonNative (m.name, fid)
            
    let (|TyParam|_|) = function
        | M.ty.Cons (s, []) when ctx.is_type_parameter s -> 
            let i = List.findIndex ((=) s) ctx.ty_params
            Some [ T.FrameDig (-(List.length ctx.ty_params - 1 - i) - 1) ]
        | _ -> None

    let emit_call_native mid fid (ty_args : M.ty list) =

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
                    | "name_of" ->
                        match ty_args.[0] with
                        | TyParam instrs -> 
                            yield! instrs
                            yield T.Extract (1u, 0u)    // name part

                        | τ -> yield T.PushBytes (τ.ToString () |> bytes_of_string)
                        
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

    let rec emit_type_tag σ =
        [
            match σ with
            | TyParam instrs     -> yield! instrs
            | M.ty.Cons (id, []) -> yield T.PushBytes (sprintf "0%s" id |> bytes_of_string)
            | TyIntegral         -> yield T.PushBytes (sprintf "1%O" σ |> bytes_of_string)
  
            | M.ty.Cons (id, τ1 :: τs) ->
                yield T.PushBytes (sprintf "0%O<" id |> bytes_of_string)
                yield! emit_type_tag τ1
                yield T.Concat
                for τ in τs do
                    yield T.PushBytes ("," |> bytes_of_string)
                    yield T.Concat
                    yield! emit_type_tag τ
                    yield T.Concat
                yield T.PushBytes (">" |> bytes_of_string)
                yield T.Concat
 
            | _ -> unexpected_case __SOURCE_FILE__ __LINE__ "emitting type tag of %O" σ
        ]

    let access_slot (i : M.index) arg local = 
        let N = uint ctx.F.paramss.Length
        let TN = uint ctx.F.ty_params.Length
        if i < N then arg -(int (TN + i + 1u))
        else local i

    [
        match op with
        | M.Nop -> ()

        | M.MovLoc i
        | M.CpyLoc i -> yield access_slot i T.FrameDig T.Load         
        | M.StLoc i  -> yield access_slot i T.FrameBury T.Store
        
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
        
        | M.Ret ->  yield T.B (exit_label ctx.P.name ctx.F.name)
                
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

        | M.Call (NonNative (mid, fid), ty_args) -> 
            TouchedFunCache.Add (mid, fid) |> ignore
            for τ in ty_args do
                yield! emit_type_tag τ
            yield T.Callsub (solid_label mid fid) 


        | M.Call (Native (mid, fid), ty_args) -> 
            yield! emit_call_native mid fid ty_args

        | M.ReadRef -> yield T.Callsub (lazy "ReadRef")
        | M.WriteRef -> yield T.Callsub (lazy "WriteRef")
        | M.FreezeRef -> ()

        | M.LdConst ((M.ty.Address | M.ty.Cons ("vector", [M.ty.U8])), nums) ->
            yield T.PushBytes (Array.ofList <| List.map byte nums)

        | M.LdConst (ty, nums) ->
            Report.error "constants of type %A is not supported" op
            failwithf "unsupported constant type %A" ty

        | M.Pack σ ->
            let S = ctx.P.instantiate_struct σ
            let N = uint S.fields.Length
            if N > 0u then
                for _, τ in S.fields do
                    yield T.Uncover (N - 1u)
                    match τ with
                    | TyParam instrs -> 
                        yield! instrs
                        yield T.Callsub (lazy "PackTyArg")

                    | _ when τ.is_integral -> yield T.Itob               
                    | _ -> ()

                // craft struct header: (offset, len) pairs
                yield T.PushInt 0UL
                yield T.Store 255u
                yield T.PushInt (uint64 (N - 1u))
                yield T.Store 254u
                let l = fresh_label ()
                yield T.Label l
                yield T.Dig (N - 1u)
                yield T.Callsub (lazy "PackField")
                yield T.Bnz l
                    
                for i = 1u to N * 2u - 1u do
                    yield T.Concat

                    

        | M.Unpack σ -> 
            let S = ctx.P.instantiate_struct σ
            for i = 0UL to uint64 <| S.fields.Length - 1 do
                let x, τ = S.fields.[int i]
                yield T.Dupn 3u
                yield T.PushInt (i * 4UL)
                yield T.Extract_uint16     // offset
                yield T.Swap
                yield T.PushInt (i * 4UL + 2UL)
                yield T.Extract_uint16     // len
                yield T.Extract3
                match τ with
                | TyParam instrs -> 
                    yield! instrs
                    yield T.Callsub (lazy "UnpackTyArg")

                | _ when τ.is_integral -> yield T.Btoi
                | _ -> ()
                yield T.Swap
            yield T.Pop

        | M.BorrowField (sid, fid, τ) ->
            let S = ctx.P.struct_by_name sid
            let i = List.findIndex (fst >> (=) fid) S.fields
            yield T.PushBytes [| byte i |]  
            yield T.Concat


        | M.BorrowGlobal τ ->
            yield T.PushBytes [| byte 0x01; ctx.P.index_of_struct τ.raw |]  
            yield T.Swap
            yield T.Concat  

        | M.BorrowLoc i -> yield T.PushBytes [| byte 0x00; byte i |]
        
        | M.Exists τ ->             
            yield T.Txn "ApplicationID"
            yield T.PushBytes [| ctx.P.index_of_struct τ.raw |]
            yield T.AppLocalGetEx
            yield T.Uncover 1u
            yield T.Pop

        | M.MoveTo τ ->
            yield T.PushBytes [| ctx.P.index_of_struct τ.raw |] // TODO check the key thing
            yield T.Swap
            yield T.AppLocalPut

        | M.MoveFrom τ -> 
            yield T.PushBytes [| ctx.P.index_of_struct τ.raw |]
            yield T.Dup2
            yield T.AppLocalGet
            yield T.Cover 2u
            yield T.AppLocalDel
    ]

let emit_instrs ctx (instrs : M.opcode array) =
    [
        for i = 0 to instrs.Length - 1 do
            let mop = instrs.[i]
            match emit_opcode ctx mop with
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
                    labels = [| for i = 0 to Array.length F.body - 1 do yield instr_label P.name F.name i |]
                    ty_params = F.ty_params
                    P = P
                    F = F
                }
            // preamble
            yield T.Label (solid_label P.name F.name)
            yield T.Proto (uint (N + TN), if F.ret.IsNone then 0u else 1u)
            let M = 
                match F.max_local_index with
                | None -> -1
                | Some M -> max (int M) (N - 1)
            for i = N to M do 
                yield T.Load (uint i)
            
            // body            
            yield! emit_instrs ctx F.body
 
            // epilogue
            yield T.Label (exit_label P.name F.name)
            if F.ret.IsSome then yield T.FrameBury 0    // TODO tuple support
            for i = int M downto N do 
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
        Report.warn "no entry function found in module '%s'. Library modules include no function dispatcher in the generated TEAL preamble." P.name
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
                        | x, τ -> 
                            yield T.Load 0u
                            let d = P.offset_of_field args_no_signer x
                            let l = P.len_of_ty τ
                            yield T.Extract (d, l)
                            if τ.is_integral then yield T.Btoi
                    // call the entry function
                    yield! emit_opcode { labels = [||]; ty_params = []; P = P; F = F } (M.Call ((None, F.name), []))
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
