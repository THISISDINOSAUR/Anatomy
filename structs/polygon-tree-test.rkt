#lang br
(require "polygon-tree.rkt"
         "polygon-tree-test-structure.rkt"
         "polygon.rkt"
         "point.rkt"
         "rect.rkt"
         rackunit)

; Test polygon-tree->polygons
(define test-polygons (list (test-polygon) (test-polygon) (test-polygon) (test-polygon) (test-polygon)))
(check-equal?
 (polygon-tree->polygons (test-structure-node1 (test-tree)))
 test-polygons)

; Test polygon-tree->nodes-list
(define test-nodes-list (test-tree))
(check-equal?
 (polygon-tree->nodes-list (test-structure-node1 test-nodes-list))
 test-tree-list)

; Test scale-polygon-tree!
(define test-tree-scaled (test-tree))
(define node1 (test-structure-node1 test-tree-scaled))
(scale-polygon-tree! node1 2 2 1)
(for ([(polygon) (polygon-tree->polygons node1)])
  (check-equal? polygon (test-polygon-with-scale 2 2 1)))

(define node2 (test-structure-node2 test-tree-scaled))
(check-equal?
 (polygon-tree-connection-point-on-parent node2)
 (point 300 100 0))
(check-equal?
 (polygon-tree-connection-point node2)
 (point 100 100 0))

(define node5 (test-structure-node5 test-tree-scaled))
(check-equal?
 (polygon-tree-connection-point-on-parent node5)
 (point 300 100 0))
(check-equal?
 (polygon-tree-connection-point node5)
 (point 100 100 0))


(define test-tree-scaled-from-node2 (test-tree))
(set! node2 (test-structure-node2 test-tree-scaled-from-node2))
(scale-polygon-tree! node2 1.5 1 1)
(for ([(polygon) (polygon-tree->polygons node2)])
  (check-equal? polygon (test-polygon-with-scale 1.5 1 1)))
;root node shouldn't scale
(check-equal?
 (polygon-tree-polygon (test-structure-node1 test-tree-scaled-from-node2))
 (test-polygon))

;connection point on parent (root) shouldn't scale, but everything else should
(check-equal? (polygon-tree-connection-point-on-parent node2) (point 150 50 0))
(check-equal? (polygon-tree-connection-point node2) (point 75.0 50 0))
(set! node5 (test-structure-node5 test-tree-scaled-from-node2))
(check-equal? (polygon-tree-connection-point-on-parent node5) (point 225.0 50 0))
(check-equal? (polygon-tree-connection-point node5) (point 75.0 50 0))


; Test scale-root-only-of-polygon-tree!
(define test-tree-node2-scaled (test-tree))
(set! node1 (test-structure-node1 test-tree-node2-scaled))
(set! node2 (test-structure-node2 test-tree-node2-scaled))
(scale-root-only-of-polygon-tree! node2 0.1 0.1 1)
(check-equal? (polygon-tree-polygon node1) (test-polygon))
(check-equal? (polygon-tree-polygon node2) (test-polygon-with-scale 0.1 0.1 1))
(check-equal? (polygon-tree-connection-point-on-parent node2) (point 150 50 0))
(check-equal? (polygon-tree-connection-point node2) (point 5.0 5.0 0))

(define node3 (test-structure-node3 test-tree-node2-scaled))
(check-equal? (polygon-tree-polygon node3) (test-polygon))
(check-equal? (polygon-tree-connection-point-on-parent node3) (point 20.0 5.0 0))
(check-equal? (polygon-tree-connection-point node3) (point 0 50 0))

(define node4 (test-structure-node4 test-tree-node2-scaled))
(check-equal? (polygon-tree-polygon node4) (test-polygon))
(check-equal? (polygon-tree-connection-point-on-parent node4) (point 150 50 0))
(check-equal? (polygon-tree-connection-point node4) (point 50 50 0))


; Test polygon-tree-absolute-angle-in-tree
(define angle-test (test-tree))
(set! node1 (test-structure-node1 angle-test))
(check-equal? (polygon-tree-absolute-angle-in-tree node1) 0)
(check-equal? (polygon-tree-absolute-angle-in-tree (test-structure-node2 angle-test)) 90)
(check-equal? (polygon-tree-absolute-angle-in-tree (test-structure-node3 angle-test)) 45)
(check-equal? (polygon-tree-absolute-angle-in-tree (test-structure-node4 angle-test)) 0)
(check-equal? (polygon-tree-absolute-angle-in-tree (test-structure-node5 angle-test)) -45)

;TODO this test file could definitely benefit from some methods to check for approximate equality
; Test polygon-tree->absolute-placement-in-tree
(define absolute-placement-test (test-tree))
(check-equal?
 (polygon-tree->absolute-placement-in-tree (test-structure-node1 absolute-placement-test))
 (placement point-zero 0))
(check-equal?
 (polygon-tree->absolute-placement-in-tree (test-structure-node2 absolute-placement-test))
 (placement (point 100.0 100.0 0) 90))
(check-equal?
 (polygon-tree->absolute-placement-in-tree (test-structure-node3 absolute-placement-test))
 (placement (point 114.64466094067262 -135.35533905932738 0) 45))
(check-equal?
 (polygon-tree->absolute-placement-in-tree (test-structure-node4 absolute-placement-test))
 (placement (point  206.06601717798213 -256.06601717798213 0) 0))
(check-equal?
 (polygon-tree->absolute-placement-in-tree (test-structure-node5 absolute-placement-test))
 (placement (point 256.06601717798213 -276.7766952966369 0) -45))

; test with root that isn't origin 0, angle 0
(define root (polygon-tree (test-polygon) #f #f (point 50 50 0) -30'()))
(set! node2 (points->root-polygon-tree (test-polygon)))
(polygon-tree-add-child!
 root
 node2
 (point 150 50 0)
 (point 50 50 0)
 90)
(check-equal?
 (polygon-tree->absolute-placement-in-tree root)
 (placement (point -18.301270189221942 -68.30127018922194 0) -30))
(check-equal?
 (polygon-tree->absolute-placement-in-tree node2)
 (placement (point 18.301270189221924 68.30127018922191 0) 60))

; Test polygon-tree->absolute-polygon
(define absolute-polygon-test (test-tree))
(check-equal?
 (polygon-tree->absolute-polygon (test-structure-node1 absolute-polygon-test))
 (test-polygon))
(check-equal?
 (polygon-tree->absolute-polygon (test-structure-node2 absolute-polygon-test))
 (list-ref test-tree-absolute-polygons 1))
(check-equal?
 (polygon-tree->absolute-polygon (test-structure-node3 absolute-polygon-test))
 (list-ref test-tree-absolute-polygons 2))
(check-equal?
 (polygon-tree->absolute-polygon (test-structure-node4 absolute-polygon-test))
 (list-ref test-tree-absolute-polygons 3))
(check-equal?
 (polygon-tree->absolute-polygon (test-structure-node5 absolute-polygon-test))
 (list-ref test-tree-absolute-polygons 4))

; Test polygon-tree->absolute-polygons
(define absolute-polygons-test (test-tree))
(check-equal?
 (polygon-tree->absolute-polygons (test-structure-node1 absolute-polygons-test))
 test-tree-absolute-polygons)

; Test polygon-tree-point->absolute-point
(define absolute-point-test (test-tree))
(define test-point-on-tree (point 30 50 0))
(define test-absolute-point (point 171.21320343559643 -121.21320343559643 0))
(check-equal?
 (polygon-tree-point->absolute-point test-point-on-tree (test-structure-node3 absolute-point-test))
 test-absolute-point)

; Test absolute-point->polygon-tree-point
(check-equal?
 (absolute-point->polygon-tree-point test-absolute-point (test-structure-node3 absolute-point-test))
 (point 30.000000000000007 50.0 0))

; Test polygon-tree->bounding-rect
(define bounding-rect-test (test-tree))
(check-equal?
 (polygon-tree->bounding-rect (test-structure-node1 bounding-rect-test))
 (bounding-rect 0.0 406.06601717798213 -276.7766952966369 100.0))

(define bounding-rect-sub-tree-test (test-structure-node3 (test-tree)))
(check-equal?
 (polygon-tree->bounding-rect bounding-rect-sub-tree-test)
 (bounding-rect 114.64466094067262 406.06601717798213 -276.7766952966369 -64.64466094067262))