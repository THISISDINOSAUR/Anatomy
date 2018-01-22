#lang brag
;TODO: can probably make things optionally 3D
a-program : [a-line] (/NEWLINE [a-line])*
a-line : a-bone-definition | a-connection-definition | a-parameters-definition

a-parameters-definition : "Parameters" /"=" /"{" [a-parameter-definition] ([/NEWLINE]*  [/"," a-parameter-definition])* /"}"
a-parameter-definition : a-id /":" a-expr /"..." a-expr /"=" a-expr  

a-bone-definition : a-id /"=" a-bone
a-bone : a-point-expr [/"," a-point-expr]*

a-connection-definition : a-id /"~" a-id /"=" a-connection
a-connection : a-point-expr /"~" a-point-expr /"," a-expr

@a-id : ID ;TODO: probably need to seperate this out into different types

a-expr : a-sum
a-sum : [a-sum ("+"|"-")] a-product
a-product : [a-product ("*"|"/"|"mod")] a-neg
a-neg : ["-"] a-expt
a-expt : [a-expt "^"] a-value
@a-value : a-number | a-id | /"(" a-expr /")" ;TODO: as written, this could allow bones (or other things associated with identifiers)
a-number : INTEGER | DECIMAL

;allowed point expressions: sum, subtract, unary negation, scaler multiplication
;TODO: point functions (inc. last)
a-point-expr: a-point-sum
a-point-sum: [a-point-sum ("+"|"-")] a-point-product
a-point-product : a-expr * a-point-neg | a-point-neg * a-expr
a-point-neg : ["-"] a-point-value
a-point-value : a-point | a-id | /"(" a-point-expr /")" ;TODO: numbers and stuff could sneak in as a-id
a-point : /"[" a-expr /"," a-expr /"]"

;todo transformations, variables, trapesium, parameters, comments, duplicates?, sections (with scaling)