#lang racket

(provide (all-defined-out))

(require "point.rkt")

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

(define (points->bounding-rect points)
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