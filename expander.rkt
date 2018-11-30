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

(define (a-print id)
  (cond
    [(or (is-a? id bone%) (is-a? id section%))
     (display (send id description))]
    [(point? id)
     (display (describe-point id))
     (display "\n")]
    [else
     (write id)
     (display "\n")]))

(define-macro-cases a-bone-range-operation
  [(_ BONE-ID START-INDEX END-INDEX OPERATION POINT-EXPR)
   #'(send BONE-ID operation-on-range! OPERATION POINT-EXPR START-INDEX END-INDEX)]
  [(_ BONE-ID INDEX OPERATION POINT-EXPR)
   #' (send BONE-ID operation-on-index! OPERATION POINT-EXPR INDEX)])

(define-macro-cases a-operation-equals-point
  [(_ "+") #'add-points]
  [(_ "-") #'subtract-points])

(define-macro-cases a-bone-range-single-dimension-operation
  [(_ BONE-ID START-INDEX END-INDEX DIMENSION OPERATION EXPR)
   #'(send BONE-ID operation-on-dimension-of-range! OPERATION DIMENSION EXPR START-INDEX END-INDEX)]
  [(_ BONE-ID INDEX DIMENSION OPERATION EXPR)
   #' (send BONE-ID operation-on-dimension-of-index! OPERATION DIMENSION EXPR INDEX)])

(define-macro-cases a-point-dimension
  [(_ "x") #'point-x]
  [(_ "y") #'point-y]
  [(_ "z") #'point-z])

(define-macro-cases a-operation-equals
  [(_ "+") #'+]
  [(_ "-") #'-]
  [(_ "*") #'*]
  [(_ "/") #'/])

(define-macro-cases a-bone-scale
  [(_ BONE-ID X Y) #'(send BONE-ID scale! X Y 1)]
  [(_ BONE-ID X Y Z) #'(send BONE-ID scale! X Y Z)])

(define-macro-cases a-section-operation
  [(_ SECTION-ID X Y) #'(send SECTION-ID scale! X Y 1)]
  [(_ SECTION-ID X Y Z) #'(send SECTION-ID scale! X Y Z)])

(define (a-point-from-bone-index bone-id index)
  (match index
    [(== "last")
     (last (vector->list (get-field points bone-id)))]
    [_
     (send bone-id point-at-index index)]))

(define-macro (a-variable-definition ID VAL) #'(set! ID VAL))
(define-macro (a-point-definition ID VAL) #'(set! ID VAL))
(define-macro (a-bone-definition ID VAL)
  #'(begin
      (set! ID VAL)
      (set-field! name ID (~a 'ID))
      ))

(define-macro (a-section-definition ID VAL)
  #' (begin
      (set! ID VAL)
      (set-field! name ID (~a 'ID))))

(define (a-section bones-list)
  (new section%
       [bones bones-list]))

(define-macro (a-bones-list BONE-IDS ...)
  #'(list BONE-IDS ...))


(define-macro (a-connection-definition BONE-ID1 BONE-ID2 POINT-EXPR-OR-FUNC1 POINT-EXPR-OR-FUNC2 ANGLE)
  #'(send BONE-ID1 add-connection! BONE-ID2
          (connection
           (POINT-EXPR-OR-FUNC1 BONE-ID1)
           (POINT-EXPR-OR-FUNC2 BONE-ID2)
           ANGLE)))

(define-macro (a-point-expr-with-bone POINT-EXPR)
  #'(lambda (bone) (expand-connection-point-expression POINT-EXPR bone)))


(define-macro-cases a-connection-point-function 
  [(_ FUNC-ID "all")
   #'(lambda (bone) (FUNC-ID (vector->list (get-field points bone))))]
  [(_ FUNC-ID POINT-EXPRS ...)
   #'(lambda (bone) (FUNC-ID (expand-connection-point-expressions (list POINT-EXPRS ...) bone)))])


(define-macro (expand-connection-point-expressions POINT-EXPRS BONE)
  #'(map (lambda (expr)
           (expand-connection-point-expression expr BONE))
         POINT-EXPRS))

(define-macro-cases a-average-bone-points
  [(_ BONE-ID "all")
   #'(average-points (vector->list (get-field points BONE-ID)))]
  [(_ BONE-ID POINT-EXPRS ...)
   #'(average-points (expand-connection-point-expressions (list POINT-EXPRS ...) BONE-ID))])

(define (a-bone-duplicate bone-id)
  (get-field points bone-id))

(define (a-trapesium topSpan bottomSpan leftSpan rightSpan)
  (list->vector (trapesium topSpan bottomSpan leftSpan rightSpan)))

(define-macro (a-function-id)
  #'average-points)

(define-macro (a-max VALS ...)
  #'(max VALS ...))

(define-macro (a-min VALS ...)
  #'(min VALS ...))

(define (a-abs val)
  (abs val))

(define (a-distance point1 point2)
  (distance-between-points point1 point2))

(define (a-sqrt val)
  (sqrt val))

(define (a-mag point)
  (distance-between-points point point-zero))

(define-macro (a-average-points POINT-EXPRS ...)
  #'(average-points (list POINT-EXPRS ...)))

(define (expand-connection-point-expression point-expr bone)
  (match point-expr
    [(== "last")
     (last (vector->list (get-field points bone)))]
    [(? number?)
     (vector-ref (get-field points bone) point-expr)]
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

(define-macro (a-points-list VAR ...) #'(vector VAR ...))

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
