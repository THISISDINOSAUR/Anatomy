#lang racket

(provide (all-defined-out))

(require "point.rkt"
         json)

(define indent "  ")

(define bone%
  (class object%

    (init-field
     [points #f]
     [parent-connection #f]
     [connections (list)]
     [name ""])

    (define/public (add-connection! bone connection)
      (set! connections (append connections (list connection)))
      (set-field! parent-connection bone connection))

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

    (define/public (scale! x y z)
      (vector-map! (lambda (point)
           (scale-point-dimension-wise point x y z))
         points)
      (scale-connections! x y z)
      (send parent-connection scale-child! x y z) ;TODO: check what happens when no parent
      )

    (define (scale-connections! x y z)
      (for ([(connection) connections])
        (send connection scale-parent! x y z))
      )      

    (define (points->json)
      (vector->list (vector-map (lambda (point) (point->list point)) points)))

    (define (connections->json)
      (map (lambda (bone-connection)
             (send bone-connection json))
           connections))

    (define/public (json)
      (hasheq 'name name
              'points (points->json)
              'connections (connections->json)))
    
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
                               (get-field name (get-field child-bone bone-connection))
                               " = "
                               (send bone-connection description)))
                            connections)
                       (string-append "\n" indent indent))
       "\n"))
      

    (super-new)
    ))

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

    (define/public (description)
      (string-append
       name ": " (string-join
                      (map (lambda (bone)
                             (get-field name bone))
                           bones)
                      ", ")
       "\n"))

    (super-new)
    ))

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

    (define/public (json)
      (hasheq 'parent_point (point->list parent-point)
                     'child_point (point->list child-point)
                     'angle angle
                     'bone (send child-bone json)))

    (define/public (description)
        (string-append
         (describe-point parent-point) " ~ " (describe-point child-point) ", " (number->string angle) "°"))


    (super-new)
    ))
      
(struct parameter (lower-bound upper-bound default)
  #:auto-value 0
  #:transparent
  #:mutable)

(define (is-valid-parameter-value? param value)
  (<= (parameter-lower-bound param) value (parameter-upper-bound param)))

(define (describe-parameter parameter1)
  (string-append (~a (parameter-lower-bound parameter1)) "  > < " (~a (parameter-upper-bound parameter1)) " = " (~a (parameter-default parameter1))))

(define (parameter->json parameter1)
  (hasheq 'lower-bound (parameter-lower-bound parameter1)
          'upper-bound (parameter-upper-bound parameter1)
          'default (parameter-default parameter1)))

(define parameters%
  (class object%

    (init-field
     [parameters #f]
     [setters #f]
     [ordering #f])

    (define/public (json)
      (map (lambda (param-name)
             (hasheq param-name (parameter->json (hash-ref parameters param-name))))
           ordering))

    (define/public (description)
      (string-join
       (map (lambda (param-name)
              (string-append (symbol->string param-name)
                             ": "
                             (describe-parameter (hash-ref parameters param-name))))
            ordering)
       "\n"))

    (super-new)))