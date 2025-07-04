module AlgoMove.Transpiler.Gen

open AlgoMove.Transpiler.Absyn
open FSharp.Common

module M = Move
module T = Teal

type M.program with
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
        | M.ty.StructName s ->
            let S = P.struct_by_name s
            List.sumBy (fun (_, ty) -> P.len_of_ty ty) S.fields |> uint16

        | _ -> unexpected_case __SOURCE_FILE__ __LINE__ "Type %A should not appear in structs" ty


    member P.find_main =
        match List.filter (fun (F : M.Fun) -> List.contains M.Entry F.quals) P.funs with
        | [] ->
            let F = P.funs.Head
            Report.warn "No entry function found. Picking first available: %s" F.id
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
            


let touch_label (L : T.label) = ignore <| L.Force (); L

let starting_label_of_fun (F : M.Fun) = lazy F.id |> touch_label

let private emit_opcode (labels : Teal.label array) (P : M.program) (op : M.opcode) : T.opcode list =
        
    let branch cons l = cons (touch_label labels.[int l])
                
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
        
        // TODO handle Ret at end of functions before emitting epilogue
        // il problema è che ci possono essere più di una Ret in una funzione, ma l'epilogo in TEAL è solo uno.
        // ci sono 2 soluzioni: 
        // 1) emettere una branch al posto della retsub che salta all'epilogo
        // 2) generare un wrapper per ogni funzione che faccia prologo + callsub + epilogo
        | M.Ret -> yield T.Retsub  
        
        
        | M.LdBool b -> yield T.PushInt (if b then 1UL else 0UL) 
        | M.LdU8 b -> yield T.PushBytes [|b|]
        | M.LdU64 u -> yield T.PushInt u
        | M.Br (None, l) -> yield branch T.B l
        | M.Br (Some true, l) -> yield branch T.Bnz l
        | M.Br (Some false, l) -> yield branch T.Bz l

        | M.Call (id, _, _) ->
            let F = List.find (fun (F : M.Fun) -> F.id = id) P.funs 
            yield T.Callsub (starting_label_of_fun F)

        // TODO implement Call to natives
        

        | M.ReadRef -> yield T.Callsub (lazy "ReadRef")         // TODO include read_ref/write_ref functions in emitted code
        | M.WriteRef -> yield T.Callsub (lazy "WriteRef")
        | M.FreezeRef -> ()

        | M.LdU128 n -> yield T.UnsupportedOpcode op
        | M.LdConst _ -> yield T.UnsupportedOpcode op

        | M.Pack id ->
            let S = P.struct_by_name id
            let n = uint S.fields.Length
            if n > 0u then
                for _, ty in S.fields do
                    yield T.Uncover (n - 1u)
                    if ty.IsStructName then yield T.Itob
                for i = 1u to n do
                    yield T.Concat

        | M.Unpack id -> 
            let S = P.struct_by_name id
            for x, ty in S.fields do
                yield T.Dup
                let d = P.offset_of_field id x
                let l = P.len_of_ty ty
                yield T.Extract (d, l)
                if ty.IsStructName then yield T.Btoi
                yield T.Swap
            yield T.Pop

        | M.BorrowField (sid, fid, fty) ->
            let d = P.offset_of_field sid fid ||| (if fty.IsStructName then 0us else 0x8000us)
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

    ]

let private emit_instrs labels P (instrs : M.opcode array) : T.instr list =
    [
        for i = 0 to instrs.Length - 1 do
            let mop = instrs.[i]
            match emit_opcode labels P mop with
            | [] -> ()
            | top1 :: tops ->
                yield Some labels.[i], top1
                for top in tops do
                    yield None, top
    ]

let private emit_fun P (F : M.Fun) : T.instr list =
    [
        let n = F.args.Length
        let labels = [| for i = 0 to Array.length F.body - 1 do yield lazy sprintf "%s$%d" F.id i |]
        // preamble
        yield Some (starting_label_of_fun F), T.Proto (uint n, 1u)
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
        yield! emit_instrs labels P F.body
 
        // epilogue
        match Mo with
        | None -> ()
        | Some M ->
            yield None, T.Cover (M + 1u)
            for i = int M downto 0 do 
                yield None, T.Store (byte i)
        yield None, T.Retsub
    ]

let emit_program (P : M.program) : T.program =    
    [
        yield None, T.Callsub (starting_label_of_fun P.find_main)
        yield None, T.PushInt 1UL
        yield None, T.Return 
        for F in P.funs do
            yield! emit_fun P F
    ]