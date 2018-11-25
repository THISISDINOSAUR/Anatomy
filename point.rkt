#lang racket

(provide (all-defined-out))

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
   