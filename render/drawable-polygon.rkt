#lang racket

(provide (all-defined-out))

(require struct-update
         "../structs/polygon-tree.rkt"
         "../structs/point.rkt"
         "../structs/polygon.rkt"
         "../structs/rect.rkt"
         "../string.rkt")

(struct labeled-point (point label)
  #:auto-value #f
  #:transparent
  #:mutable)

(struct labeled-polygon (polygon labels)
  #:auto-value #f
  #:transparent
  #:mutable)

(define (point->drawable-labeled-point point label-point)
  (labeled-point
   (point-invert-y point)
   (point->description-string-2d-rounded label-point)))

(define (polygon->drawable-labeled-polygon polygon label-points)
  (labeled-polygon
   (map (lambda (point)
         (point-invert-y point))
       polygon)
   (map (lambda (label-point)
         (point->description-string-2d-rounded label-point))
       label-points)))

;TODO should have  original-placement field?
(struct drawable-polygon (labeled-polygon
                          labeled-connection-point
                          labeled-child-connection-points
                          highlighted?
                          selected?)
  #:auto-value #f
  #:transparent
  #:mutable)

(define-struct-updaters drawable-polygon)

(define (drawable-polygon->draw-points polygon)
  (labeled-polygon-polygon (drawable-polygon-labeled-polygon polygon)))

(define (polygon-tree->drawable-polygon tree)
  (drawable-polygon
     (polygon->drawable-labeled-polygon (polygon-tree->absolute-polygon tree) (polygon-tree-polygon tree))
     (point->drawable-labeled-point (polygon-tree-point->absolute-point (polygon-tree-connection-point tree) tree) (polygon-tree-connection-point tree))
     (map (lambda (child)
            (point->drawable-labeled-point
             (polygon-tree-point->absolute-point (polygon-tree-connection-point-on-parent child) tree)
             (polygon-tree-connection-point-on-parent child)))
          (polygon-tree-children tree))
     #f
     #f))

(define (polygon-tree->drawable-polygons tree)
  (append
   (list
    (polygon-tree->drawable-polygon tree))
   (append-map (lambda (child)
                 (polygon-tree->drawable-polygons child))
               (polygon-tree-children tree))))

(define (drawable-polygon->polygon polygon)
  (labeled-polygon-polygon (drawable-polygon-labeled-polygon polygon)))

(define (drawable-polygons->bounding-rect drawable-polygons)
  (define polygons
    (map (lambda (polygon)
           (drawable-polygon->polygon polygon))
         drawable-polygons))
  (polygons->bounding-rect polygons))

(define (drawable-polygons-intersected-by-point drawable-polygons point)
  (remove*
   (list null)
   (map (lambda (polygon)
          (if
           (point-intersects-polygon? point (drawable-polygon->polygon polygon))
           polygon
           null))
        drawable-polygons)))
  