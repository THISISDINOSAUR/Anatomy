#lang racket

(provide (all-defined-out))

;TODO add edit mode where you can drag points
;TODO draw mode without a bone selected (maybe with origin at the cursor). Not sure what to do about rotation tho


;gaps in bones?
;soft body

(require "../render/draw.rkt"
         "../render/drawable-polygon.rkt"
         "../structs/point.rkt"
         "../structs/rect.rkt"
         "../structs/polygon-tree.rkt"
         "../string.rkt"
         "../bone.rkt"
         racket/gui/base
         (prefix-in image: 2htdp/image))

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
         [style '(transparent)]
         [root-bone bone]

         ;drawable-polygons to bones
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

    (define reference-image (read-bitmap  "../references/herrerCropped.JPG" #:backing-scale 0.2))
    (define reference-image-hip (read-bitmap  "../references/herrerHipCropped.JPG" #:backing-scale 0.27))
    
    (define drawable-polygons (hash-keys drawable-polygons-hash))

    (define draw-mode #f)
    (define just-entered-draw-mode #f)
    (define draw-mode-points '())
    (define drawn-polygons '())
    (define draw-origin #f)

    (define mouse-position #f)
    
    (define mouse-labeled-point-for-selected #f)

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

    (define (selected)
      (filter
       (lambda (drawable) (drawable-polygon-selected? drawable))
       drawable-polygons))
      

    (define (refresh-drawable-polygons-from-hash)
      (set! drawable-polygons (hash-keys drawable-polygons-hash)))

    (define/override (on-paint)
      (define dc (get-dc))

      ;(draw-reference-image reference-image 950 -150)
      (draw-reference-image reference-image-hip -120 270)

      (draw-drawable-polygons drawable-polygons draw-mode dc)
      (draw-drawn-polygons drawn-polygons dc)
      (draw-currently-drawing-points draw-mode-points dc)
      (draw-mouse-label-if-needed))

    (define (draw-reference-image image x y)
      (define dc (get-dc))
      (send dc draw-bitmap	
       image
       (+ x (/ (- (image:image-width image)) 2))
       (+ y (/ (- (image:image-height image)) 2))))

    (define/override (on-event event)
      (case (send event get-event-type)
        ['motion
         (define mouse-p (point (send event get-x) (send event get-y) 0))
         (set! mouse-position mouse-p)
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
           [draw-mode (draw-mode-mouse-down mouse-p)]
           [else
            (define intersected
              (drawable-polygons-intersected-by-point
               drawable-polygons
               (screen-point-to-root-drawable-polygon-point mouse-p)))

            (set! drawable-polygons
                  (map (lambda (polygon)
                         (if (member polygon intersected)
                             (drawable-polygon-selected?-set polygon #t)
                             (drawable-polygon-selected?-set polygon #f)))
                       drawable-polygons))
            ;todo: add ability to rotate through overlapping bones
         
            (update-mouse-labeled-point-for-selected mouse-p)

            (refresh)])
         ]))

    (define (draw-mode-mouse-down mouse-p)
       (define
         label
         (point->description-string-2d-rounded
          (cond
            [(equal? (selected) '())
             (subtract-points mouse-p draw-origin)]
            [else
             (screen-point-to-polygon-point mouse-p (car (selected)))])))
               
      (set!
       draw-mode-points
       (append
        draw-mode-points
        (list (labeled-point (screen-point-to-root-drawable-polygon-point mouse-p) label))))
               
      (display
       (string-append
        (if just-entered-draw-mode "" ", ")
        label))
      (set! just-entered-draw-mode #f))

    (define/override (on-char ke)
      (define key-code (send ke get-key-code))
      (case key-code
        ['release
         null]
        [else
         (match (key-code-downcase key-code)
           [(== #\d)
            (toggle-draw-mode)]
           [(== #\p)
            ;todo printing when in draw mode?
            (for ([polygon (selected)])
              (displayln (bone->description-string
                          (hash-ref drawable-polygons-hash polygon))))]
           [(== #\q)
            (for ([polygon (selected)])
              (rotate-drawable-polygon polygon #t))]
           [(== #\e)
            (for ([polygon (selected)])
              (rotate-drawable-polygon polygon #f))]
           [_
            void])]))

    (define (key-code-downcase k)
      (cond
        [(char? k) (char-downcase k)]
        [else k]))

    (define (rotate-drawable-polygon polygon clockwise)
      (define rotation (if clockwise 10 -10))
      (define new-polygon
        (rotate-drawable-polygon-around-parent polygon rotation))

      (define bone (hash-ref drawable-polygons-hash polygon))
      (hash-remove! drawable-polygons-hash polygon)
      (hash-set! drawable-polygons-hash new-polygon bone)
      
      (refresh-drawable-polygons-from-hash)

      (define new-angle (- (send bone angle) rotation))
      (send bone set-angle! new-angle)
      (println new-angle))

    (define (toggle-draw-mode)
      (cond
        [draw-mode
         (displayln "")
         (set! draw-mode #f)
         (set! just-entered-draw-mode #f)
         (set! draw-origin #f)

         (cond
           [(not (equal? draw-mode-points '()))
            (set! drawn-polygons
                  (append
                   drawn-polygons
                   (list (labeled-points->labeled-polygon draw-mode-points))))
            (set! draw-mode-points '())])]
        [else
         (set! draw-mode #t)
         (set! just-entered-draw-mode #t)
         (set! draw-origin mouse-position)]))

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
        [(and (equal? (selected) '()) (equal? draw-origin #f))
         (set! mouse-labeled-point-for-selected #f)]
        [else
         (define
           label-point
           (if (equal? (selected) '())
               (subtract-points mouse-point draw-origin)
               (screen-point-to-polygon-point mouse-point (car (selected)))))
         (set!
          mouse-labeled-point-for-selected
          (point->drawable-labeled-point
           (screen-point-to-root-polygon-point mouse-point)
           label-point))]))
    
    (define/public (draw-mouse-label-if-needed)
      (cond 
        [(not (equal? mouse-labeled-point-for-selected #f))
          (draw-mouse-label mouse-labeled-point-for-selected (get-dc))]
        [else null]))))