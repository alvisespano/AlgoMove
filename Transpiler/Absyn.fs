module AlgoMove.Transpiler.Absyn

open System
open FSharp.Common

module Move =

    type id = string
    type qid = id option * id
    type address = string
    type label = uint


    [<RequireQualifiedAccess>]
    type ty = 
        | Bool
        | U8
        | U16
        | U32
        | U64
        | Address
        | Cons of id * ty list
        | Typename of id
        | Ref of ty
        | MutRef of ty 
        | Tuple of ty list
    with 
        static member of_const_ty (cons : id, arg : id option) =
            match cons.ToLower(), Option.map (fun (s : string) -> s.ToLower()) arg with
            | "address", None -> ty.Address
            | "vector", Some "u8" -> ty.Cons ("vector", [ty.U8])
            | _ -> unexpected_case __SOURCE_FILE__ __LINE__ "Move const type '%s%s' not recognized" cons (Option.map (sprintf "(%s)") arg |> Option.defaultValue "")

        member self.raw =
            match self with
            | Cons (id, _)
            | Typename id -> id
            | _ -> unexpected_case __SOURCE_FILE__ __LINE__ "Raw type of non-struct '%A'" self

    type field = id * ty
    type param = field

    [<RequireQualifiedAccess>]
    type qual = Public | Entry | Native

    type capab = Key | Store | Copy | Drop

    type index = uint

    type opcode = 
        | Nop
        | MovLoc of index
        | CpyLoc of index
        | StLoc of index
        | Add
        | Sub
        | Mul
        | Div
        | Mod
        | BOr
        | BAnd
        | Xor
        | Shl
        | Shr
        | Not
        | And
        | Or
        | Eq
        | Neq
        | Lt
        | Le
        | Gt
        | Ge
        | Pop
        | Abort
        | Call of qid * ty list 
        | ReadRef
        | WriteRef
        | FreezeRef
        | LdBool of bool
        | LdU8 of byte
        | LdU16 of uint16
        | LdU32 of uint32
        | LdU64 of uint64
        | LdConst of ty * int list
        | CastU8
        | CastU16
        | CastU32
        | CastU64
        | Pack of id    // the struct typename must be local and cannot be a qid
        | Unpack of id
        | Br of bool option * label
        | Ret
        | BorrowField of id * id * ty
        | BorrowGlobal of id 
        | BorrowLoc of index
        | Exists of id
        | MoveTo of id
        | MoveFrom of id

    type ty_param = id * capab list

    type Fun = { quals : qual list; name : id; ty_params : ty_param list; paramss : param list; ret : ty option; body : opcode array }

    type Struct = { id : id; ty_params : ty_param list; capabs : capab list; fields : field list }

    type Module = { fullname : qid; imports: qid list; structs : Struct list; funs : Fun list }
    with
        member P.name = let _, s = P.fullname in s

module Teal =
   
    type label = string Lazy

    type opcode =
        | Label of label
        //| UnsupportedOpcode of Move.opcode
        | UnsupportedNative of string

        // Stack manipulation
        | PushInt of uint64
        | PushBytes of byte array
        | Pop
        | Dup
        | Dup2
        | Dupn of uint
        | Swap
        | Cover of uint
        | Uncover of uint
        | FrameDig of int 

        // Arithmetic
        | Add
        | Sub
        | Mul
        | Div
        | Mod
        | Exp
        | Sqrt

        // Bitwise
        | BOr
        | BAnd
        | BXor
        | BNot
        | Shl
        | Shr

        // Logic
        | Not
        | And
        | Or
        | Xor

        // Comparison (uint64)
        | Eq
        | Neq
        | Lt
        | Le
        | Gt
        | Ge

        // Branching
        | B of label
        | Bnz of label
        | Bz of label
        | Callsub of label
        | Retsub
        | Switch of label list
        
        // Storage/State
        | Load of uint
        | Store of uint
        | LoadS
        | StoreS

        // Global/Txn
        | Global of string
        | Txn of string
        | Txnas of string
        | Txna of string * uint
        | ITxnBegin
        | ITxnField of string
        | ITxnSubmit

        // Account/Asset/App
        | Balance
        | MinBalance
        | AssetHoldingGet of string
        | AssetParamsGet of string
        | AppLocalPut
        | AppLocalGet
        | AppLocalDel
        | AppLocalGetEx
        | AppGlobalGet
        | AppGlobalPut

        // Misc
        | Assert
        | Itob
        | Btoi
        | Len
        | Extract of uint16 * uint16
        | Extract3
        | Concat
        | Err
        | Proto of uint * uint
        | Return


    type program = opcode list

    let pretty_opcode (op: opcode) =
        match op with
        | Label l -> if l.IsValueCreated then sprintf "%s:" l.Value else ""
        //| UnsupportedOpcode mop -> sprintf "UNSUPPORTED_OPCODE[%A]" mop
        | UnsupportedNative s -> sprintf "UNSUPPORTED_NATIVE[%s]" s
        | PushInt n -> sprintf "pushint %d" n
        | PushBytes b -> sprintf "pushbytes 0x%s" (System.BitConverter.ToString(b).Replace("-", ""))
        | Pop -> "pop"
        | Dup -> "dup"
        | Dup2 -> "dup2"
        | Dupn n -> sprintf "dupn %d" n
        | Swap -> "swap"
        | Cover n -> sprintf "cover %d" n
        | Uncover n -> sprintf "uncover %d" n
        | FrameDig n -> sprintf "frame_dig %d" n
        | Add -> "+"
        | Sub -> "-"
        | Mul -> "*"
        | Div -> "/"
        | Mod -> "%"
        | Exp -> "exp"
        | Sqrt -> "sqrt"
        | BOr -> "|"
        | BAnd -> "&"
        | BNot -> "~"
        | BXor -> "^"
        | Shl -> "shl"
        | Shr -> "shr"
        | Not -> "!"
        | And -> "&&"
        | Or -> "||"
        | Xor -> "^"    // non sono sicuro se questo sia corretto, ma in TEAL non esiste l'operatore XOR non-bitwise
        | Eq -> "=="
        | Neq -> "!="
        | Lt -> "<"
        | Le -> "<="
        | Gt -> ">"
        | Ge -> ">="
        | Switch ls -> sprintf "switch %s" (mappen_strings (fun (l : label) -> l.Value) " " ls)
        | B l -> sprintf "b %s" l.Value
        | Bnz l -> sprintf "bnz %s" l.Value
        | Bz l -> sprintf "bz %s" l.Value
        | Callsub l -> sprintf "callsub %s" l.Value
        | Retsub -> "retsub"
        | Load s -> sprintf "load %d" s
        | Store s -> sprintf "store %d" s
        | LoadS -> "loads"
        | StoreS -> "stores"
        | Global s -> sprintf "global %s" s
        | Txn s -> sprintf "txn %s" s
        | Txnas s -> sprintf "txnas %s" s
        | Txna (s, i) -> sprintf "txna %s %d" s i
        | ITxnBegin -> "itxn_begin"
        | ITxnField s -> sprintf "itxn_field %s" s
        | ITxnSubmit -> "itxn_submit"
        | Balance -> "balance"
        | MinBalance -> "min_balance"
        | AssetHoldingGet s -> sprintf "asset_holding_get %s" s
        | AssetParamsGet s -> sprintf "asset_params_get %s" s
        | AppLocalPut -> "app_local_put"
        | AppLocalGet -> "app_local_get"
        | AppLocalDel -> "app_local_del"
        | AppLocalGetEx -> "app_local_get_ex"
        | AppGlobalGet -> "app_global_get"
        | AppGlobalPut -> "app_global_put"
        | Assert -> "assert"
        | Itob -> "itob"
        | Btoi -> "btoi"
        | Len -> "len"
        | Extract (s, l)-> sprintf "extract %d %d" s l
        | Extract3 -> "extract3"
        | Concat -> "concat"
        | Err -> "err"
        | Proto (a, b) -> sprintf "proto %d %d" a b
        | Return -> "return"

    let pretty_program (prog: program) =
        (List.map (fun (op : opcode) -> sprintf "%s%s" (if op.IsLabel then "" else "\t") (pretty_opcode op)) prog |> List.filter (fun s -> s <> "") |> String.concat "\n") + "\n"




