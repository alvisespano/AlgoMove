module AlgoMove.Transpiler.Main

open System
open System.IO


[<EntryPoint>]
let main argv =
    let r =
        if argv.Length < 1 then
            printfn "Usage: algomovetranspiler <filename>"
            0
        else
            let input = argv.[0]
            try
                let mprg = Parsing.load_and_parse_module input
                let tprg = Gen.generate_program mprg
                let output = Path.ChangeExtension (input, ".teal")
                Report.info "saving output TEAL file: %s" output
                File.WriteAllText (output, tprg)
                0
            with Parsing.SyntaxError (msg, lexbuf) -> 
                let u = lexbuf.EndPos 
                Report.error "%s:%d:%d-%d: syntax error: %s (lexbuffer: %A)" (IO.Path.GetFileName u.FileName) u.Line lexbuf.StartPos.Column u.Column msg lexbuf.Lexeme
                1
                #if !DEBUG
                | e -> Report.error "\nexception caught: %O" e; 1
                #endif
    #if DEBUG
    Console.ReadLine () |> ignore
    #endif
    r
