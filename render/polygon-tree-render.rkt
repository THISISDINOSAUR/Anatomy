#lang racket

(provide (all-defined-out))

(require "../structs/polygon-tree.rkt"
         "../structs/point.rkt"
         "../structs/polygon.rkt"
         "../structs/rect.rkt")

(struct labeled-point (point label)
  #:auto-value #f
  #:transparent
  #:mutable)

(define (polygon->labeled-polygon polygon labels)
  (map (lambda (point label)
         (labeled-point point label))
       polygon labels))

(define (labeled-polygon->polygon labeled-polygon)
  (map (lambda (labeled-point)
         (labeled-point-point labeled-point))
       labeled-polygon))

(struct drawable-polygon (labeled-polygon
                          labeled-connection-point
                          labeled-child-connection-points
                          highlighted?
                          selected?)
  #:auto-value #f
  #:transparent
  #:mutable)

(define (drawable-polygon->draw-points polygon)
  (labeled-polygon->polygon (drawable-polygon-labeled-polygon polygon)))

(define (polygon-tree->drawable-polygon tree)
  (drawable-polygon
     (polygon->labeled-polygon (polygon-tree->absolute-polygon tree) (polygon-tree-polygon tree))
     (labeled-point (polygon-tree-point->absolute-point tree (polygon-tree-connection-point tree)) (polygon-tree-connection-point tree))
     (map (lambda (child)
            (labeled-point
             (polygon-tree-point->absolute-point tree (polygon-tree-connection-point-on-parent child))
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
         
  