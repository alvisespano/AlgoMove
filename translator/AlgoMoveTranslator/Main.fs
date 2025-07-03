module AlgoMove.Transpiler.Main

open FSharp.Text
open System
open FSharp.Common.Parsing
open FSharp.Common.Log
open AlgoMove.Transpiler

let Log = printfn

exception SyntaxError of string * Lexing.LexBuffer<char>

let private __syntax_error (msg, lexbuf : Lexing.LexBuffer<char>) = SyntaxError (msg, lexbuf) //new syntax_error (msg, lexbuf)
let parse_from_TextReader args = parse_from_TextReader __syntax_error args

let load_and_parse_program filename =
   use fstr = new IO.FileStream (filename, IO.FileMode.Open)
   use rd = new IO.StreamReader (fstr)
   Log "parsing source file '%s'..." filename
   parse_from_TextReader rd filename (1, 1) Parser.program Lexer.tokenize Parser.tokenTagToTokenId

let parse_from_string what p s = parse_from_string __syntax_error s (sprintf "%s:\"%s\"" what s) (0, 0) p Lexer.tokenize Parser.tokenTagToTokenId


[<EntryPoint>]
let main argv =
    let r =
        try
            let mprg = load_and_parse_program "../../../../tests/borrow_field_order.mv.asm"
            Log "parsed Move program:\n\n%A" mprg
            let tprg = Gen.emit_program mprg
            Log "\n\ngenerated TEAL program:\n\n%s" (Absyn.Teal.pretty_program tprg)
            0
        with SyntaxError (msg, lexbuf) -> 
               let u = lexbuf.EndPos 
               Log "%s:%d:%d-%d: syntax error: %s" (IO.Path.GetFileName u.FileName) u.Line lexbuf.StartPos.Column u.Column msg
               1

             | e -> Log "\nexception caught: %O" e; 2

    Console.ReadLine () |> ignore
    r

