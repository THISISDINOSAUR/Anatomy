#lang br/quicklang

(provide (matching-identifiers-out #rx"^a-" (all-defined-out))
         (all-from-out "a-functions.rkt"
                       "a-maths.rkt"
                       "a-definitions.rkt"))

(require "point.rkt"
         "bone.rkt"
         "utils.rkt"
         "a-functions.rkt"
         "a-maths.rkt"
         "a-definitions.rkt"
         racket/syntax)

(define-macro (a-module-begin (a-program LINE ...))
  (with-pattern
      ([(ID ...) (find-unique-ids 'a-id #'(LINE ...))]
       [(PRESET-ID ...) (find-unique-ids 'a-preset-id #'(LINE ...))])
  #'(#%module-begin
     
     (provide ID ...)
     (define ID #f) ...

     (provide set-parameters!)
     (provide reset-parameters!)
     
     (define presets (list 'PRESET-ID ...))
     (provide presets)
     (provide a-print)
     
     (provide recalculate)
     (define (recalculate)
       LINE ...)
     LINE ...)))
(provide (rename-out [a-module-begin #%module-begin]))
(provide a-module-begin)

(begin-for-syntax
  (require racket/list)
  (define (find-unique-ids id-type line-stxs)
    (remove-duplicates
     (for/list ([stx (in-list (stx-flatten line-stxs))]
                #:when (syntax-property stx id-type))
       stx)
     #:key syntax->datum)))

(define-macro (set-parameters! ID VALS)
  (with-pattern ([PARAMETERS-ID (datum->syntax #'ID #'ID)])
  #'(for ([(param-id val) VALS])
      ((car (hash-ref (get-field setters PARAMETERS-ID) (append-symbols 'set- param-id))) val)
    )))

(define-macro (reset-parameters! ID)
  (with-pattern ([PARAMETERS-ID (datum->syntax #'ID #'ID)])
    #'(for ([(param-id val) (get-field parameters PARAMETERS-ID)])
        ((car (hash-ref (get-field setters PARAMETERS-ID) (append-symbols 'set- param-id)))
         (parameter-default val))
        )))

(define (a-print id)
  (cond
    [(or (is-a? id bone%) (is-a? id section%) (is-a? id parameters%))
     (display (send id description))]
    [(point? id)
     (display (describe-point id))
     (display "\n")]
    [else
     (write id)
     (display "\n")]))

(define-macro-cases a-bone-range-operation
  [(_ BONE-ID START-INDEX END-INDEX OPERATION POINT-EXPR)
   #'(send BONE-ID operation-on-range! OPERATION POINT-EXPR START-INDEX (resolve-index-of-bone BONE-ID END-INDEX))]
  [(_ BONE-ID INDEX OPERATION POINT-EXPR)
   #' (send BONE-ID operation-on-index! OPERATION POINT-EXPR (resolve-index-of-bone BONE-ID INDEX))])

(define-macro-cases a-operation-equals-point
  [(_ "+") #'add-points]
  [(_ "-") #'subtract-points]
  [(_) #'(lambda (x y) y)])

(define-macro-cases a-bone-range-single-dimension-operation
  [(_ BONE-ID START-INDEX END-INDEX DIMENSION OPERATION EXPR)
   #'(send BONE-ID operation-on-dimension-of-range! OPERATION DIMENSION EXPR START-INDEX (resolve-index-of-bone BONE-ID END-INDEX))]
  [(_ BONE-ID INDEX DIMENSION OPERATION EXPR)
   #' (send BONE-ID operation-on-dimension-of-index! OPERATION DIMENSION EXPR (resolve-index-of-bone BONE-ID INDEX))])

(define-macro-cases a-point-dimension
  [(_ "x") #'point-x]
  [(_ "y") #'point-y]
  [(_ "z") #'point-z])

(define-macro-cases a-operation-equals
  [(_ "+") #'+]
  [(_ "-") #'-]
  [(_ "*") #'*]
  [(_ "/") #'/]
  [(_) #'(lambda (x y) y)])

(define-macro-cases a-bone-scale
  [(_ BONE-ID X Y) #'(send BONE-ID scale! X Y 1)]
  [(_ BONE-ID X Y Z) #'(send BONE-ID scale! X Y Z)])

(define-macro-cases a-section-operation
  [(_ SECTION-ID X Y) #'(send SECTION-ID scale! X Y 1)]
  [(_ SECTION-ID X Y Z) #'(send SECTION-ID scale! X Y Z)])

(define (resolve-index-of-bone bone-id index)
  (match index
    [(== "last")
     (last-index-of-bone bone-id)]
    [_
     index]))

(define (last-index-of-bone bone-id)
  (- (length (vector->list (get-field points bone-id))) 1))

(define (a-point-from-bone-index bone-id index)
  (match index
    [(== "last")
     (last (vector->list (get-field points bone-id)))]
    [_
     (send bone-id point-at-index index)]))



