#lang racket

(provide (all-defined-out))

(struct point (x y z)
  #:auto-value 0
  #:transparent
  #:mutable)

(define (add-points point1 point2)
  (point (+ (point-x point1) (point-x point2)) (+ (point-y point1) (point-y point2)) (+ (point-z point1) (point-z point2))))

(define (subtract-points point1 point2)
  (point (- (point-x point1) (point-x point2)) (- (point-y point1) (point-y point2)) (- (point-z point1) (point-z point2))))

(define (scale-point point1 scale)
  (point (* (point-x point1) scale) (* (point-y point1) scale) (* (point-z point1) scale)))

(define (negate-point point1)
  (point (- (point-x point1)) (- (point-y point1)) (- (point-z point1))))
