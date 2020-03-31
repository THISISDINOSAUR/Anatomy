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
  (define frame (new frame%
                     [label (get-field name id)]
                     [width frame-width]
                     [height frame-height]))

  (define drawable-polygons
    (polygon-tree->drawable-polygons (get-field polygon-tree id)))
  
  (define canvas
    (new anatomy-canvas%
         [parent frame]
         [paint-callback
          (lambda (canvas dc)
            (send id render-without-parent dc)
            (draw-drawable-polygons drawable-polygons dc)
            (send canvas draw-mouse-label))]
         [root-bone id]
         [drawable-polygons drawable-polygons]
         [width frame-width]
         [height frame-height]
         [padding padding]))
 
  (send frame show #t))

(define (draw-drawable-polygons polygons dc)
  (for ([(drawable-polygon) polygons])
    (draw-polygon drawable-polygon dc)
    
    (draw-connection-point (drawable-polygon-labeled-connection-point drawable-polygon) dc)))

(define (draw-polygon polygon dc)
  (send dc set-brush (make-object color% 255 246 222 0.3) 'solid)
  (send dc set-pen (make-object color% 60 60 60 0.8) 8 'solid)
  (send dc draw-path (points->path (drawable-polygon->draw-points polygon))))

(define (draw-connection-point con-point dc)
  (send dc set-pen (make-object color% 200 50 50 0.9) 6 'solid)
  (send dc set-brush "white" 'transparent)
  (define draw-size 20)
  (define draw-point (subtract-points (labeled-point-point con-point) (point (/ draw-size 2) (/ draw-size 2) 0)))
  (send dc draw-ellipse (point-x draw-point) (point-y draw-point) draw-size draw-size)

  ;TODO: only render connection points when highlighted (but also render parent connection point)
  ;will also need to change connection point label depending on parent or child
  ;at the moment it just renders the point on the child
  (send dc set-font (make-font #:size 15 #:family 'modern))
  (send dc set-text-foreground "red")
  (define text-draw-point (add-points (labeled-point-point con-point) (point 0 (/ draw-size 2) 0)))
  (send dc draw-text (point->description-string-2d-rounded (labeled-point-label con-point)) (point-x text-draw-point) (point-y text-draw-point)))
   
;TODO ANGLES ARE THE WRONG WAY AROUND AND I DON'T KNOW WHY
;I think we drawing upside down
;I want, and assume, y is up, but I think it's down when we drawing
;this means we need an additional translation step :O


;TODO definitely move this into a seperate file too
;currently in expander folder
;expander folder doesn't need to know shit about this (and probs most of above too)
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
    (define absolute-mouse-point #f)
    (define selected #f)

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