#lang racket

(provide (all-defined-out))

(define section%
  (class object%

    (init-field
     [bones #f]
     [name ""])

    (define/public (scale! x y z)
      (map (lambda (bone)
             (send bone scale! x y z))
           bones)
      (void))

    (super-new)
    ))