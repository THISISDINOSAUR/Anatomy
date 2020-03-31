#lang racket

(provide (all-defined-out))

(require "point.rkt"
         "polygon.rkt"
         "rect.rkt")

(struct polygon-tree (polygon parent connection-point-on-parent connection-point angle children)
    #:auto-value #f
    #:transparent
    #:mutable)

(struct placement (point angle)
    #:auto-value #f
    #:transparent
    #:mutable)

(define (points->root-polygon-tree points)
    (polygon-tree points #f #f point-zero 0 '()))

(define (polygon-tree-add-child! parent child point-on-parent point-on-child angle)
    (set-polygon-tree-children! parent (append (polygon-tree-children parent) (list child)))
    (set-polygon-tree-parent! child parent)
    (set-polygon-tree-connection-point-on-parent! child point-on-parent)
    (set-polygon-tree-connection-point! child point-on-child)
    (set-polygon-tree-angle! child angle))

(define (polygon-tree->polygons tree)
  (append (list (polygon-tree-polygon tree))
          (append-map (lambda (child)
                        (polygon-tree->polygons child))
                      (polygon-tree-children tree))))

(define (polygon-tree->nodes-list tree)
  (append (list tree)
          (append-map (lambda (child)
                        (polygon-tree->nodes-list child))
                      (polygon-tree-children tree))))

(define (scale-polygon-tree! tree x y z)
  (set-polygon-tree-polygon!
   tree
   (scale-polygon (polygon-tree-polygon tree) x y z))

  (set-polygon-tree-connection-point!
   tree
   (scale-point-dimension-wise (polygon-tree-connection-point tree) x y z))

  (for ([(child) (polygon-tree-children tree)])
    (set-polygon-tree-connection-point-on-parent!
     child
     (scale-point-dimension-wise (polygon-tree-connection-point-on-parent child) x y z))
    (scale-polygon-tree! child x y z)))


(define (scale-root-only-of-polygon-tree! tree x y z)
  (set-polygon-tree-polygon!
   tree
   (scale-polygon (polygon-tree-polygon tree) x y z))

  (set-polygon-tree-connection-point!
   tree
   (scale-point-dimension-wise (polygon-tree-connection-point tree) x y z))

  (for ([(child) (polygon-tree-children tree)])
    (set-polygon-tree-connection-point-on-parent!
     child
     (scale-point-dimension-wise (polygon-tree-connection-point-on-parent child) x y z))))


(define (polygon-tree->absolute-placement-in-tree tree)
    (cond 
        [(equal? (polygon-tree-parent tree) #f)
            (placement
                (rotate-point (negate-point (polygon-tree-connection-point tree)) (polygon-tree-angle tree))
                (polygon-tree-angle tree))]
        [else
         (define place (polygon-tree->absolute-placement-in-tree (polygon-tree-parent tree)))
         (define current-angle (+ (placement-angle place) (polygon-tree-angle tree)))
         (define rotated-con-point (rotate-point (polygon-tree-connection-point tree) current-angle))
         (define rotate-parent-con-point (rotate-point (polygon-tree-connection-point-on-parent tree) (placement-angle place)))
         (define current-point
           (subtract-points
            (add-points (placement-point place) rotate-parent-con-point)
            rotated-con-point))
         (placement current-point current-angle)]))
         
(define (polygon-tree->absolute-polygon tree)
  (define placement (polygon-tree->absolute-placement-in-tree tree))
  (move-polygon
   (rotate-polygon (polygon-tree-polygon tree) (placement-angle placement))
   (placement-point placement)))

;TODO this could be more efficient by not using the polygon-tree->absolute-placement-in-tree method
;could work the same way as that method, altough would be tricky to keep track of collected placement
(define (polygon-tree->absolute-polygons tree)
  (append (list (polygon-tree->absolute-polygon tree))
          (append-map (lambda (child)
                        (polygon-tree->absolute-polygons child))
                      (polygon-tree-children tree))))

(define (polygon-tree-point->absolute-point point tree)
  (define placement (polygon-tree->absolute-placement-in-tree tree))
  (add-points
   (rotate-point point (placement-angle placement))
   (placement-point placement)))

(define (absolute-point->polygon-tree-point point tree)
  (absolute-point->placement-point point (polygon-tree->absolute-placement-in-tree tree)))

(define (absolute-point->placement-point point placement)
  (rotate-point
   (subtract-points
    point
    (placement-point placement))
   (- (placement-angle placement))))

(define (polygon-tree->bounding-rect tree)
  (bounding-rect-containing-bounding-rects-list
   (map (lambda (polygon)
         (points->bounding-rect polygon))
       (polygon-tree->absolute-polygons tree))))
