#lang brag

a-program : [a-line] (/NEWLINE [a-line])*
@a-line : [a-definition] [a-comment]

@a-definition : a-variable-definition
 


a-variable-definition : /"var" a-variable-id /"=" a-expr

@a-variable-id : ID

@a-expr : a-sum
a-sum : [a-sum ("+"|"-")] a-product
a-product : [a-product ("*"|"/"|"mod")] a-neg
a-neg : ["-"] a-expt
a-expt : [a-expt "^"] a-value
@a-value : a-number | a-variable-id | /"(" a-expr /")"
@a-number : INTEGER | DECIMAL


@a-comment: COMMENT
