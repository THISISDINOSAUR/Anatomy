#lang br
(require "polygon-tree.rkt"
         "polygon.rkt"
         "point.rkt"
         rackunit)

(define (test-polygon-with-scale x y z)
  (list
   (scale-point-dimension-wise (point 0 0 0) x y z)
   (scale-point-dimension-wise (point 200 0 0) x y z)
   (scale-point-dimension-wise (point 200 100 0) x y z)
   (scale-point-dimension-wise (point 0 100 0) x y z)))

(define (test-polygon) (test-polygon-with-scale 1 1 1))

(struct test-structure (node1 node2 node3 node4 node5))
#|
1. ____
  |____|   __
     | |  / /
  2. |_|\/ / 5.
       \ \/__
    3.  \/___| 4.

1 ~ 2 = [150, 50] ~ [50, 50], 90
2 ~ 3 = [200, 50] ~ [0, 50], -45
3 ~ 4 = [150, 50] ~ [50, 50], -45
3 ~ 5 = [150, 50] ~ [50, 50], -90
|#

(define (test-tree-with-scale x y z)
  (define rect (test-polygon-with-scale x y z))

  (define root (points->root-polygon-tree rect))
  (define node2 (points->root-polygon-tree rect))
  (define node3 (points->root-polygon-tree rect))
  (define node4 (points->root-polygon-tree rect))
  (define node5 (points->root-polygon-tree rect))

  (polygon-tree-add-child! root node2
                           (scale-point-dimension-wise (point 150 50 0) x y z)
                           (scale-point-dimension-wise (point 50 50 0) x y z)
                           90)
  (polygon-tree-add-child! node2 node3
                           (scale-point-dimension-wise (point 200 50 0) x y z)
                           (scale-point-dimension-wise (point 0 50 0) x y z)
                           -45)
  (polygon-tree-add-child! node3 node4
                           (scale-point-dimension-wise (point 150 50 0) x y z)
                           (scale-point-dimension-wise (point 50 50 0) x y z)
                           -45)
  (polygon-tree-add-child! node3 node5
                           (scale-point-dimension-wise (point 150 50 0) x y z)
                           (scale-point-dimension-wise (point 50 50 0) x y z)
                           -90)
  (test-structure root node2 node3 node4 node5))

(define (test-tree) (test-tree-with-scale 1 1 1))


; Test polygon-tree->polygons
(define test-polygons (list (test-polygon) (test-polygon) (test-polygon) (test-polygon) (test-polygon)))
(check-equal? (polygon-tree->polygons (test-structure-node1 (test-tree))) test-polygons)

; Test scale-polygon-tree!
(define test-tree-scaled (test-tree))
(define node1 (test-structure-node1 test-tree-scaled))
(scale-polygon-tree! node1 2 2 1)
(for ([(polygon) (polygon-tree->polygons node1)])
  (check-equal? polygon (test-polygon-with-scale 2 2 1)))

(define node2 (test-structure-node2 test-tree-scaled))
(check-equal? (polygon-tree-connection-point-on-parent node2) (point 300 100 0))
(check-equal? (polygon-tree-connection-point node2) (point 100 100 0))
(define node5 (test-structure-node5 test-tree-scaled))
(check-equal? (polygon-tree-connection-point-on-parent node5) (point 300 100 0))
(check-equal? (polygon-tree-connection-point node5) (point 100 100 0))


(define test-tree-scaled-from-node2 (test-tree))
(set! node2 (test-structure-node2 test-tree-scaled-from-node2))
(scale-polygon-tree! node2 1.5 1 1)
(for ([(polygon) (polygon-tree->polygons node2)])
  (check-equal? polygon (test-polygon-with-scale 1.5 1 1)))
;root node shouldn't scale
(check-equal? (polygon-tree-polygon (test-structure-node1 test-tree-scaled-from-node2)) (test-polygon))

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