#lang racket

(provide (all-defined-out))

(require "point.rkt")

(define indent "  ")

(define bone%
  (class object%

    (init-field
     [points #f]
     [connections (make-hash)]
     [name ""])

    (define/public (add-connection! bone connection)
      (hash-set! connections bone connection))
    
    (define/public (remove-connection! bone)
      (hash-remove! connections bone))

    (define/public (point-at-index index)
      (vector-ref points index))

    (define/public (operation-on-index! op point index)
      (vector-set! points index (op (vector-ref points index) point)))

    (define/public (operation-on-range! op point start end)
      (for ([i (in-range start (+ end 1))])
        (operation-on-index! op point i)
        ))

    (define/public (operation-on-dimension-of-index! op dimension val index)
      (vector-set! points index
                   (operation-on-point-dimension op dimension (vector-ref points index) val)))
    
    (define/public (operation-on-dimension-of-range! op dimension val start end)
      (for ([i (in-range start (+ end 1))])
        (operation-on-dimension-of-index! op dimension val i)
        ))
    
    (define/public (description)
      (string-append
       name ":\n"
       indent "points:\n"
       indent indent (string-join
                      (map describe-point (vector->list points)) ", ") "\n"
       indent "connections:\n"
       indent indent (string-join
                       (map (lambda (bone-connection)
                              (string-append
                               name
                               " ~ "
                               (get-field name (car bone-connection))
                               " = "
                               (describe-connection (cdr bone-connection))))
                            (hash->list connections))
                       (string-append "\n" indent indent))
       "\n"))
      

    (super-new)
    ))

(struct connection (point-parent point-child angle)
  #:auto-value 0
  #:transparent
  #:mutable)

(define (describe-connection connection1)
  (string-append (describe-point (connection-point-parent connection1)) " ~ " (describe-point (connection-point-child connection1)) ", " (number->string (connection-angle connection1)) "°"))

(struct parameter (lower-bound upper-bound default)
  #:auto-value 0
  #:transparent
  #:mutable)
