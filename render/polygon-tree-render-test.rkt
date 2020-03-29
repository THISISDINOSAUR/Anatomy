#lang br
(require "polygon-tree-render.rkt"
         "../structs/polygon-tree.rkt"
         "../structs/polygon-tree-test-structure.rkt"
         "../structs/polygon.rkt"
         "../structs/point.rkt"
         "../structs/rect.rkt"
         rackunit)

;TODO check all these numbers once we have paper
; Test polygon-tree->drawable-polygon
(define test-drawable-polygon (test-tree))
(define expected (list-ref test-tree-drawable-polygons 2))
(check-equal?
 (polygon-tree->drawable-polygon (test-structure-node3 test-drawable-polygon))
 expected)

; Test polygon-tree->drawable-polygons
(define test-drawable-polygons (test-tree))
(check-equal?
 (polygon-tree->drawable-polygons (test-structure-node1 test-drawable-polygons))
 test-tree-drawable-polygons)

