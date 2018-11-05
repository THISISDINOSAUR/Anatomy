#lang br/quicklang

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(require "point.rkt"
         "bone.rkt"
         racket/syntax)

(define-macro (a-module-begin (a-program LINE ...))
  (with-pattern
      ([(ID ...) (find-unique-ids #'(LINE ...))])
  #'(#%module-begin
     (define ID #f) ...
     LINE ...)))
(provide (rename-out [a-module-begin #%module-begin]))

(begin-for-syntax
  (require racket/list)
  (define (find-unique-ids line-stxs)
    (remove-duplicates
     (for/list ([stx (in-list (stx-flatten line-stxs))]
                #:when (syntax-property stx 'a-id))
       stx)
     #:key syntax->datum)))

(define-macro (a-print BONE-ID) #'(display (send BONE-ID description)))

(define-macro (a-variable-definition ID VAL) #'(set! ID VAL))
(define-macro (a-point-definition ID VAL) #'(set! ID VAL))
(define-macro (a-bone-definition ID VAL)
  #'(begin
      (set! ID VAL)
      (set-field! name ID (~a 'ID))
      ))

(define-macro (a-connection-definition BONE-ID1 BONE-ID2 POINT-EXPR-OR-FUNC1 POINT-EXPR-OR-FUNC2 ANGLE)
  #'(begin
      ;(write 'POINT-EXPR-OR-FUNC1)
  (send BONE-ID1 add-connection BONE-ID2
          (connection
           (POINT-EXPR-OR-FUNC1 BONE-ID1)
            (POINT-EXPR-OR-FUNC2 BONE-ID2)
           ;(expand-connection-point-expression POINT-EXPR1 BONE-ID1)
           ;(expand-connection-point-expression POINT-EXPR2 BONE-ID2)
           ANGLE))))

;(define-macro (a-connection-point-expr POINT-EXPR-OR-FUNC)
;  #'(lambda bone (apply POINT-EXPR-OR-FUNC bone)))

(define-macro (a-point-expr-with-bone POINT-EXPR)
  #'(lambda bone (apply expand-connection-point-expression POINT-EXPR bone)))

(define-macro (a-connection-point-function FUNC-ID POINT-EXPRS ...)
  #'(begin
      (lambda bone (FUNC-ID (expand-connection-point-expressions '(POINT-EXPRS ...) bone)))))

(define-macro (expand-connection-point-expressions POINT-EXPRS BONE)
  #'(map (lambda (expr)
           (apply expand-connection-point-expression expr BONE))
         POINT-EXPRS))

(define-macro (a-function-id)
  #'average)

(define (average points)
  (add-point points))


;(define-macro-cases expand-connection-point-expr-or-func
;  [(BONE-ID VAL) #'(expand-connection-point-expression VAL BONE-ID)]
;  [(BONE-ID FUNCTION-ID POINT-EXPRS ...) #'(FUNCTION-ID (expand-connection-point-expression POINT-EXPRS ... BONE-ID))])
                                ;(map (lambda (point-expr)
                                    ;   (expand-connection-point-expression point-expr BONE-ID))
                                    ; ...))])
;(define-macro (expand-connection-point-expr-or-func EXPR BONE-ID)
;  #'(begin
;      (write EXPR) 
;             (expand-connection-point-expression EXPR BONE-ID)))
  ;[(BONE-ID VAL) #'(expand-connection-point-expression VAL BONE-ID)]
  ;[(BONE-ID FUNCTION-ID POINT-EXPRS ...) #'(FUNCTION-ID (expand-connection-point-expression POINT-EXPRS ... BONE-ID))])


(define (expand-connection-point-expression point-expr bone)
  (match point-expr
    [(== "last")
     (last (get-field points bone))]
    [(? number?)
     (list-ref (get-field points bone) point-expr)]
    [_
     point-expr]
    ))

(define-macro (a-parameters-definition ID PARAMETER ...)
  #'(begin
      (set! ID (make-hash))
      (hash-set! ID (car PARAMETER) (cdr PARAMETER)) ...
      ))

(define-macro (a-parameter-definition ID LOWER-BOUND UPPER-BOUND VAL)
  #'(begin
      (set! ID VAL)
      '(ID (parameter LOWER-BOUND UPPER-BOUND VAL))
      ))

(define (a-bone point-list)
  (new bone%
       [points point-list]))

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


(define-macro-cases a-point
  [(a-point X Y) #'(point X Y 0)]
  [(a-point X Y Z) #'(point X Y Z)])

(define-macro (a-points-list VAR ...) #'(list VAR ...))

(define-macro-cases a-point-sum
  [(_ VAL) #'VAL]
  [(_ LEFT "+" RIGHT) #'(add-points LEFT RIGHT)]
  [(_ LEFT "-" RIGHT) #'(subtract-points LEFT RIGHT)])

(define-macro-cases a-point-product-left
  [(_ VAL) #'VAL]
  [(_ SCALE "*" POINT) #'(scale-point POINT SCALE)])

(define-macro-cases a-point-product-right
  [(_ VAL) #'VAL]
  [(_ POINT "*" SCALE) #'(scale-point POINT SCALE)]
  [(_ POINT "/" SCALE) #'(scale-point POINT (/ 1 SCALE))])

(define-macro-cases a-point-neg
  [(_ VAL) #'VAL]
  [(_ "-" VAL) #'(negate-point VAL)])