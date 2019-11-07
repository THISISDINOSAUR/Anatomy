#lang racket

(provide (all-defined-out))

(struct parameter (lower-bound upper-bound default)
  #:auto-value 0
  #:transparent
  #:mutable)

(define (is-valid-parameter-value? param value)
  (<= (parameter-lower-bound param) value (parameter-upper-bound param)))

(define parameters%
  (class object%

    (init-field
     [parameters #f]
     [setters #f]
     [ordering #f])

    (super-new)))