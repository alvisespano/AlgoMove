
module AlgoMove.Transpiler.Report

open FSharp.Common.Log

let private L = 
    let r = new console_logger ()
    r.cfg.show_datetime <- false
    r.cfg.all_thresholds <- Low 
    r

let error fmt = L.fatal_error fmt

let warn fmt = L.warn Normal fmt

let info fmt = L.msg Normal fmt


