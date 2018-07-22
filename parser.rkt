#lang brag

a-program : [a-line] (/NEWLINE [a-line])*
@a-line : [a-definition | a-print] [a-comment]

a-print : /"print" a-bone-id

@a-definition : a-variable-definition | a-point-definition | a-bone-definition | a-connection-definition | a-parameters-definition

a-parameters-definition : a-id /"=" /"{" [/NEWLINE]* a-parameter-definition (/"," [/NEWLINE]* a-parameter-definition)* [/NEWLINE]* /"}"
a-parameter-definition : a-variable-id /":" a-expr /">" /"<" a-expr /"=" a-expr

a-bone-definition : a-bone-id /"=" a-bone
a-bone : a-points-list
a-points-list : a-point-expr [/"," a-point-expr]*

a-connection-definition : a-bone-id /"~" a-bone-id /"=" a-connection
a-connection : a-point-expr /"~" a-point-expr /"," a-expr

a-variable-definition : /"var" a-variable-id /"=" a-expr
a-point-definition : /"point" a-point-id /"=" a-point-expr

@a-variable-id : a-id
@a-bone-id : a-id
@a-point-id : a-id
@a-id : ID

@a-expr : a-sum
a-sum : [a-sum ("+"|"-")] a-product
a-product : [a-product ("*"|"/"|"mod")] a-neg
a-neg : ["-"] a-expt
a-expt : [a-expt "^"] a-value
@a-value : a-number | a-variable-id | /"(" a-expr /")"
@a-number : INTEGER | DECIMAL


@a-point-expr: a-point-sum
a-point-sum: [a-point-sum ("+"|"-")] a-point-product-left
a-point-product-left : [a-expr ("*")] a-point-product-right
a-point-product-right : a-point-neg [("*"|"/") a-expr]
a-point-neg : ["-"] a-point-value
@a-point-value : a-point | a-point-id | /"(" a-point-expr /")"
a-point : /"[" a-expr /"," a-expr [/"," a-expr] /"]" ;points can be specified in 2D or 3D


@a-comment: COMMENT
