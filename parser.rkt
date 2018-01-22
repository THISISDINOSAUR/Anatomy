#lang brag
;TODO: can probably make things optionally 3D
a-program : a-line (/NEWLINE a-line)*
a-line : [a-definition | a-transformation] [a-comment]

a-definition : a-bone-definition | a-connection-definition | a-parameters-definition | a-section-definition | a-variable-definition

a-parameters-definition : "Parameters" /"=" /"{" [a-parameter-definition] ([/NEWLINE] [/"," a-parameter-definition])* /"}"
a-parameter-definition : a-variable-id /":" a-expr /".." a-expr /"=" a-expr  

a-bone-definition : a-bone-id /"=" a-bone
a-bone : a-point-expr [/"," a-point-expr]*

a-connection-definition : a-bone-id /"~" a-bone-id /"=" a-connection
a-connection : a-point-expr /"~" a-point-expr /"," a-expr

a-section-definition : a-section-id /"=" /"{" [a-bone-id] ([/NEWLINE] [/"," a-bone-id])* /"}"

a-variable-definition : a-variable-id /"=" a-expr

a-transformation : a-transformation-dimension | a-transformation-point
a-transformation-dimension : a-bone-range /"." ("x"|"y") ("+"|"-"|"*"|"/"|"^") /"=" a-expr
a-transformation-point : a-transformation-point-point | a-transformation-point-scaler
a-transformation-point-point: a-bone-range ("+"|"-") /"=" a-point-expr
a-transformation-point-scaler : a-bone-range ("*"|"/") /"=" a-expr
a-bone-range : a-bone-id /"[" a-integer-range /"]"
a-integer-range: INTEGER /".." INTEGER

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
a-point-product : a-expr ("*"|"/") a-point-neg | a-point-neg ("*"|"/") a-expr
a-point-neg : ["-"] a-point-value
@a-point-value : a-point | a-point-id | /"(" a-point-expr /")"
a-point : /"[" a-expr /"," a-expr /"]"

@a-comment: /"//" [STRING]
;todo variables, trapesium, duplicates?, section scaling