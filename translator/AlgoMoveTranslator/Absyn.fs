
module AlgoMoveTranspiler.Absyn

open FSharp.Text
open System

type id = string
type qid = id list
type label = id

type ty = Bool | U64 | Address

type field = id * ty
type arg = field

type qual = Public | Entry

type capab = Key | Store | Copy | Drop

type loc = uint64

type opcode = 
    | MovLoc of loc
    | CpyLoc of loc
    | StLoc of loc

type instr = label * opcode

type Fun = { quals : qual list; id : id; args : arg list; ret : ty option; body : instr list }

type Struct = { id : id; capabs : capab list; fields : field list }

type Module = { qid : qid; structs : Struct list; funs : Fun list }




