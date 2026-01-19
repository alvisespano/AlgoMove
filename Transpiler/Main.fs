module AlgoMove.Transpiler.Main

open System
open System.IO
open Argu

type CLIArgs =
    | [<MainCommand; ExactlyOnce>] Input of path:string
    | [<AltCommandLine("-I")>] Include of path:string

    interface IArgParserTemplate with
        member s.Usage =
            match s with
            | Input _ -> "input Move bytecode file"
            | Include _ -> "add an include/search path for libraries and imports"

[<EntryPoint>]
let main argv =
    let parser = ArgumentParser.Create<CLIArgs>(programName = "algomovetranspiler")
    let results = parser.Parse(argv, raiseOnUsage = false)

    // show usage if no main command provided or usage requested
    if results.IsUsageRequested || results.TryGetResult(CLIArgs.Input).IsNone then
        printfn "%s" (parser.PrintUsage ())
        0
    else
        let input = results.GetResult CLIArgs.Input
        let paths = Path.GetDirectoryName input :: results.GetResults CLIArgs.Include

        Report.debug "include paths: %A" paths

        try
            let mprg = Parsing.load_and_parse_module paths input
            let tprg = Gen.generate_program paths mprg
            let output = Path.ChangeExtension (input, ".teal")
            Report.info "saving output TEAL file: %s" output
            File.WriteAllText (output, tprg)
            0
        with
        | Parsing.SyntaxError (msg, lexbuf) ->
            let u = lexbuf.EndPos
            Report.error "%s:%d:%d-%d: syntax error: %s (lexbuffer: %A)"
                (IO.Path.GetFileName u.FileName) u.Line lexbuf.StartPos.Column u.Column msg lexbuf.Lexeme
            1
        #if !DEBUG
        | e ->
            Report.error "\nexception caught: %O" e
            1
        #endif


