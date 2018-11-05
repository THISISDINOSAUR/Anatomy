#lang racket

(provide (all-defined-out))

(struct point (x y z)
  #:auto-value 0
  #:transparent
  #:mutable)

(define point-zero (point 0 0 0))

(define (add-point point1 point2)
  (point (+ (point-x point1) (point-x point2)) (+ (point-y point1) (point-y point2)) (+ (point-z point1) (point-z point2))))

(define (add-points points)
  (foldl add-point point-zero points))
  
(define (subtract-point point1 point2)
  (point (- (point-x point1) (point-x point2)) (- (point-y point1) (point-y point2)) (- (point-z point1) (point-z point2))))

(define (scale-point point1 scale)
  (point (* (point-x point1) scale) (* (point-y point1) scale) (* (point-z point1) scale)))

(define (divide-point point1 divider)
  (scale-point point1 (/ 1.0 divider)))

(define (negate-point point1)
  (point (- (point-x point1)) (- (point-y point1)) (- (point-z point1))))

(define (average-points points)
  (divide-point (add-points points) (length points)))

(define (describe-point point1)
  (string-append "[" (~a (point-x point1)) ", " (~a (point-y point1)) ", " (~a (point-z point1)) "]"))