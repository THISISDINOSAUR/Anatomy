#lang racket

(provide (all-defined-out))

(require racket/draw)

(struct point (x y z)
  #:auto-value 0
  #:transparent
  #:mutable)

;TODO this should be a procedure? All caps?
(define point-zero (point 0 0 0))

(define (add-points point1 point2)
  (point (+ (point-x point1) (point-x point2)) (+ (point-y point1) (point-y point2)) (+ (point-z point1) (point-z point2))))

(define (add-points-list points)
  (foldl add-points point-zero points))
  
(define (subtract-points point1 point2)
  (point (- (point-x point1) (point-x point2)) (- (point-y point1) (point-y point2)) (- (point-z point1) (point-z point2))))

(define (scale-point-dimension-wise point1 x-scale y-scale z-scale)
  (point (* (point-x point1) x-scale) (* (point-y point1) y-scale) (* (point-z point1) z-scale)))

(define (scale-point point1 scale)
  (scale-point-dimension-wise point1 scale scale scale))

(define (divide-point point1 divider)
  (scale-point point1 (/ 1.0 divider)))

(define (negate-point point1)
  (point (- (point-x point1)) (- (point-y point1)) (- (point-z point1))))

(define (rotate-point point1 angle)
  (rotate-point-about-point point1 angle point-zero))

; THIS DID ROTATE ANTICLOCKWISE, BUT NOW DOES CLOCKWISE
; we changed the handidness of the system
; y used to point down, now it points up
;https://stackoverflow.com/questions/2259476/rotating-a-point-about-another-point-2d
(define (rotate-point-about-point point1 angle rotation-point)
  (define radians (degrees->radians angle))
  (define translated-point (subtract-points point1 rotation-point))
  (define rotated-point 
    (point (+ (* (point-x translated-point) (cos radians)) (* (point-y translated-point) (sin radians)))
           (+ (- (* (point-x translated-point) (sin radians))) (* (point-y translated-point) (cos radians)))
           (point-z translated-point)))
  (add-points rotated-point rotation-point))

(define (average-points points)
  (divide-point (add-points-list points) (length points)))

(define (distance-between-points point1 point2)
  (define p (subtract-points point1 point2))
  (sqrt (+
         (* (point-x p) (point-x p))
         (* (point-y p) (point-y p))
         (* (point-z p) (point-z p)))))

(define (operation-on-point-dimension op dimension point1 val)
  (match dimension
    [(== point-x)
     (point
      (op (point-x point1) val)
      (point-y point1)
      (point-z point1))]
    [(== point-y)
     (point
      (point-x point1)
      (op (point-y point1) val)
      (point-z point1))]
    [(== point-z)
     (point
      (point-x point1)
      (point-y point1)
      (op (point-z point1) val))]
    [_
     void]))

(define (point->list point1)
  (list (point-x point1) (point-y point1) (point-z point1)))

(define (points->path points)
  (let ([p (new dc-path%)])
    (define firstPoint (car points))
    (send p move-to (point-x firstPoint) (point-y firstPoint))
    (for ([(point) points])
      (send p line-to (point-x point) (point-y point)))
    (send p line-to (point-x firstPoint) (point-y firstPoint))
    p))
   