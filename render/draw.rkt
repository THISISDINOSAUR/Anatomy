#lang racket

;TODO: draw bone names? Seems useful, bone struct has the info, just need to give to drawable polygon

(define OUTLINE-THICKNESS 3)

(provide draw-drawn-polygons
         draw-currently-drawing-points
         draw-drawable-polygons
         draw-mouse-label)

(require "../render/drawable-polygon.rkt"
         "../structs/point.rkt"
         "../structs/rect.rkt"
         "../structs/polygon-tree.rkt"
         "../bone.rkt"
         racket/gui/base)

(define (draw-drawn-polygons polygons dc)
  (for ([(polygon) polygons])
    (send dc set-brush (make-object color% 255 100 100 0.3) 'solid)
    (send dc set-pen (make-object color% 110 60 60 0.8) OUTLINE-THICKNESS 'solid)
    (send dc draw-path (points->path (labeled-polygon-polygon polygon)))
    (draw-polygon-labels polygon dc)))

(define (draw-currently-drawing-points points dc)
  (if (equal? points '())
      void
      (draw-drawn-polygons
       (list (labeled-points->labeled-polygon points))
       dc)))

(define (draw-drawable-polygons polygons dc)
  (for ([(drawable-polygon) polygons])
    (draw-polygon drawable-polygon dc)

    (cond
     [(or (drawable-polygon-selected? drawable-polygon) (drawable-polygon-highlighted? drawable-polygon))
      (draw-connection-point
       (drawable-polygon-labeled-connection-point drawable-polygon)
       #t
       dc)
      (for ([(connection-point) (drawable-polygon-labeled-child-connection-points drawable-polygon)])
        (draw-connection-point connection-point #t dc))]
     [else
      (draw-connection-point
       (drawable-polygon-labeled-connection-point drawable-polygon)
       #f
       dc)])))

(define (draw-polygon polygon dc)
  (cond 
    [(drawable-polygon-selected? polygon)
     (send dc set-brush (make-object color% 200 100 100 0.3) 'solid)]
    [(drawable-polygon-highlighted? polygon)
     (send dc set-brush (make-object color% 20 20 100 0.3) 'solid)]
    [else
     (send dc set-brush (make-object color% 255 246 222 0.3) 'solid)])
  (send dc set-pen (make-object color% 60 60 60 0.8) OUTLINE-THICKNESS 'solid)
  (send dc draw-path (points->path (drawable-polygon->draw-points polygon)))

  (if (or (drawable-polygon-selected? polygon) (drawable-polygon-highlighted? polygon))
      (draw-polygon-labels (drawable-polygon-labeled-polygon polygon) dc)
      null))

(define (draw-polygon-labels labeled-polygon dc)
  (define index 0)
  (map (lambda (point label)
         (draw-point-label point label index dc)
         (set! index (+ index 1)))
       (labeled-polygon-polygon labeled-polygon) (labeled-polygon-labels labeled-polygon)))

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
  (define text (string-append (~a index) ":" label))
  (send dc draw-text text (point-x text-draw-point) (point-y text-draw-point)))
    
(define (draw-connection-point con-point draw-label? dc)
  (send dc set-pen (make-object color% 200 50 50 0.9) 6 'solid)
  (send dc set-brush "white" 'transparent)
  (define draw-size 20)
  (define draw-point (subtract-points (labeled-point-point con-point) (point (/ draw-size 2) (/ draw-size 2) 0)))
  (send dc draw-ellipse (point-x draw-point) (point-y draw-point) draw-size draw-size)

  (cond
    [draw-label?
     (send dc set-font (make-font #:size 15 #:family 'modern))
     (send dc set-text-foreground "red")
     (define text-draw-point (add-points (labeled-point-point con-point) (point 0 (/ draw-size 2) 0)))
     (send dc draw-text (labeled-point-label con-point) (point-x text-draw-point) (point-y text-draw-point))]
    [else null]))

(define (draw-mouse-label labeled-mouse-point dc)
  (send dc set-font (make-font #:size 10 #:family 'modern #:weight 'bold))
  (send dc set-text-foreground (make-object color% 130 50 100))
  (send dc set-text-background "red")
  (define text-draw-point
    (add-points
     (labeled-point-point labeled-mouse-point)
     (point 0 10 0)))
  (send dc draw-text (labeled-point-label labeled-mouse-point) (point-x text-draw-point) (point-y text-draw-point)))
