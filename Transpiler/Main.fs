module AlgoMove.Transpiler.Main

open FSharp.Text
open System
open FSharp.Common.Parsing
open FSharp.Common.Log
open AlgoMove.Transpiler

exception SyntaxError of string * Lexing.LexBuffer<char>

let private __syntax_error (msg, lexbuf : Lexing.LexBuffer<char>) = SyntaxError (msg, lexbuf) //new syntax_error (msg, lexbuf)
let parse_from_TextReader args = parse_from_TextReader __syntax_error args

let load_and_parse_program filename =
   use fstr = new IO.FileStream (filename, IO.FileMode.Open)
   use rd = new IO.StreamReader (fstr)
   Report.info "parsing source file '%s'..." filename
   parse_from_TextReader rd filename (1, 1) Parser.program Lexer.tokenize Parser.tokenTagToTokenId

let parse_from_string what p s = parse_from_string __syntax_error s (sprintf "%s:\"%s\"" what s) (0, 0) p Lexer.tokenize Parser.tokenTagToTokenId


[<EntryPoint>]
let main argv =
    let r =
        try
            let mprg = load_and_parse_program "tests/auction_with_item.mv.asm"
            Report.info "parsed Move program:\n\n%A" mprg
            let tprg = Gen.emit_program mprg
            Report.info "generated TEAL program:\n\n%s" (Absyn.Teal.pretty_program tprg)
            0
        with SyntaxError (msg, lexbuf) -> 
               let u = lexbuf.EndPos 
               Report.error "%s:%d:%d-%d: syntax error: %s (lexbuffer: %A)" (IO.Path.GetFileName u.FileName) u.Line lexbuf.StartPos.Column u.Column msg lexbuf.Lexeme
               1

             //| e -> Report.error "\nexception caught: %O" e; reraise ()

    Console.ReadLine () |> ignore
    r

