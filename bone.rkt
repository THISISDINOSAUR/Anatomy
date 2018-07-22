#lang racket

(provide (all-defined-out))

(require "point.rkt")

(define bone%
  (class object%

    (init-field
     [points #f]
     [connections (make-hash)]
     [name ""])

    (define indent
      "  ")

    (define/public (add-connection bone connection)
      (hash-set! connections bone connection))
    
    (define/public (remove-connection bone)
      (hash-remove! connections bone))

    (define/public (description)
      (string-append
       name ":\n"
       indent "points:\n"
       indent indent (string-join
                      (map describe-point points) ", ") "\n"
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
