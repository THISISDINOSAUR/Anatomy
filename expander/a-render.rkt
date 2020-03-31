#lang br

;MAIN TODO
;connection point display
;mouse point display
;cleanup

(provide (matching-identifiers-out #rx"^a-" (all-defined-out)))

(require "../render/drawable-polygon.rkt"
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
  
  (define canvas
    (new anatomy-canvas%
         [parent frame]
         [paint-callback
          (lambda (canvas dc)
            (draw-drawable-polygons (get-field drawable-polygons canvas) dc)
            (send canvas draw-mouse-label))]
         [root-bone id]
         [drawable-polygons (polygon-tree->drawable-polygons (get-field polygon-tree id))]
         [width frame-width]
         [height frame-height]
         [padding padding]))
 
  (send frame show #t))

(define (draw-drawable-polygons polygons dc)
  (for ([(drawable-polygon) polygons])
    (draw-polygon drawable-polygon dc)
    
    (draw-connection-point (drawable-polygon-labeled-connection-point drawable-polygon) dc)))

(define (draw-polygon polygon dc)
  (cond 
    [(drawable-polygon-selected? polygon)
     (send dc set-brush (make-object color% 200 100 100 0.3) 'solid)]
    [(drawable-polygon-highlighted? polygon)
     (send dc set-brush (make-object color% 20 20 100 0.3) 'solid)]
    [else
     (send dc set-brush (make-object color% 255 246 222 0.3) 'solid)])
  (send dc set-pen (make-object color% 60 60 60 0.8) 8 'solid)
  (send dc draw-path (points->path (drawable-polygon->draw-points polygon)))

  (if (or (drawable-polygon-selected? polygon) (drawable-polygon-highlighted? polygon))
      (draw-polygon-labels polygon dc)
      null))

(define (draw-polygon-labels polygon dc)
  (define labeled-polygon (drawable-polygon-labeled-polygon polygon))
  (define index 0)
  (map (lambda (point label)
         (draw-point-label point label index dc)
         (set! index (+ index 1)))
       (labeled-polygon-polygon labeled-polygon) (labeled-polygon-labels labeled-polygon)))

;TODO labels should be actual labels and not points probably
(define (draw-point-label draw-point label index dc)
  (send dc set-pen "white" 0 'transparent)
  (send dc set-brush (make-object color% 61 252 201 0.9) 'solid)
  (define draw-size 6)
  (define p (subtract-points draw-point (point (/ draw-size 2) (/ draw-size 2) 0)))
  (send dc draw-ellipse (point-x p) (point-y p) draw-size draw-size)

  (send dc set-font (make-font #:size 10 #:family 'modern #:weight 'bold))
  (send dc set-text-foreground (make-object color% 0 204 150))
  (send dc set-text-background "red")
  (define text-draw-point (add-points draw-point (point 0 (/ draw-size 2) 0)))
  (define text (string-append (~a index) ":" (point->description-string-2d-rounded label)))
  (send dc draw-text text (point-x text-draw-point) (point-y text-draw-point)))
    

(define (draw-connection-point con-point dc)
  (send dc set-pen (make-object color% 200 50 50 0.9) 6 'solid)
  (send dc set-brush "white" 'transparent)
  (define draw-size 20)
  (define draw-point (subtract-points (labeled-point-point con-point) (point (/ draw-size 2) (/ draw-size 2) 0)))
  (send dc draw-ellipse (point-x draw-point) (point-y draw-point) draw-size draw-size))
  ;TODO: only render connection points when highlighted (but also render parent connection point)
  ;will also need to change connection point label depending on parent or child
  ;at the moment it just renders the point on the child, probs also want angle
  ;(send dc set-font (make-font #:size 15 #:family 'modern))
  ;(send dc set-text-foreground "red")
  ;(define text-draw-point (add-points (labeled-point-point con-point) (point 0 (/ draw-size 2) 0)))
  ;(send dc draw-text (point->description-string-2d-rounded (labeled-point-label con-point)) (point-x text-draw-point) (point-y text-draw-point)))
   

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