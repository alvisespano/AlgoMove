
module AlgoMoveTranspiler.Absyn

open FSharp.Text
open System

type id = string
type qid = id list
type label = string
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

type Module = { qid : qid; structs : Struct list; funs : Fun list }




