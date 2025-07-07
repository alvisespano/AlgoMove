module AlgoMove.Transpiler.Main

open System


[<EntryPoint>]
let main argv =
    let r =
        try
            let mprg = Parsing.load_and_parse_module "tests/auction_with_item.mv.asm"
            Report.info "parsed Move program:\n\n%A" mprg
            let tprg = Gen.emit_program mprg
            Report.info "generated TEAL program:\n\n%s" (Absyn.Teal.pretty_program tprg)
            0
        with Parsing.SyntaxError (msg, lexbuf) -> 
               let u = lexbuf.EndPos 
               Report.error "%s:%d:%d-%d: syntax error: %s (lexbuffer: %A)" (IO.Path.GetFileName u.FileName) u.Line lexbuf.StartPos.Column u.Column msg lexbuf.Lexeme
               1

             //| e -> Report.error "\nexception caught: %O" e; reraise ()

    Console.ReadLine () |> ignore
    r

