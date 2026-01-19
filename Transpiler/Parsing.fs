
module AlgoMove.Transpiler.Parsing

open FSharp.Common.Parsing
open System
open FSharp.Text
open AlgoMove.Transpiler
open System.IO

exception SyntaxError of string * Lexing.LexBuffer<char>


let private __syntax_error (msg, lexbuf : Lexing.LexBuffer<char>) = SyntaxError (msg, lexbuf) //new syntax_error (msg, lexbuf)
let parse_from_TextReader args = parse_from_TextReader __syntax_error args


let load_and_parse_module paths filename =
    let cwd = IO.Directory.GetCurrentDirectory ()
    let paths = cwd :: paths
    let f path =
        let filename = sprintf "%s/%s" path filename
        try
            use fstr = new IO.FileStream (filename, IO.FileMode.Open)
            use rd = new IO.StreamReader (fstr)
            Report.info "parsing source file '%s'..." filename
            Some <| parse_from_TextReader rd filename (1, 1) Parser.Module Lexer.tokenize Parser.tokenTagToTokenId
        with _ -> Report.debug "file '%s' not found in from path '%s', trying next..." filename path; None
    match paths |> List.tryPick f with
    | Some r -> r
    | None -> raise (FileNotFoundException (sprintf "could not find source file '%s' in any of the provided paths" filename))