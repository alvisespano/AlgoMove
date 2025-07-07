module AlgoMove.Transpiler.Lexer

open System
open FSharp.Text.Lexing
open FSharp.Common.Parsing
open FSharp.Common.Parsing.LexYacc
open AlgoMove.Transpiler.Absyn
open AlgoMove.Transpiler.Parser/// Rule blockcomment
val blockcomment: lexbuf: LexBuffer<char> -> token
/// Rule linecomment
val linecomment: lexbuf: LexBuffer<char> -> token
/// Rule skip_generics
val skip_generics: lexbuf: LexBuffer<char> -> token
/// Rule tokenize
val tokenize: lexbuf: LexBuffer<char> -> token
