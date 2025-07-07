module AlgoMove.Transpiler.Absyn

open System


module Move =

    type id = string
    type qid = id list * id
    type address = string
    type label = uint


    [<RequireQualifiedAccess>]
    type ty = 
        | Bool
        | U8
        | U64
        | U128
        | Address
        | Typename of id
        | Ref of ty
        | MutRef of ty 
        | Tuple of ty list
        | Cons of id * ty   // only types of LdConst use this

    type field = id * ty
    type arg = field

    type qual = Public | Entry | Native

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
        | Call of qid * ty list * ty option
        | ReadRef
        | WriteRef
        | FreezeRef
        | LdBool of bool
        | LdU8 of byte
        | LdU64 of uint64
        | LdU128 of UInt128
        | LdConst of ty * int list
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

    //type instr = label * opcode

    type Fun = { quals : qual list; id : id; args : arg list; ret : ty option; body : opcode array }

    type Struct = { id : id; capabs : capab list; fields : field list }

    type program = { modulename : qid; imports: qid list; structs : Struct list; funs : Fun list }


module Teal =
   
    type scratch = uint8
    type label = string Lazy

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
        | Concat
        | Err
        | Proto of uint * uint
        | Return


    type instr = label option * opcode

    type program = instr list

    let pretty_opcode (op: opcode) : string =
        match op with
        | UnsupportedOpcode m -> sprintf "UNSUPPORTED(%A)" m
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
        | Txna (s, i) -> sprintf "txna %s %d" s i
        | ITxnBegin -> "itxn_begin"
        | ITxnField s -> sprintf "itxn_field %s" s
        | ITxnSubmit -> "itxn_submit"
        | Balance -> "balance"
        | MinBalance -> "min_balance"
        | AssetHoldingGet (s, i) -> sprintf "asset_holding_get %s %d" s i
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
        | Concat -> "concat"
        | Err -> "err"
        | Proto (a, b) -> sprintf "proto %d %d" a b
        | Return -> "return"

    let pretty_instr ((lbl, op): instr) : string =
        let op = pretty_opcode op
        match lbl with
        | Some l when l.IsValueCreated -> sprintf "%s:\n\t%s" l.Value op
        | _ -> sprintf "\t%s" op

    let pretty_program (prog: program) : string =
        prog
        |> List.map pretty_instr
        |> String.concat "\n"




