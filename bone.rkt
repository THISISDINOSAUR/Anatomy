#lang racket

(provide (all-defined-out))

(require "point.rkt"
         json)

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

    (define/public (scale! x y z)
      (vector-map! (lambda (point)
           (scale-point-dimension-wise point x y z))
         points)
      (void)) ;void to supress output

    (define (points->json)
      (vector->list (vector-map (lambda (point) (point->list point)) points)))

    (define (connections->json)
      (map (lambda (bone-connection)
             (hasheq 'parent_point (point->list (connection-point-parent (cdr bone-connection)))
                     'child_point (point->list (connection-point-child (cdr bone-connection)))
                     'angle (connection-angle (cdr bone-connection))
                     'bone (send (car bone-connection) json)))
           (hash->list connections)))

    (define/public (json)
      (write connections)
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
                               (get-field name (car bone-connection))
                               " = "
                               (describe-connection (cdr bone-connection))))
                            (hash->list connections))
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
      (set! bones
            (map (lambda (bone)
                   (send bone scale! x y z))
                 bones)))

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

(define (describe-parameter parameter1)
  (string-append (~a (parameter-lower-bound parameter1)) "  > < " (~a (parameter-upper-bound parameter1)) " = " (~a (parameter-default parameter1))))

(define parameters%
  (class object%

    (init-field
     [parameters #f]
     [setters #f])

    (define/public (description)
      (string-join
       (map (lambda (param)
              (string-append (symbol->string (car param))
                             ": "
                             (describe-parameter (cadr param))))
            (hash->list parameters))
       "\n"))

    (super-new)))