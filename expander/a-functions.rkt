#lang br

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(require "../structs/point.rkt")

(define (a-trapesium topSpan bottomSpan leftSpan rightSpan)
  (trapesium topSpan bottomSpan leftSpan rightSpan))

(define-macro (a-max VALS ...)
  #'(max VALS ...))

(define-macro (a-min VALS ...)
  #'(min VALS ...))

(define (a-abs val)
  (abs val))

(define (a-distance point1 point2)
  (distance-between-points point1 point2))

(define (a-sqrt val)
  (sqrt val))

(define (a-mag point)
  (distance-between-points point point-zero))

(define-macro (a-average-points POINT-EXPRS ...)
  #'(average-points (list POINT-EXPRS ...)))