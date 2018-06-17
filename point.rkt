#lang racket

(provide (all-defined-out))

(struct point (x y)
  #:auto-value 0
  #:transparent
  #:mutable)
