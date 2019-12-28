#lang racket

(provide (all-defined-out))

(require "point.rkt"
         sfont/geometry)

(define (scale-polygon polygon x y z)
      (map (lambda (point)
           (scale-point-dimension-wise point x y z))
         polygon))

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

(define (point-intersects-polygon? point1 polygon)
  (define index 0)
  (define intersections
    (map (lambda (line-point)
           (define next-point-index (if (equal? index (- (length polygon) 1)) 0 (+ 1 index)))
           (define next-point (list-ref polygon next-point-index))
           (set! index (+ index 1))
           (horizontal-line-for-point-intersects-line? point1 (list line-point next-point)))
         polygon))
  (odd? (- (length intersections) (count false? intersections))))

(define (horizontal-line-for-point-intersects-line? point1 line)
  (segment-intersection (vec (point-x point1) (point-y point1))
                        (vec 999999999999999999999999 (point-y point1))
                        (vec (point-x (car line)) (point-y (car line)))
                        (vec (point-x (car (cdr line))) (point-y (car (cdr line))))))