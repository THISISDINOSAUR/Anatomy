#lang racket

;MAIN TODO
;connection point display
;mouse point display

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
         [paint-callback
          (lambda (canvas dc)
            (draw-drawable-polygons (get-field drawable-polygons canvas) dc)
            (send canvas draw-mouse-label))]
         [root-bone bone]
         [drawable-polygons (polygon-tree->drawable-polygons (get-field polygon-tree bone))]
         [width frame-width]
         [height frame-height]
         [padding padding]))
 
  (send frame show #t))

(define anatomy-canvas%
  (class canvas%
    (inherit get-width get-height get-dc refresh)

     (init-field
     [root-bone #f]
     [drawable-polygons #f]
     [width 0]
     [height 0]
     [padding 0])

    (super-new)

    (define mouse-label-point #f)
    (define mouse-point #f)

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

    (define/override (on-event event)
      (case (send event get-event-type)
        ['motion
         
         (define mouse-p (point (send event get-x) (send event get-y) 0))
         (define
          highlighted
          (drawable-polygons-intersected-by-point
           drawable-polygons
           (screen-point-to-root-bone-point mouse-p)))

         (set! drawable-polygons
               (map (lambda (polygon)
                      (if (member polygon highlighted)
                          (drawable-polygon-highlighted?-set polygon #t)
                          (drawable-polygon-highlighted?-set polygon #f)))
                    drawable-polygons))
         
         (cond 
           [(equal? mouse-label-point #f)
            null]
           [else
            (set! mouse-point mouse-p)
            ;(set! mouse-label-point 
               ;   (send root-bone absolute-point->bone-point-without-parent mouse-p selected))
            ])
         
         (refresh)
         ]
        ['left-down

         (define mouse-p (point (send event get-x) (send event get-y) 0))
         (define
          selected
          (drawable-polygons-intersected-by-point
           drawable-polygons
           (screen-point-to-root-bone-point mouse-p)))

         (set! drawable-polygons
               (map (lambda (polygon)
                      (if (member polygon selected)
                          (drawable-polygon-selected?-set polygon #t)
                          (drawable-polygon-selected?-set polygon #f)))
                    drawable-polygons))
         ;todo: add ability to rotate through overlapping bones
         
         (set! mouse-label-point #f)
         
         (cond 
           [(empty? selected)
            (set! mouse-point #f)]
           [else
            (set! mouse-point mouse-p)])

         (refresh)]))

    (define (screen-point-to-root-bone-point screen-point)
      (subtract-points
       (divide-point
        (subtract-points screen-point (point padding padding 0))
        scale)
       (point translation-x translation-y 0)))

    ;TODO this is going to be such a pain
    (define/public (draw-mouse-label)
      (cond 
        [(and mouse-label-point (not (equal? mouse-label-point null)))
          (define dc (get-dc))
          (send dc set-font (make-font #:size 10 #:family 'modern #:weight 'bold))
          (send dc set-text-foreground (make-object color% 130 50 100))
          (send dc set-text-background "red")
          (define text-draw-point (add-points mouse-point (point 0 10 0)))
          (send dc draw-text (point->description-string-2d-rounded mouse-label-point) (point-x text-draw-point) (point-y text-draw-point))]
        [else null]))
    ))