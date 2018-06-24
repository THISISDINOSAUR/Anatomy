#lang racket

(provide bone%)

(require "point.rkt")

(define bone%
  (class object%

    (init-field
     [points #f]
     [angle 0]
     [children (mutable-set)])

    (define/public (add-child child)
      (set-add! children child))
    
    (define/public (remove-child child)
      (set-remove! children child))

    (define/public (get-points)
      (points))

    (define/public (description)
      (string-join
           (map describe-point points) ", "))

    (super-new)
    ))
