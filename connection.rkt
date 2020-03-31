#lang racket

(provide (all-defined-out))

(require "structs/point.rkt"
         )

(define connection%
  (class object%

    (init-field
     [parent-point #f]
     [child-point #f]
     [angle #f]
     [child-bone #f])

    (super-new)
    ))

(define (connection-zero)
  (new connection%
       [parent-point point-zero]
       [child-point point-zero]
       [angle 0]))