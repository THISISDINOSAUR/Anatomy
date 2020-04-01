#lang racket

(provide draw-drawable-polygons)

(require "../render/drawable-polygon.rkt"
         "../structs/point.rkt"
         "../structs/rect.rkt"
         "../structs/polygon-tree.rkt"
         "../bone.rkt"
         racket/gui/base)

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
