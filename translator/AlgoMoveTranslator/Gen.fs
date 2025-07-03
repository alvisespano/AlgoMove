module AlgoMove.Transpiler.Gen

open AlgoMove.Transpiler.Absyn
open FSharp.Common

module M = Move
module T = Teal

type M.program with
    member P.index_of_structname id = List.findIndex (fun (s : M.Struct) -> s.id = id) P.structs

    member P.find_main =
        match List.filter (fun (F : M.Fun) -> List.contains M.Entry F.quals) P.funs with
        | [] -> failwith "No entry function found"
        | [F] -> F
        | Fs -> 
            match List.tryFind (fun (F : M.Fun) -> F.id = "main") Fs with
            | Some F -> F
            | None -> List.head Fs

type M.Fun with
    member F.max_local_index =
        F.body 
        |> List.map snd 
        |> List.choose (function 
            | M.MovLoc i
            | M.CpyLoc i
            | M.StLoc i -> Some i
            | _ -> None) 
        |> function [] -> None 
                   | l -> Some (uint (List.max l))
            

let emit_opcode (P : M.program) (op : M.opcode) : T.opcode list =
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
    | M.Br (None, l) -> yield T.B l
    | M.Br (Some true, l) -> yield T.Bnz l
    | M.Br (Some false, l) -> yield T.Bz l

    | op -> yield T.UnsupportedOpcode op

]

let emit_instrs P (instrs : M.instr list) : T.instr list = 
    [
        for l, mop in instrs do 
            match emit_opcode P mop with
            | [] -> ()
            | top1 :: tops -> 
                yield Some l, top1
                for top in tops do
                    yield None, top
    ]

let emit_fun P (F : M.Fun) : T.instr list =
    [
        let n = F.args.Length
        match F.body with
        | [] -> ()
        | (l1, mop1) :: minstrs ->
            // preamble
            yield Some l1, T.Proto (uint n, 1u)
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
            yield! emit_instrs P (("_" + l1, mop1) :: minstrs) // first opcode has fake label, since the original is on the proto above
 
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
        match P.find_main.body with
        | [] -> failwith "No body in main function"
        | (l1, _) :: _ -> 
            yield None, T.Callsub l1
            for F in P.funs do
                yield! emit_fun P F
    ]