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
                           -54)
  (polygon-tree-add-child! node3 node5
                           (scale-point-dimension-wise (point 150 50 0) x y z)
                           (scale-point-dimension-wise (point 50 50 0) x y z)
                           -90)
  root)

(define (test-tree) (test-tree-with-scale 1 1 1))



(define test-polygons (list (test-polygon) (test-polygon) (test-polygon) (test-polygon) (test-polygon)))
(check-equal? (polygon-tree->polygons (test-tree)) test-polygons)

(define test-tree-scaled (test-tree))
(scale-polygon-tree! test-tree-scaled 2 2 1)
(for ([(polygon) (polygon-tree->polygons test-tree-scaled)])
  (check-equal? polygon (test-polygon-with-scale 2 2 1)))

;test connection points
(define node2 (car (polygon-tree-children test-tree-scaled)))
(check-equal? (polygon-tree-connection-point-on-parent node2) (point 300 100 0))
(check-equal? (polygon-tree-connection-point node2) (point 100 100 0))
(define node5 (car (cdr (polygon-tree-children (car (polygon-tree-children node2))))))
(check-equal? (polygon-tree-connection-point-on-parent node5) (point 300 100 0))
(check-equal? (polygon-tree-connection-point node5) (point 100 100 0))


(define test-tree-scaled-from-node2 (test-tree))
(scale-polygon-tree! (car (polygon-tree-children test-tree-scaled-from-node2)) 1.5 1 1)
(for ([(polygon) (polygon-tree->polygons (car (polygon-tree-children test-tree-scaled-from-node2)))])
  (check-equal? polygon (test-polygon-with-scale 1.5 1 1)))
;root node shouldn't scale
(check-equal? (polygon-tree-polygon test-tree-scaled-from-node2) (test-polygon))

(set! node2 (car (polygon-tree-children test-tree-scaled-from-node2)))
;connection point on parent (root) shouldn't scale, but everything else should
(check-equal? (polygon-tree-connection-point-on-parent node2) (point 150 50 0))
(check-equal? (polygon-tree-connection-point node2) (point 75.0 50 0))
(set! node5 (car (cdr (polygon-tree-children (car (polygon-tree-children node2))))))
(check-equal? (polygon-tree-connection-point-on-parent node5) (point 225.0 50 0))
(check-equal? (polygon-tree-connection-point node5) (point 75.0 50 0))