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
  (point-and-label->drawable-labeled-point
   point
   (point->description-string-2d-rounded label-point)))

(define (point-and-label->drawable-labeled-point point label)
  (labeled-point
   (point-invert-y point)
   label))

(define (polygon->drawable-labeled-polygon polygon label-points)
  (labeled-polygon
   (map (lambda (point)
         (point-invert-y point))
       polygon)
   (map (lambda (label-point)
         (point->description-string-2d-rounded label-point))
       label-points)))

(define (labeled-points->labeled-polygon points)
  (labeled-polygon
   (map (lambda (point)
         (labeled-point-point point))
       points)
   (map (lambda (point)
         (labeled-point-label point))
       points)))

(struct drawable-polygon (labeled-polygon
                          labeled-connection-point
                          labeled-child-connection-points
                          original-placement
                          highlighted?
                          selected?)
  #:auto-value #f
  #:transparent
  #:mutable

  ;Don't include UI state in equality checks
  ;TODO: maybe should approach storing UI state differently, we'll see how it progresses
  #:methods
  gen:equal+hash
  [(define (equal-proc a b equal?-recur)
     (and (equal?-recur (drawable-polygon-labeled-polygon a) (drawable-polygon-labeled-polygon b))
          (equal?-recur (drawable-polygon-labeled-connection-point a) (drawable-polygon-labeled-connection-point b))
          (equal?-recur (drawable-polygon-labeled-child-connection-points a) (drawable-polygon-labeled-child-connection-points b))
          (equal?-recur (drawable-polygon-original-placement a) (drawable-polygon-original-placement b))))
   (define (hash-proc a hash-recur)
     (+ (hash-recur (drawable-polygon-labeled-polygon a))
        (hash-recur (drawable-polygon-labeled-connection-point a))
        (hash-recur (drawable-polygon-labeled-child-connection-points a))
        (hash-recur (drawable-polygon-original-placement a))))
   (define (hash2-proc a hash2-recur)
     (+ (hash2-recur (drawable-polygon-labeled-polygon a))
        (hash2-recur (drawable-polygon-labeled-connection-point a))
        (hash2-recur (drawable-polygon-labeled-child-connection-points a))
        (hash2-recur (drawable-polygon-original-placement a))))])

(define-struct-updaters drawable-polygon)

(define (drawable-polygon->draw-points polygon)
  (labeled-polygon-polygon (drawable-polygon-labeled-polygon polygon)))

(define (polygon-tree->drawable-polygon tree)
  (drawable-polygon
     (polygon->drawable-labeled-polygon
      (polygon-tree->absolute-polygon tree)
      (polygon-tree-polygon tree))
     (point-and-label->drawable-labeled-point
      (polygon-tree-point->absolute-point (polygon-tree-connection-point tree) tree)
      (polygon-tree->connection-description-string-2d-rounded tree))
     (map (lambda (child)
            (point-and-label->drawable-labeled-point
             (polygon-tree-point->absolute-point (polygon-tree-connection-point-on-parent child) tree)
             (polygon-tree->connection-description-string-2d-rounded child)))
          (polygon-tree-children tree))
     (polygon-tree->absolute-placement-in-tree tree)
     #f
     #f))

(define (bone->drawable-polygons-pairs bone)
  (define tree (get-field poly-tree bone))
  (append
   (list (cons (polygon-tree->drawable-polygon tree) bone))
   (append-map (lambda (child)
                 (bone->drawable-polygons-pairs child))
               (get-field connections bone))))


(define (drawable-polygon->polygon polygon)
  (labeled-polygon-polygon (drawable-polygon-labeled-polygon polygon)))

(define (drawable-polygon->label-points polygon)
  (labeled-polygon-labels (drawable-polygon-labeled-polygon polygon)))

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

(define (rotate-drawable-polygon-around-parent drawable angle)
  (drawable-polygon-replace-polygon
   drawable
   (rotate-polygon-about-point
    (drawable-polygon->polygon drawable) angle (labeled-point-point (drawable-polygon-labeled-connection-point drawable)))))

(define (drawable-polygon-replace-polygon drawable new-polygon)
  (drawable-polygon
   (labeled-polygon
     new-polygon
    (drawable-polygon->label-points drawable))
   (drawable-polygon-labeled-connection-point drawable)
   (drawable-polygon-labeled-child-connection-points drawable)
   (drawable-polygon-original-placement drawable)
   (drawable-polygon-highlighted? drawable)
   (drawable-polygon-selected? drawable)))
  
  