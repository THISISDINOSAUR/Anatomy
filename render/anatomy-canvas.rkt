#lang racket

(provide (all-defined-out))

;TODO add edit mode where you can drag points

;gaps in bones?
;soft body
;how to do highly repeated bones? (e.g. vertebrae)

;TODO add ability to select drawn bones/draw multiple in a row

(require "../render/draw.rkt"
         "../render/drawable-polygon.rkt"
         "../render/canvas-state.rkt"
         "../structs/point.rkt"
         "../structs/rect.rkt"
         "../structs/polygon-tree.rkt"
         "../string.rkt"
         "../bone.rkt"
         racket/gui/base
         (prefix-in image: 2htdp/image))

(define frame-width 1300)
(define frame-height 750)
(define padding 50)
(define frame (new frame%
                   [label "Bone name pending"]
                   [width frame-width]
                   [height frame-height]))

(define interface-mode-message
  (new message%
       [parent frame]
       [label DEFAULT-MODE-LABEL]
       [auto-resize #t]))	 


(define (create-and-show-anatomy-canvas bone)
  (send frame set-label (get-field name bone))
  
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

    (define reference-image-head (read-bitmap  "../references/herrerCropped.JPG" #:backing-scale 0.2))
    (define reference-image-hip (read-bitmap  "../references/herrerHipCropped.JPG" #:backing-scale 0.27))
    (define reference-image-spine (read-bitmap "../references/herrerSpineCropped.JPG" #:backing-scale 0.27))
    (define reference-image-whole (read-bitmap "../references/herrerWholeResized.JPG" #:backing-scale 0.27))
    
    (define drawable-polygons (hash-keys drawable-polygons-hash))

    (define interface-mode DEFAULT-MODE)
    (define interface-mode-state #f)

    (define show-point-labels? #t)

    (define (in-draw-mode?)
      (equal? interface-mode DRAW-MODE))
    
    (define drawn-polygons '())

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

      ;(draw-reference-image reference-image-head 950 -150)
      ;(draw-reference-image reference-image-spine 540 -70)
      (draw-reference-image reference-image-whole -230 220)
      ;(draw-reference-image reference-image-hip -120 270)
      

      (draw-drawable-polygons drawable-polygons show-point-labels? interface-mode dc)
      (draw-drawn-polygons drawn-polygons show-point-labels? dc)
      (cond [(in-draw-mode?)
             (draw-currently-drawing-points (draw-mode-state-drawn-points interface-mode-state) dc)])
      (draw-mouse-label-if-needed))

     (define/public (draw-mouse-label-if-needed)
      (cond 
        [(not (equal? mouse-labeled-point-for-selected #f))
          (draw-mouse-label mouse-labeled-point-for-selected (get-dc))]
        [else null]))

    (define (draw-reference-image image x y)
      (define dc (get-dc))
      (send dc draw-bitmap	
       image
       (+ x (/ (- (image:image-width image)) 2))
       (+ y (/ (- (image:image-height image)) 2))))

    (define/override (on-event event)
      (define mouse-p (point (send event get-x) (send event get-y) 0))
      (case (send event get-event-type)
        ['motion
         (set! mouse-position mouse-p)
         (cond
           [(in-draw-mode?)
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
         ]
        ['left-down
         (update-mouse-labeled-point-for-selected mouse-p)
         (cond
           [(in-draw-mode?) (draw-mode-mouse-down mouse-p)]
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
            ])
         ])
      (update-mouse-labeled-point-for-selected mouse-p)
      (refresh))
    
    (define (draw-mode-mouse-down mouse-p)
      (set-draw-mode-state-drawn-points!
       interface-mode-state
       (append
        (draw-mode-state-drawn-points interface-mode-state)
        (list mouse-labeled-point-for-selected)))
               
      (display
       (string-append
        (if (draw-mode-state-just-entered? interface-mode-state) "" ", ")
        (labeled-point-label mouse-labeled-point-for-selected)))
      (set-draw-mode-state-just-entered?! interface-mode-state #f))

    (define/override (on-char ke)
      (define key-code (send ke get-key-code))
      (case key-code
        ['release
         null]
        [else
         (match (key-code-downcase key-code)
           [(== #\h)
            (set! show-point-labels? (not show-point-labels?))
            (refresh)]
           [_
            (match interface-mode
              [(== DEFAULT-MODE)
               (match (key-code-downcase key-code)
                 [(== #\d)
                  (enable-draw-mode #f)]
                 [(== #\n)
                  (cond [(not (equal? (selected) '()))
                         (enable-name-bone-mode)])]
           
                 [(== #\p)
                  (for ([polygon (selected)])
                    (displayln (bone->description-string
                                (hash-ref drawable-polygons-hash polygon))))]
           
                 ;connection labels don't update when rotating a polygon like this (or the data model at all)
                 [(== #\q)
                  (for ([polygon (selected)])
                    (rotate-drawable-polygon polygon #t))]
                 [(== #\e)
                  (for ([polygon (selected)])
                    (rotate-drawable-polygon polygon #f))]
              
                 [_ void])]
           
              [(== NAME-BONE-MODE)
               void]
           
              [(== DRAW-MODE)
               (match (key-code-downcase key-code)
                 [(== #\return)
                  (end-draw-mode)]
                 [_ void]
                 )])])]))

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

    (define (enable-name-bone-mode)
      (set! interface-mode NAME-BONE-MODE)
      (send interface-mode-message set-label NAME-BONE-MODE-LABEL)
      (set! interface-mode-state
            (name-bone-mode-state
             ""
             mouse-position
             (labeled-point-label mouse-labeled-point-for-selected)
             (car (selected))))

      (define new-bone-name-dialog
        (new dialog%
             [label "New bone name:"]
             [width 300]
             [height 100]))

      (define text-field
        (new text-field%	 
             [parent new-bone-name-dialog]
             [label #f]
             [callback
              (lambda (text-field event)
                (case (send event get-event-type)
                  ['text-field-enter
                    (set-name-bone-mode-state-name! interface-mode-state (send text-field get-value))
                    (send new-bone-name-dialog show #f)
                    (end-name-bone-mode)]))]))
      
      (send new-bone-name-dialog show #t)
      )
      
    (define (end-name-bone-mode)
      (enable-draw-mode interface-mode-state))

      
    (define (enable-draw-mode name-bone-mode-state)
      (set! interface-mode DRAW-MODE)
      (send interface-mode-message set-label DRAW-MODE-LABEL)
      (cond
        [name-bone-mode-state
          (set! interface-mode-state
            (draw-mode-state
             #t
             #t
             '()
             (name-bone-mode-state-draw-origin name-bone-mode-state)
             (name-bone-mode-state-draw-origin-in-parent-bone-label name-bone-mode-state)
             (name-bone-mode-state-name name-bone-mode-state)
             (name-bone-mode-state-parent-polygon name-bone-mode-state)))
          (display (string-append (name-bone-mode-state-name name-bone-mode-state) " = "))
          ]
        [else
         (define label (if mouse-labeled-point-for-selected
                           (labeled-point-label mouse-labeled-point-for-selected)
                           #f))
         (define selected-polygon (if (equal? (selected) '())
                                      #f
                                      (car (selected))))
         (set! interface-mode-state
            (draw-mode-state #t #f '() mouse-position label #f selected-polygon))]))
          

    (define (end-draw-mode)
      (displayln "")
      (cond [(draw-mode-state-name interface-mode-state)
             (define parent-bone (hash-ref drawable-polygons-hash (draw-mode-state-parent-polygon interface-mode-state)))
             (displayln (string-append (get-field name parent-bone) " ~ " (draw-mode-state-name interface-mode-state) " = "
                                       (draw-mode-state-draw-origin-in-parent-bone-label interface-mode-state) " ~ [0, 0], 0"))
             (displayln "")])
             
      (set! interface-mode DEFAULT-MODE)
      (send interface-mode-message set-label DEFAULT-MODE-LABEL)

      (define drawn-points (draw-mode-state-drawn-points interface-mode-state))
         (cond
           [(not (equal? drawn-points '()))
            (set! drawn-polygons
                  (append
                   drawn-polygons
                   (list (labeled-points->labeled-polygon drawn-points))))
            ]))
      

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

    ;todo, why save state here? this really should be a function for "mouse-labeled-point-for-selected"
    ;esp since we save the mouse point anyeway (maybe that's why, maybe we never used to save the mouse point) 
    (define (update-mouse-labeled-point-for-selected mouse-point)
      (cond
        [(and (equal? (selected) '()) (not (in-draw-mode?)))
         (set! mouse-labeled-point-for-selected #f)]
        [else
         (define
           label-point
           (if (equal? (selected) '())
               (subtract-points mouse-point (draw-mode-state-draw-origin interface-mode-state))
                                
               (if (and (in-draw-mode?) (draw-mode-state-use-initial-mouse-as-origin? interface-mode-state))
                   (divide-point
                    (point-invert-y
                     (rotate-point (subtract-points mouse-point (draw-mode-state-draw-origin interface-mode-state))
                                   (placement-angle (drawable-polygon-original-placement (car (selected))))))
                    scale)
                   
                   (screen-point-to-polygon-point mouse-point (car (selected))))))
         (set!
          mouse-labeled-point-for-selected
          (point->drawable-labeled-point
           (screen-point-to-root-polygon-point mouse-point)
           label-point))]))
    
   ))