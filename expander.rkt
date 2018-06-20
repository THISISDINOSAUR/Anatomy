#lang br/quicklang

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(require "point.rkt")

(define-macro (a-module-begin (a-program LINE ...))
   (write #'(LINE ...))
  #'(#%module-begin
     LINE ...))
(provide (rename-out [a-module-begin #%module-begin]))

(define-macro (a-variable-definition ID VAL) #'(define ID VAL))
(define-macro (a-bone-definition ID VAL) #'(define ID VAL))

(define-macro-cases a-point
  [(a-point X Y) #'(point X Y 0)]
  [(a-point X Y Z) #'(point X Y Z)])

(define-macro (a-points-list VAR ...) #'(list VAR ...))

(define-macro-cases a-sum
  [(_ VAL) #'VAL]
  [(_ LEFT "+" RIGHT) #'(+ LEFT RIGHT)]
  [(_ LEFT "-" RIGHT) #'(- LEFT RIGHT)])

(define-macro-cases a-product
  [(_ VAL) #'VAL]
  [(_ LEFT "*" RIGHT) #'(* LEFT RIGHT)]
  [(_ LEFT "/" RIGHT) #'(/ LEFT RIGHT)]
  [(_ LEFT "mod" RIGHT) #'(modulo LEFT RIGHT)])

(define-macro-cases a-neg
  [(_ VAL) #'VAL]
  [(_ "-" VAL) #'(- VAL)])

(define-macro-cases a-expt
  [(_ VAL) #'VAL]
  [(_ LEFT "^" RIGHT) #'(expt LEFT RIGHT)])