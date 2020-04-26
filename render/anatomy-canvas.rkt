#lang racket

(provide (all-defined-out))

(require "../render/draw.rkt"
         "../render/drawable-polygon.rkt"
         "../structs/point.rkt"
         "../structs/rect.rkt"
         "../structs/polygon-tree.rkt"
         "../string.rkt"
         "../bone.rkt"
         racket/gui/base)

(define (create-and-show-anatomy-canvas bone)
  (define frame-width 1300)
  (define frame-height 750)
  (define padding 50)
  (define frame (new frame%
                     [label (get-field name bone)]
                     [width frame-width]
                     [height frame-height]))
  
  (define canvas
    (new anatomy-canvas%
         [parent frame]
         [root-bone bone]
         [drawable-polygons-hash (make-hash (bone->drawable-polygons-pairs bone))]
         [width frame-width]
         [height frame-height]
         [padding padding]))
 
  (send frame show #t))

(define anatomy-canvas%
  (class canvas%
    (inherit get-width get-height get-dc refresh)

     (init-field
     [root-bone #f]
     [drawable-polygons-hash #f]
     [width 0]
     [height 0]
     [padding 0])

    (super-new)

    (define drawable-polygons (hash-keys drawable-polygons-hash))

    (define draw-mode #f)
    (define just-entered-draw-mode #f)
    (define draw-mode-points '())
    (define drawn-polygons '())
    
    (define mouse-labeled-point-for-selected #f)
    (define selected '())

    (define drawing-width (- width (* 2 padding)))
    (define drawing-height (- height (* 2 padding)))
    (define rect (drawable-polygons->bounding-rect drawable-polygons))
    (define rect-width (bounding-rect-width rect))
    (define rect-height (bounding-rect-height rect))
    (define scale (min (/ drawing-width rect-width) (/ drawing-height rect-height)))
    (define translation-x (- (bounding-rect-min-x rect)))
    (define translation-y (- (bounding-rect-min-y rect)))
    
    (send (get-dc) translate padding padding)
    (send (get-dc) set-scale scale scale)
    (send (get-dc) translate translation-x translation-y)

    (define/override (on-paint)
      (define dc (get-dc))
      (draw-drawable-polygons drawable-polygons dc)
      (draw-mouse-label-if-needed))

    (define/override (on-event event)
      (case (send event get-event-type)
        ['motion
         (define mouse-p (point (send event get-x) (send event get-y) 0))
         (cond
           [draw-mode
            (set! drawable-polygons
                  (map (lambda (polygon)
                         (drawable-polygon-highlighted?-set polygon #f))
                  drawable-polygons))]
           [else
            (define
              highlighted
              (drawable-polygons-intersected-by-point
               drawable-polygons
               (screen-point-to-root-drawable-polygon-point mouse-p)))

            (set! drawable-polygons
                  (map (lambda (polygon)
                         (if (member polygon highlighted)
                             (drawable-polygon-highlighted?-set polygon #t)
                             (drawable-polygon-highlighted?-set polygon #f)))
                       drawable-polygons))])
         
         (update-mouse-labeled-point-for-selected mouse-p)
         (refresh)]
        ['left-down
         (define mouse-p (point (send event get-x) (send event get-y) 0))
         (cond
           [draw-mode
            (display
             (string-append
              (if just-entered-draw-mode "" ", ")
              (point->description-string-2d-rounded
               (screen-point-to-polygon-point mouse-p (car selected)))))
            (set! just-entered-draw-mode #f)]
           [else
            (set!
             selected
             (drawable-polygons-intersected-by-point
              drawable-polygons
              (screen-point-to-root-drawable-polygon-point mouse-p)))

            (set! drawable-polygons
                  (map (lambda (polygon)
                         (if (member polygon selected)
                             (drawable-polygon-selected?-set polygon #t)
                             (drawable-polygon-selected?-set polygon #f)))
                       drawable-polygons))
            ;todo: add ability to rotate through overlapping bones
         
            (update-mouse-labeled-point-for-selected mouse-p)

            (refresh)])
         ]))

    (define/override (on-char ke)
      (define key-code (send ke get-key-code))
      (case key-code
        ['release
         null]
        [else
         (match key-code
           [(== #\d)
            (toggle-draw-mode)]
           [(== #\p)
            ;todo printing when in draw mode?
            (for ([polygon selected])
              (displayln (bone->description-string
                          (hash-ref drawable-polygons-hash polygon))))]
           [_
            void])]))

    (define (key-code-downcase k)
      (cond
        [(char? k) (char-downcase k)]
        [else k]))

    (define (toggle-draw-mode)
      (cond
        [draw-mode
         (displayln "")
         (set! draw-mode #f)
         (set! just-entered-draw-mode #f)]
        [(not (equal? selected '()))
         (set! draw-mode #t)
         (set! just-entered-draw-mode #t)]))

    (define (screen-point-to-polygon-point screen-point polygon)
      (absolute-point->placement-point
       (screen-point-to-root-polygon-point screen-point)
       (drawable-polygon-original-placement polygon)))

    (define (screen-point-to-root-polygon-point screen-point)
      (point-invert-y
            (screen-point-to-root-drawable-polygon-point screen-point)))

    (define (screen-point-to-root-drawable-polygon-point screen-point)
      (subtract-points
       (divide-point
        (subtract-points screen-point (point padding padding 0))
        scale)
       (point translation-x translation-y 0)))

    (define (update-mouse-labeled-point-for-selected mouse-point)
      (cond 
        [(equal? selected '())
         (set! mouse-labeled-point-for-selected #f)]
        [else
         (define selected-polygon (car selected))
         (define point
           (screen-point-to-root-polygon-point mouse-point))
         (set!
          mouse-labeled-point-for-selected
          (point->drawable-labeled-point
           point
           (screen-point-to-polygon-point mouse-point selected-polygon)))]))
    
    (define/public (draw-mouse-label-if-needed)
      (cond 
        [(not (equal? mouse-labeled-point-for-selected #f))
          (draw-mouse-label mouse-labeled-point-for-selected (get-dc))]
        [else null]))
    ))