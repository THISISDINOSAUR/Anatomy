#lang racket

;TODO perhaps in future this should return absolute polygons rather than a relative tree to make clients easier to implement?

(provide (all-defined-out))

(require "bone.rkt"
         "parameter.rkt"
         "structs/point.rkt"
         "structs/polygon-tree.rkt")

(define (child-bone-connection->json child-bone)
  (define polygon-tree (get-field polygon-tree child-bone))
  (hasheq 'parent_point (point->list (polygon-tree-connection-point-on-parent polygon-tree))
          'child_point (point->list (polygon-tree-connection-point polygon-tree))
          'angle (polygon-tree-angle polygon-tree)
          'bone (bone->json child-bone)))

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
          'points (points->json (polygon-tree-polygon (get-field polygon-tree bone)))
          'connections (map (lambda (connection)
                              (child-bone-connection->json connection))
                            (get-field connections bone))))

(define (parameter->json parameter1)
  (hasheq 'lower-bound (parameter-lower-bound parameter1)
          'upper-bound (parameter-upper-bound parameter1)
          'default (parameter-default parameter1)))

(define (parameters->json parameters)
  (map (lambda (param-name)
         (hasheq param-name (parameter->json (hash-ref (get-field parameters parameters) param-name))))
       (get-field ordering parameters)))