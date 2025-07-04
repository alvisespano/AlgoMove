module AlgoMove.Transpiler.Gen

open AlgoMove.Transpiler.Absyn
open FSharp.Common

module M = Move
module T = Teal

type M.program with
    member P.index_of_structname id = List.findIndex (fun (s : M.Struct) -> s.id = id) P.structs

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
            

//module Pre =        

//    let private unique_labels (P : M.program) =
//        let p f (l, op) = 
//            let u l = sprintf "%s$%s" f l
//            let op' =
//                match op with
//                | M.Br (o, l) -> M.Br (o, u l)
//                | _ -> op
//            in
//                u l, op'
//        in
//            { P with funs = List.map (fun F -> { F with body = List.map (p F.id) F.body }) P.funs }
   
//    let private remove_nops (P : M.program) =
//        let p (l, op) =
//            match op with
//            | M.Nop -> None
//            | _ -> Some (l, op)
//        in
//            { P with funs = List.map (fun F -> { F with body = List.choose p F.body }) P.funs }

//    let program P = P |> remove_nops |> unique_labels


let touch_label (L : T.label) = ignore <| L.Force (); L

let label_of_funname s = lazy s |> touch_label

let private emit_opcode (labels : Teal.label array) (P : M.program) (op : M.opcode) : T.opcode list =
        
    let branch cons l = cons (touch_label labels.[int l])
                
    [
        match op with

        | M.Nop -> ()

        | M.MoveTo id ->
            yield T.PushBytes [| P.index_of_structname id |> byte |]
            yield T.Swap
            yield T.AppLocalPut

        // single instruction
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
        | M.Ret -> yield T.Retsub
        | M.LdBool b -> yield T.PushInt (if b then 1UL else 0UL) 
        | M.LdU8 b -> yield T.PushBytes [|b|]
        | M.LdU64 u -> yield T.PushInt u
        | M.Br (None, l) -> yield branch T.B l
        | M.Br (Some true, l) -> yield branch T.Bnz l
        | M.Br (Some false, l) -> yield branch T.Bz l

        | M.Call (id, _, _) ->
            let F = List.find (fun (F : M.Fun) -> F.id = id) P.funs 
            yield T.Callsub (label_of_funname F.id)

        | op -> yield T.UnsupportedOpcode op

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
        yield Some (label_of_funname F.id), T.Proto (uint n, 1u)
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
    //let P = Pre.program P
    [
        let main = P.find_main
        yield None, T.Callsub (label_of_funname main.id)
        yield None, T.PushInt 1UL
        yield None, T.Return 
        for F in P.funs do
            yield! emit_fun P F
    ]