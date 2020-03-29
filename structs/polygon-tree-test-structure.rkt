#lang br

(provide (all-defined-out))

(require "polygon-tree.rkt"
         "polygon.rkt"
         "point.rkt"
         "rect.rkt")

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

(define test-tree-list (list (test-structure-node1 (test-tree))
                             (test-structure-node2 (test-tree))
                             (test-structure-node3 (test-tree))
                             (test-structure-node4 (test-tree))
                             (test-structure-node5 (test-tree))))

(define test-tree-absolute-polygons
  (list (test-polygon)
        (list (point 100.0 100.0 0)
              (point 100.00000000000001 -100.0 0)
              (point 200.0 -100.0 0)
              (point 200.0 100.0 0))
        (list (point 114.64466094067262 -135.35533905932738 0)
              (point 256.06601717798213 -276.77669529663683 0)
              (point 326.7766952966369 -206.0660171779821 0)
              (point 185.35533905932738 -64.64466094067262 0))
        (list (point 206.06601717798213 -256.06601717798213 0)
              (point 406.06601717798213 -256.06601717798213 0)
              (point 406.06601717798213 -156.06601717798213 0)
              (point 206.06601717798213 -156.06601717798213 0))
        (list (point 256.06601717798213 -276.7766952966369 0)
              (point 397.48737341529164 -135.3553390593274 0)
              (point 326.7766952966369 -64.64466094067265 0)
              (point 185.35533905932738 -206.06601717798213 0))))