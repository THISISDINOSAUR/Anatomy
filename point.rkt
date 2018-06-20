#lang racket

(provide (all-defined-out))

(struct point (x y z)
  #:auto-value 0
  #:transparent
  #:mutable)
