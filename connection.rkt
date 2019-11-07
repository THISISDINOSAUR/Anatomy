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

    (define/public (scale-parent! x y z)
      (set! parent-point (scale-point-dimension-wise parent-point x y z)))

    (define/public (scale-child! x y z)
      (set! child-point (scale-point-dimension-wise child-point x y z)))

    (super-new)
    ))

(define (connection-zero)
  (new connection%
       [parent-point point-zero]
       [child-point point-zero]
       [angle 0]))