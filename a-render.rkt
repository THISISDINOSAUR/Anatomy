#lang br

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(require "point.rkt"
         "bone.rkt"
         "utils.rkt"
         racket/gui/base)

(define (a-render id)
  (define frame-width 1300)
  (define frame-height 750)
  (define padding 50)
  (define drawing-width (- frame-width (* 2 padding)))
  (define drawing-height (- frame-height (* 2 padding)))
  (define frame (new frame%
                     [label (get-field name id)]
                     [width frame-width]
                     [height frame-height]))
  (define canvas
    (new canvas% [parent frame]
       [paint-callback
        (lambda (canvas dc)
          (send id render-without-parent dc))]))
  (define dc (send canvas get-dc))
  (define rect (send id tree-bounding-rect-without-parent))
  (define rect-width (bounding-rect-width rect))
  (define rect-height (bounding-rect-height rect))
  (define scale (min (/ drawing-width rect-width) (/ drawing-height rect-height)))
  (send dc translate padding padding)
  (send dc set-scale scale scale)
  (send dc translate (- (bounding-rect-min-x rect)) (- (bounding-rect-min-y rect)))
  (send frame show #t))