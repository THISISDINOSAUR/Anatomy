#lang racket

(provide (all-defined-out))

(require "bone.rkt"
"parameter.rkt"
"structs/point.rkt")

(define (connection->json connection)
      (hasheq 'parent_point (point->list (get-field parent-point connection))
                     'child_point (point->list (get-field child-point connection))
                     'angle (get-field angle connection)
                     'bone (bone->json (get-field child-bone connection))))

(define (points->json points)
    (map (lambda (point) 
    (point->list point))
    points))


    (define (connections->json connections)
      (map (lambda (bone-connection)
             (send bone-connection json))
           connections))

(define (bone->json bone)
    (hasheq 'name (get-field name bone)
            'points (points->json (vector->list (get-field points bone)))
            'connections (map (lambda (connection)
             (connection->json connection))
           (get-field connections bone))))

(define (parameter->json parameter1)
  (hasheq 'lower-bound (parameter-lower-bound parameter1)
          'upper-bound (parameter-upper-bound parameter1)
          'default (parameter-default parameter1)))

(define (parameters->json parameters)
      (map (lambda (param-name)
             (hasheq param-name (parameter->json (hash-ref (get-field parameters parameters) param-name))))
           (get-field ordering parameters)))