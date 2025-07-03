module AlgoMove.Transpiler.Absyn

open System

type label = string

module Move =

    type id = string
    type qid = id list
    type address = string

    type ty = Bool | U64 | Address | StructName of id | Ref of ty | MutRef of ty 

    type field = id * ty
    type arg = field

    type qual = Public | Entry

    type capab = Key | Store | Copy | Drop

    type index = byte

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
        | Call of id * ty list * ty option
        | ReadRef
        | WriteRef
        | FreezeRef
        | LdBool of bool
        | LdU8 of byte
        | LdU64 of uint64
        | LdU128 of UInt128
        | LdConst of index
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

    type instr = label * opcode

    type Fun = { quals : qual list; id : id; args : arg list; ret : ty option; body : instr list }

    type Struct = { id : id; capabs : capab list; fields : field list }

    type program = { qid : qid; structs : Struct list; funs : Fun list }


module Teal =
   
    type scratch = uint8

    type opcode =
        | UnsupportedOpcode of Move.opcode

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

        // Storage/State
        | Load of scratch
        | Store of scratch
        | LoadS
        | StoreS

        // Global/Txn
        | Global of string
        | Txn of string
        | Txna of string * int
        | ITxnBegin
        | ITxnField of string
        | ITxnSubmit

        // Account/Asset/App
        | Balance
        | MinBalance
        | AssetHoldingGet of string * int
        | AppLocalGet
        | AppGlobalGet
        | AppLocalPut
        | AppGlobalPut

        // Misc
        | Assert
        | Itob
        | Btoi
        | Len
        | GetByte
        | SetByte
        | Substring
        | Substring3
        | Concat
        | Err
        | Proto of uint * uint
        | Return


    type instr = label option * opcode

    type program = instr list

    let pretty_opcode (op: opcode) : string =
        match op with
        | UnsupportedOpcode m -> sprintf "UNSUPPORTED(%A)" m
        | PushInt n -> sprintf "pushint %A" n
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
        | B l -> sprintf "b %s" l
        | Bnz l -> sprintf "bnz %s" l
        | Bz l -> sprintf "bz %s" l
        | Callsub l -> sprintf "callsub %s" l
        | Retsub -> "retsub"
        | Load s -> sprintf "load %d" s
        | Store s -> sprintf "store %d" s
        | LoadS -> "loads"
        | StoreS -> "stores"
        | Global s -> sprintf "global %s" s
        | Txn s -> sprintf "txn %s" s
        | Txna (s, i) -> sprintf "txna %s %d" s i
        | ITxnBegin -> "itxn_begin"
        | ITxnField s -> sprintf "itxn_field %s" s
        | ITxnSubmit -> "itxn_submit"
        | Balance -> "balance"
        | MinBalance -> "min_balance"
        | AssetHoldingGet (s, i) -> sprintf "asset_holding_get %s %d" s i
        | AppLocalGet -> "app_local_get"
        | AppGlobalGet -> "app_global_get"
        | AppLocalPut -> "app_local_put"
        | AppGlobalPut -> "app_global_put"
        | Assert -> "assert"
        | Itob -> "itob"
        | Btoi -> "btoi"
        | Len -> "len"
        | GetByte -> "getbyte"
        | SetByte -> "setbyte"
        | Substring -> "substring"
        | Substring3 -> "substring3"
        | Concat -> "concat"
        | Err -> "err"
        | Proto (a, b) -> sprintf "proto %d %d" a b
        | Return -> "return"

    let pretty_instr ((lbl, op): instr) : string =
        match lbl with
        | Some l -> sprintf "%s: %s" l (pretty_opcode op)
        | None -> pretty_opcode op

    let pretty_program (prog: program) : string =
        prog
        |> List.map pretty_instr
        |> String.concat "\n"




