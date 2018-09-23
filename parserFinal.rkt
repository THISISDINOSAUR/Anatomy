#lang brag

;This is the complete parser, which is seperated from parser.rkt in order to build up the language gradually

;TODO: extend print to all types, connections strings etc.
;todo colourer
;todo better errors?
;repl?
a-program : [a-line] (NEWLINE [a-line])*
a-line : [a-definition | a-transformation] [a-comment]

a-definition : a-bone-definition | a-connection-definition | a-parameters-definition | a-section-definition | a-variable-definition

a-parameters-definition : "Parameters" /"=" /"{" [a-parameter-definition] ([/NEWLINE] [/"," a-parameter-definition])* /"}"
a-parameter-definition : a-variable-id /":" a-expr /".." a-expr /"=" a-expr  

a-bone-definition : a-bone-id /"=" a-bone
a-bone : a-point-expr [/"," a-point-expr]* ;todo: seperate point list

a-connection-definition : a-bone-id /"~" a-bone-id /"=" a-connection
a-connection : a-point-expr /"~" a-point-expr /"," a-expr

a-section-definition : a-section-id /"=" /"{" [a-bone-id] ([/NEWLINE] [/"," a-bone-id])* /"}"

a-variable-definition : "var " a-variable-id /"=" a-expr

a-transformation : a-transformation-dimension | a-transformation-point
a-transformation-dimension : a-bone-range /"." ("x"|"y") ("+"|"-"|"*"|"/"|"^") /"=" a-expr
a-transformation-point : a-transformation-point-point | a-transformation-point-scaler
a-transformation-point-point: a-bone-range ("+"|"-") /"=" a-point-expr
a-transformation-point-scaler : a-bone-range ("*"|"/") /"=" a-expr
a-bone-range : a-bone-id /"[" a-integer-range /"]"
a-integer-range: INTEGER /".." INTEGER

;these probably don't need to be seperate as far as implementation is concerned, but I think it makes it conceptually easier to understand
a-variable-id : ID
a-bone-id : ID
a-point-id : ID
a-section-id : ID

a-expr : a-sum
a-sum : [a-sum ("+"|"-")] a-product
a-product : [a-product ("*"|"/"|"mod")] a-neg
a-neg : ["-"] a-expt
a-expt : [a-expt "^"] a-value
@a-value : a-number | a-variable-id | /"(" a-expr /")"
a-number : INTEGER | DECIMAL

;allowed point expressions: sum, subtract, unary negation, scaler multiplication
;TODO: point functions (inc. last)
a-point-expr: a-point-sum
a-point-sum: [a-point-sum ("+"|"-")] a-point-product
a-point-product : [a-expr ("*"|"/")] a-point-neg | a-point-neg [("*"|"/") a-expr] ;TODO make sure this enforces left-to-right evaluation
a-point-neg : ["-"] a-point-value
@a-point-value : a-point | a-point-id | /"(" a-point-expr /")"
a-point : /"[" a-expr /"," a-expr /"]"

a-point-index : INTEGER | "last"

;TODO: not sure if should implement functions in a general sense, or in specific cases (Since there are only a couple)
;functions currently are: average, trapesium, max, distanceBetween, scale
;avereage, takes a list of points, returns a point
;trapesium takes length, lentgh , height , height, returns list of points
;max, takes list of numbers/expressions, returns, num
;distance between takes two points, returns num
;scale takes two scalers (and arguably a section), and returns nothing (or arguably the scaled section)

;(should also at least add min)
; also sqrt?
;also mag of point? (essentially convinence for distanceBetween(point, [0,0]))

;I think I will have to treat them by return type, since that depends on where they will go. But otherwise, for now
;the parser should just know about each function individual, for the sake of simplicity
;at some point may want to see about allowing general racket functions, or even defining own functions
;a-func-call : a-func-id /"("
;a-func-id : 

@a-comment: /"//" [STRING]
;todo trapesium, duplicates?, section scaling, indexing/last