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
@a-connection : a-connection-point-expr /"~" a-connection-point-expr /"," a-expr
;connection point functions can have context sensitive point indicies, which is why they are seperate from just point functions
;the fact that these expressions can't be resolved without the context from the left side of a connection definition is something
;that complicates the expander.
;An alternative syntax of BONE-NAME.FUNCTION-NAME(POINT-INDEX) was considered, which would simplify the expander
;but would still mean there is redundant infomormation in a connection definition

;for the sake of flexibilty (E.g. doing maths like 'average + [20, 30]'), I think I should probaby change to the more general format above.
;also need to add a more general way of indexing points

;DO BOTH! If use short form, no maths for you, since it's ambigious
;e.g. does '[20, 30] * 2' mean times the third point, or times the number 2?
@a-connection-point-expr : a-point-expr-with-bone | a-connection-point-function
a-point-expr-with-bone : a-point-index | a-point-expr
a-connection-point-function : a-function-id /"(" (((a-point-index | a-point-expr) [/"," (a-point-index | a-point-expr)]*) | "all") /")"

a-variable-definition : /"var" a-variable-id /"=" a-expr
a-point-definition : /"point" a-point-id /"=" a-point-expr

@a-variable-id : a-id
@a-bone-id : a-id
@a-point-id : a-id
@a-id : ID

a-function-id : /"average"

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

@a-point-index : INTEGER | "last"

@a-comment: COMMENT
