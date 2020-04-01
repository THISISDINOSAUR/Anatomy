#lang br

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(require "../render/anatomy-canvas.rkt")

(define (a-render id)
  (create-and-show-anatomy-canvas id))