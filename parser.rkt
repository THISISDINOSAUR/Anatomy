#lang brag

a-program : [a-line] (/NEWLINE [a-line])*
@a-line : [a-definition | a-operation | a-print] [a-comment]

a-print : /"print" (a-bone-id | a-variable-id | a-point-id | a-section-id)

@a-operation : a-bone-operation | a-section-operation

@a-bone-operation : a-bone-scale | a-bone-range-operation | a-bone-range-single-dimension-operation
a-bone-scale : a-section-id /"." /"scale" /"(" a-expr /"," a-expr [/"," a-expr] /")"
a-bone-range-operation : a-bone-range a-operation-equals-point a-point-expr
a-bone-range-single-dimension-operation : a-bone-range /"." a-point-dimension a-operation-equals a-expr

@a-bone-range : a-bone-id /"[" a-point-index [/":" a-point-index] /"]"

;TODO:
;duplicates with children? Duplicate section?
;probably not for now, without address the question of how to assign these things ids

;print expressions as well as ids?

@a-definition : a-variable-definition | a-point-definition | a-bone-definition | a-connection-definition | a-parameters-definition | a-section-definition

a-section-definition : a-section-id /"=" a-section
a-section : a-bones-list
a-bones-list : a-bone-id [/"," a-bone-id]+
a-section-operation : a-section-id /"." /"scale" /"(" a-expr /"," a-expr [/"," a-expr] /")"

a-parameters-definition : a-id /"=" /"{" [/NEWLINE]* a-parameter-definition (/"," [/NEWLINE]* a-parameter-definition)* [/NEWLINE]* /"}"
a-parameter-definition : a-variable-id /":" a-expr /">" /"<" a-expr /"=" a-expr

a-bone-definition : a-bone-id /"=" a-bone
a-bone : a-points-list | a-points-list-function
a-points-list : a-point-expr [/"," a-point-expr]+

@a-points-list-function : a-trapesium | a-bone-duplicate
a-trapesium : /"trapesium" /"(" a-expr /"," a-expr /"," a-expr /"," a-expr /")"
a-bone-duplicate : a-bone-id /"." /"duplicate"


a-connection-definition : a-bone-id /"~" a-bone-id /"=" a-connection
@a-connection : a-connection-point-expr /"~" a-connection-point-expr /"," a-expr

@a-connection-point-expr : a-point-expr-with-bone | a-connection-point-average
a-point-expr-with-bone : a-point-index | a-point-expr
a-connection-point-average : /"average" /"(" (((a-point-index | a-point-expr) [/"," (a-point-index | a-point-expr)]*) | "all") /")"

a-variable-definition : a-variable-id /"=" a-expr
a-point-definition : a-point-id /"=" a-point-expr

@a-variable-id : a-id
@a-bone-id : a-id
@a-point-id : a-id
@a-section-id : a-id
@a-id : ID

@a-expr : a-sum
a-sum : [a-sum ("+"|"-")] a-product
a-product : [a-product ("*"|"/"|"mod")] a-neg
a-neg : ["-"] a-expt
a-expt : [a-expt "^"] a-value
@a-value : a-number | a-variable-id | a-number-function | /"(" a-expr /")"
@a-number : INTEGER | DECIMAL

@a-number-function : a-max | a-min | a-abs | a-distance | a-sqrt | a-mag
a-max : /"max" /"(" a-expr [/"," a-expr]* /")"
a-min : /"min" /"(" a-expr [/"," a-expr]* /")"
a-abs : /"abs" /"(" a-expr /")"
a-distance : /"distanceBetween" /"(" a-point-expr /"," a-point-expr /")"
a-sqrt : /"sqrt" /"(" a-expr /")"
a-mag : /"mag" /"(" a-point-expr /")"

@a-point-expr: a-point-sum
a-point-sum: [a-point-sum ("+"|"-")] a-point-product-left
a-point-product-left : [a-expr ("*")] a-point-product-right
a-point-product-right : a-point-neg [("*"|"/") a-expr]
a-point-neg : ["-"] a-point-value
@a-point-value : a-point | a-point-id | a-point-from-bone-index | a-point-function | /"(" a-point-expr /")"
a-point : /"[" a-expr /"," a-expr [/"," a-expr] /"]" ;points can be specified in 2D or 3D

a-point-from-bone-index : a-bone-id /"[" a-point-index /"]"
@a-point-index : a-expr | "last"

@a-point-function : a-average-points | a-average-bone-points
a-average-points : /"average" /"(" a-point-expr [/"," a-point-expr]* /")"
a-average-bone-points : a-bone-id /"." /"average" /"(" (((a-point-index | a-point-expr) [/"," (a-point-index | a-point-expr)]*) | "all") /")"

a-operation-equals : ("+"|"-"|"*"|"/") /"="
a-operation-equals-point : ("+"|"-") /"="
a-point-dimension : "x" | "y" | "z"

@a-comment: COMMENT
