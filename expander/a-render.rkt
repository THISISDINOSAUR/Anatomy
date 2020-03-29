#lang br

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(require "../render/polygon-tree-render.rkt"
         "../structs/point.rkt"
         "../structs/rect.rkt"
         "../structs/polygon-tree.rkt"
         "../bone.rkt"
         "../utils.rkt"
         "../string.rkt"
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

  ;TODO why do I do all this here and not as part of the canvas?
  (define rect (polygon-tree->bounding-rect (get-field polygon-tree id)))
  (define rect-width (bounding-rect-width rect))
  (define rect-height (bounding-rect-height rect))
  (define scale (min (/ drawing-width rect-width) (/ drawing-height rect-height)))

  (define drawable-tree
    (polygon-tree->drawable-polygons (get-field polygon-tree id)))
  
  (define canvas
    (new anatomy-canvas%
         [parent frame]
         [paint-callback
          (lambda (canvas dc)
            (send id render-without-parent dc)
            (draw-drawable-tree drawable-tree dc)
            (send canvas draw-mouse-label))]
         [root-bone id]
         [drawable-tree drawable-tree]
         [padding padding]
         [scale scale]
         [translation-x (- (bounding-rect-min-x rect))]
         [translation-y (- (bounding-rect-min-y rect))]
         ))
 
  (send frame show #t))

(define (draw-drawable-tree tree dc)
  (send dc set-brush (make-object color% 255 246 222 0.3) 'solid)
  (send dc set-pen (make-object color% 60 60 60 0.8) 8 'solid)

  (for ([(drawable-polygon) tree])
    (send dc draw-path (points->path (drawable-polygon->draw-points drawable-polygon)))))


;TODO definitely move this into a seperate file too
;currently in expander folder
;expander folder doesn't need to know shit about this (and probs most of above too)
(define anatomy-canvas%
  (class canvas%
    (inherit get-width get-height get-dc refresh)

     (init-field
     [root-bone #f]
     [drawable-tree #f]
     [padding 0]
     [scale 1]
     [translation-x 0]
     [translation-y 0])

    (super-new)

    (define mouse-label-point #f)
    (define absolute-mouse-point #f)
    (define selected #f)

    (send (get-dc) translate padding padding)
    (send (get-dc) set-scale scale scale)
    (send (get-dc) translate translation-x translation-y)

    (define/override (on-event event)
      (case (send event get-event-type)
        ['motion
         (send root-bone set-tree-highlighted #f)
         
         (define mouse-point (point (send event get-x) (send event get-y) 0))
         (define highlighted
           (send root-bone bone-intersected-by-absolute-point-without-parent (screen-point-to-root-bone-point mouse-point)))
         (if (empty? highlighted) null (set-field! highlighted? highlighted #t))
         
         (cond 
          [(empty? selected)
           null]
           [else
           (set! absolute-mouse-point (screen-point-to-root-bone-point mouse-point))
            (set! mouse-label-point 
              (send root-bone absolute-point->bone-point-without-parent absolute-mouse-point selected))
            ])
         
         (refresh)
         ]
         ['left-down
         (send root-bone set-tree-selected #f)
         (set! selected #f)
         (set! mouse-label-point #f)
         
         (define mouse-point (point (send event get-x) (send event get-y) 0))
         (set! selected
           (send root-bone bone-intersected-by-absolute-point-without-parent (screen-point-to-root-bone-point mouse-point)))
         (cond 
          [(empty? selected)
           null]
           [else
            (set-field! selected? selected #t)
            (set! absolute-mouse-point (screen-point-to-root-bone-point mouse-point))
            ])
         (refresh)
         ]
        ))

    (define (screen-point-to-root-bone-point screen-point)
      (subtract-points
       (divide-point
        (subtract-points screen-point (point padding padding 0))
        scale)
       (point translation-x translation-y 0)))

    (define/public (draw-mouse-label)
      (cond 
        [(and mouse-label-point (not (equal? mouse-label-point null)))
          (define dc (get-dc))
          (send dc set-font (make-font #:size 10 #:family 'modern #:weight 'bold))
          (send dc set-text-foreground (make-object color% 130 50 100))
          (send dc set-text-background "red")
          (define text-draw-point (add-points absolute-mouse-point (point 0 10 0)))
          (send dc draw-text (point->description-string-2d-rounded mouse-label-point) (point-x text-draw-point) (point-y text-draw-point))]
        [else null]))
    ))