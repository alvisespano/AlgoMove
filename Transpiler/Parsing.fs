
module AlgoMove.Transpiler.Parsing

open FSharp.Common.Parsing
open System
open FSharp.Text
open AlgoMove.Transpiler

exception SyntaxError of string * Lexing.LexBuffer<char>


let private __syntax_error (msg, lexbuf : Lexing.LexBuffer<char>) = SyntaxError (msg, lexbuf) //new syntax_error (msg, lexbuf)
let parse_from_TextReader args = parse_from_TextReader __syntax_error args

let mutable private cwd = IO.Directory.GetCurrentDirectory ()

let load_and_parse_module filename =
    let filename = sprintf "%s/%s" cwd filename
    use fstr = new IO.FileStream (filename, IO.FileMode.Open)
    use rd = new IO.StreamReader (fstr)
    cwd <- IO.Path.GetDirectoryName filename
    Report.info "parsing source file '%s'..." filename
    parse_from_TextReader rd filename (1, 1) Parser.Module Lexer.tokenize Parser.tokenTagToTokenId
