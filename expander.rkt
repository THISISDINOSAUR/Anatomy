#lang br/quicklang

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(define-macro (a-module-begin (a-program LINE))
   (write #'(LINE))
  #'(#%module-begin
     LINE))
(provide (rename-out [a-module-begin #%module-begin]))

(define-macro (a-variable-definition ID VAL) #'(define ID VAL))
;(define-macro (a-line LINE) #'(LINE))