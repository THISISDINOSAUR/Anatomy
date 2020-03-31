#lang br

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(require "../structs/point.rkt"
         "../bone.rkt"
         "../section.rkt"
         "../parameter.rkt"
         "../utils.rkt")

(define-macro (a-variable-definition ID VAL) #'(set! ID VAL))
(define-macro (a-point-definition ID VAL) #'(set! ID VAL))
(define-macro (a-parameters-definition ID VAL) #'(set! ID VAL))
(define-macro (a-preset-definition ID VAL) #'(set! ID VAL))
(define-macro (a-bone-definition ID VAL)
  #'(begin
      (set! ID VAL)
      (set-field! name ID (~a 'ID))
      ))

(define-macro (a-section-definition ID VAL)
  #' (begin
      (set! ID VAL)
      (set-field! name ID (~a 'ID))))

(define-macro (a-connection-definition BONE-ID1 BONE-ID2 POINT-EXPR-OR-FUNC1 POINT-EXPR-OR-FUNC2 ANGLE)
  #'(send BONE-ID1 add-connection!
          BONE-ID2
          (POINT-EXPR-OR-FUNC1 BONE-ID1)
          (POINT-EXPR-OR-FUNC2 BONE-ID2)
          ANGLE))

(define-macro-cases a-point
  [(a-point X Y) #'(point X Y 0)]
  [(a-point X Y Z) #'(point X Y Z)])

(define-macro (a-points-list VAR ...) #'(list VAR ...))

(define (a-bone points-list)
  (new bone%
       [points (list->vector points-list)]))

(define-macro (a-parameters PARAMETER ...)
  #'(new parameters%
           [parameters (make-hash
                        (list (cons (car (car PARAMETER))
                                    (cadr (car PARAMETER))) ...))]
           [setters (make-hash
                     (list (cons (car (cdr PARAMETER))
                                 (cdr (cdr PARAMETER))) ...))]
           [ordering (list (car (car PARAMETER)) ...)]
           ))

(define-macro (a-parameter ID LOWER-BOUND UPPER-BOUND VAL)
  #'(begin
      (cond [(not ID) (set! ID VAL)])
      (list (list 'ID (parameter LOWER-BOUND UPPER-BOUND VAL))
            (append-symbols 'set- 'ID) (lambda (val) (set! ID val)))
      ))

(define-macro (a-preset PRESET-VALUES ...)
  #'(begin
      (hasheq PRESET-VALUES ...)))

(define-macro (a-preset-value-id ID)
  #''ID)

(define (a-section bones-list)
  (new section%
       [bones bones-list]))

(define-macro (a-bones-list BONE-IDS ...)
  #'(list BONE-IDS ...))

(define (a-bone-duplicate bone-id)
  (vector->list (get-field points bone-id)))


;Connection point evaluation
(define-macro (a-point-expr-with-bone POINT-EXPR)
  #'(lambda (bone) (expand-connection-point-expression POINT-EXPR bone)))

(define-macro-cases a-connection-point-average
  [(_ "all")
   #'(lambda (bone) (a-average-bone-points bone "all"))]
  [(_ POINT-EXPRS ...)
   #'(lambda (bone) (a-average-bone-points bone POINT-EXPRS ...))])


(define-macro (expand-connection-point-expressions POINT-EXPRS BONE)
  #'(map (lambda (expr)
           (expand-connection-point-expression expr BONE))
         POINT-EXPRS))

(define-macro-cases a-average-bone-points
  [(_ BONE-ID "all")
   #'(average-points (vector->list (get-field points BONE-ID)))]
  [(_ BONE-ID POINT-EXPRS ...)
   #'(average-points (expand-connection-point-expressions (list POINT-EXPRS ...) BONE-ID))])

(define (expand-connection-point-expression point-expr bone)
  (match point-expr
    [(== "last")
     (last (vector->list (get-field points bone)))]
    [(? number?)
     (vector-ref (get-field points bone) point-expr)]
    [_
     point-expr]
    ))
