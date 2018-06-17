#lang brag

a-program : [a-line] (/NEWLINE [a-line])*
@a-line : [a-definition] [a-comment]

@a-definition : a-variable-definition | a-bone-definition
 
a-bone-definition : a-bone-id /"=" a-bone
@a-bone : a-points-list
a-points-list : a-point [/"," a-point]*

a-variable-definition : /"var" a-variable-id /"=" a-expr

@a-variable-id : ID
@a-bone-id : ID
@a-point-id : ID

@a-expr : a-sum
a-sum : [a-sum ("+"|"-")] a-product
a-product : [a-product ("*"|"/"|"mod")] a-neg
a-neg : ["-"] a-expt
a-expt : [a-expt "^"] a-value
@a-value : a-number | a-variable-id | /"(" a-expr /")"
@a-number : INTEGER | DECIMAL


a-point-expr: a-point-sum
a-point-sum: [a-point-sum ("+"|"-")] a-point-product
a-point-product : [a-expr ("*"|"/")] a-point-neg | a-point-neg [("*"|"/") a-expr] ;TODO make sure this enforces left-to-right evaluation. TBH why  do I even allow this?
a-point-neg : ["-"] a-point-value
@a-point-value : a-point | a-point-id | /"(" a-point-expr /")"
a-point : /"[" a-expr /"," a-expr /"]"


@a-comment: COMMENT
