
module AlgoMove.Transpiler.Report

open FSharp.Common.Log
open System

let private L = 
    let r = new console_logger ()
    r.cfg.show_datetime <- false
    #if DEBUG
    r.cfg.all_thresholds <- Low 
    #else
    r.cfg.msg_header <- ""
    r.cfg.all_thresholds <- Low 
    r.cfg.debug_threshold <- Unmaskerable
    #endif
    r

let error fmt = L.fatal_error fmt

let warn fmt = L.warn Normal fmt

let info fmt = L.msg Normal fmt

let debug fmt = L.debug Normal fmt

