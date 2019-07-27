#lang racket

(provide (all-defined-out))

(require racket/draw)

(struct point (x y z)
  #:auto-value 0
  #:transparent
  #:mutable)

(define point-zero (point 0 0 0))

(define (add-points point1 point2)
  (point (+ (point-x point1) (point-x point2)) (+ (point-y point1) (point-y point2)) (+ (point-z point1) (point-z point2))))

(define (add-points-list points)
  (foldl add-points point-zero points))
  
(define (subtract-points point1 point2)
  (point (- (point-x point1) (point-x point2)) (- (point-y point1) (point-y point2)) (- (point-z point1) (point-z point2))))

(define (scale-point-dimension-wise point1 x-scale y-scale z-scale)
  (point (* (point-x point1) x-scale) (* (point-y point1) y-scale) (* (point-z point1) z-scale)))

(define (scale-point point1 scale)
  (scale-point-dimension-wise point1 scale scale scale))

(define (divide-point point1 divider)
  (scale-point point1 (/ 1.0 divider)))

(define (negate-point point1)
  (point (- (point-x point1)) (- (point-y point1)) (- (point-z point1))))

(define (rotate-point point1 angle)
  (define radians (degrees->radians angle))
  (point (- (* (point-x point1) (cos radians)) (* (point-y point1) (sin radians)))
         (+ (* (point-x point1) (sin radians)) (* (point-y point1) (cos radians)))
         (point-z point1)))

(define (rotate-point-about-point point1 angle rotation-point)
  (define radians (degrees->radians angle))
  (define translated-point (subtract-points point1 rotation-point))
  (define rotated-point (point (- (* (point-x translated-point) (cos radians)) (* (point-y translated-point) (sin radians)))
         (+ (* (point-x translated-point) (sin radians)) (* (point-y translated-point) (cos radians)))
         (point-z translated-point)))
  (add-points rotated-point rotation-point))

(define (average-points points)
  (divide-point (add-points-list points) (length points)))

(define (distance-between-points point1 point2)
  (define p (subtract-points point1 point2))
  (sqrt (+
         (* (point-x p) (point-x p))
         (* (point-y p) (point-y p))
         (* (point-z p) (point-z p)))))

(define (operation-on-point-dimension op dimension point1 val)
  (match dimension
    [(== point-x)
     (point
      (op (point-x point1) val)
      (point-y point1)
      (point-z point1))]
    [(== point-y)
     (point
      (point-x point1)
      (op (point-y point1) val)
      (point-z point1))]
    [(== point-z)
     (point
      (point-x point1)
      (point-y point1)
      (op (point-z point1) val))]
    [_
     void]))

(define (describe-point point1)
  (string-append "[" (~a (point-x point1)) ", " (~a (point-y point1)) ", " (~a (point-z point1)) "]"))

(define (describe-point-2d-rounded point1)
  (string-append "[" (~a (exact-round (point-x point1))) "," (~a (exact-round (point-y point1))) "]"))

(define (point->list point1)
  (list (point-x point1) (point-y point1) (point-z point1)))

(define (points->path points)
  (let ([p (new dc-path%)])
    (define firstPoint (car points))
    (send p move-to (point-x firstPoint) (point-y firstPoint))
    (for ([(point) points])
      (send p line-to (point-x point) (point-y point)))
    (send p line-to (point-x firstPoint) (point-y firstPoint))
    p))

(struct bounding-rect (min-x max-x min-y max-y)
  #:transparent
  #:mutable)

(define (bounding-rect-containing-bounding-rects rect1 rect2)
  (bounding-rect (min (bounding-rect-min-x rect1) (bounding-rect-min-x rect2))
                 (max (bounding-rect-max-x rect1) (bounding-rect-max-x rect2))
                 (min (bounding-rect-min-y rect1) (bounding-rect-min-y rect2))
                 (max (bounding-rect-max-y rect1) (bounding-rect-max-y rect2))))

;This won't work for an empty list since there is no sensible base case
(define (bounding-rect-containing-bounding-rects-list rects)
  (foldl bounding-rect-containing-bounding-rects (car rects) rects))

(define (bounding-rect-for-points points)
  (define x-values
    (map (lambda (point)
           (point-x point))
         points))
  (define y-values
    (map (lambda (point)
           (point-y point))
         points))
  (bounding-rect (apply min x-values) (apply max x-values) (apply min y-values) (apply max y-values)))

(define (translate-bounding-rect rect translation)
  (bounding-rect (+ (bounding-rect-min-x rect) (point-x translation))
                 (+ (bounding-rect-max-x rect) (point-x translation))
                 (+ (bounding-rect-min-y rect) (point-y translation))
                 (+ (bounding-rect-max-y rect) (point-y translation))))

(define (add-padding-to-bounding-rect rect padding)
  (bounding-rect (- (bounding-rect-min-x rect) padding)
                 (+ (bounding-rect-max-x rect) padding)
                 (- (bounding-rect-min-y rect) padding)
                 (+ (bounding-rect-max-y rect) padding)))

(define (bounding-rect-width rect)
  (- (bounding-rect-max-x rect) (bounding-rect-min-x rect)))

(define (bounding-rect-height rect)
 (- (bounding-rect-max-y rect) (bounding-rect-min-y rect)))


(define (trapesium top-span bottom-span left-span right-span)
  (define shift (point (/ (max bottom-span top-span) 2.0)
                       (/ (max left-span right-span) 2.0)
                       0))
  (map (lambda (p)
         (add-points p shift))
       (list
        (point (- (/ bottom-span 2.0)) (- (/ left-span 2.0)) 0)
        (point (/ bottom-span 2.0) (- (/ right-span 2.0)) 0)
        (point (/ top-span 2.0) (/ right-span 2.0) 0)
        (point (- (/ top-span 2.0)) (/ left-span 2.0) 0))))
   