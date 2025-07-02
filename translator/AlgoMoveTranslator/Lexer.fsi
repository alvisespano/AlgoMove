module AlgoMoveTranspiler.Lexer

open System
open FSharp.Text.Lexing
open FSharp.Common.Parsing
open FSharp.Common.Parsing.LexYacc
open AlgoMoveTranspiler.Absyn
open AlgoMoveTranspiler.Parser/// Rule blockcomment
val blockcomment: lexbuf: LexBuffer<char> -> token
/// Rule linecomment
val linecomment: lexbuf: LexBuffer<char> -> token
/// Rule tokenize
val tokenize: lexbuf: LexBuffer<char> -> token
