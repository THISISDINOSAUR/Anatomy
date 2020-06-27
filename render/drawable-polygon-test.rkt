#lang br
(require "drawable-polygon.rkt"
         "../structs/polygon-tree.rkt"
         "../structs/polygon-tree-test-structure.rkt"
         "../structs/polygon.rkt"
         "../structs/point.rkt"
         "../structs/rect.rkt"
         rackunit)

; Test polygon-tree->drawable-polygon
(define test-drawable-polygon (test-tree))
(define expected (list-ref test-tree-drawable-polygons 2))
(check-equal?
 (polygon-tree->drawable-polygon (test-structure-node3 test-drawable-polygon))
 expected)
