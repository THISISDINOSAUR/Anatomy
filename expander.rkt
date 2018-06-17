#lang br/quicklang

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(define-macro (a-module-begin (a-program LINE ...))
   (write #'(LINE ...))
  #'(#%module-begin
     LINE ...))
(provide (rename-out [a-module-begin #%module-begin]))

(define-macro (a-variable-definition ID VAL) #'(define ID VAL))

(define-macro-cases a-sum
  [(_ VAL) #'VAL]
  [(_ LEFT "+" RIGHT) #'(+ LEFT RIGHT)]
  [(_ LEFT "-" RIGHT) #'(- LEFT RIGHT)])

(define-macro-cases a-product
  [(_ VAL) #'VAL]
  [(_ LEFT "*" RIGHT) #'(* LEFT RIGHT)]
  [(_ LEFT "/" RIGHT) #'(/ LEFT RIGHT 1.0)] ;TODO: do I want a 1.0 to force a floating-point result here?
  [(_ LEFT "mod" RIGHT) #'(modulo LEFT RIGHT)])

(define-macro-cases a-neg
  [(_ VAL) #'VAL]
  [(_ "-" VAL) #'(- VAL)])

(define-macro-cases a-expt
  [(_ VAL) #'VAL]
  [(_ LEFT "^" RIGHT) #'(expt LEFT RIGHT)])