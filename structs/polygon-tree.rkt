#lang racket

(provide (all-defined-out))

(require "point.rkt"
         "polygon.rkt")

;(struct polygon-connection (parent child parent-point child-point angle)
;  #:auto-value 0
;  #:transparent
;  #:mutable)

;maybe polygon parent-point own-point angle children

;(struct polygon-tree (polygon connections)
;  #:auto-value 0
;  #:transparent
;  #:mutable)

(struct polygon-tree (polygon parent connection-point-on-parent connection-point angle children)
    #:auto-value #f
    #:transparent
    #:mutable)

(struct placement (point angle)
    #:auto-value #f
    #:transparent
    #:mutable)

(define (points->root-polygon-tree points)
    (polygon-tree points #f #f point-zero 0 '()))

(define (polygon-tree-add-child! parent child point-on-parent point-on-child angle)
    (set-polygon-tree-children! parent (append (polygon-tree-children parent) (list child)))
    (set-polygon-tree-parent! child parent)
    (set-polygon-tree-connection-point-on-parent! child point-on-parent)
    (set-polygon-tree-connection-point! child point-on-child)
    (set-polygon-tree-angle! child angle))

(define (polygon-tree->polygons tree)
  (append (list (polygon-tree-polygon tree))
          (append-map (lambda (child)
                        (polygon-tree->polygons child))
                      (polygon-tree-children tree))))

(define (scale-polygon-tree! tree x y z)
  (set-polygon-tree-polygon!
   tree
   (scale-polygon (polygon-tree-polygon tree) x y z))

  (set-polygon-tree-connection-point!
   tree
   (scale-point-dimension-wise (polygon-tree-connection-point tree) x y z))

  (for ([(child) (polygon-tree-children tree)])
    (set-polygon-tree-connection-point-on-parent!
     child
     (scale-point-dimension-wise (polygon-tree-connection-point-on-parent child) x y z))
    (scale-polygon-tree! child x y z)))


(define (scale-root-only-of-polygon-tree! tree x y z)
  (set-polygon-tree-polygon!
   tree
   (scale-polygon (polygon-tree-polygon tree) x y z))

  (set-polygon-tree-connection-point!
   tree
   (scale-point-dimension-wise (polygon-tree-connection-point tree) x y z))

  (for ([(child) (polygon-tree-children tree)])
    (set-polygon-tree-connection-point-on-parent!
     child
     (scale-point-dimension-wise (polygon-tree-connection-point-on-parent child) x y z))))


;could make this return pos and angle to be absolute placement in tree

(define (polygon-tree->absolute-placement-in-tree tree)
    (cond 
        [(equal? (polygon-tree-parent tree) #f)
            (placement
                (rotate-point (polygon-tree-connection-point tree) (polygon-tree-angle tree))
                (polygon-tree-angle tree))]
        [else
         (define place (polygon-tree->absolute-placement-in-tree (polygon-tree-parent tree)))
         (define current-angle (+ (placement-angle place) (polygon-tree-angle tree)))
         (define rotated-con-point (rotate-point (polygon-tree-connection-point tree) current-angle))
         (define rotate-parent-con-point (rotate-point (polygon-tree-connection-point-on-parent tree) (placement-angle place)))
         (define current-point
           (subtract-points
            (add-points (placement-point place) rotate-parent-con-point)
            rotated-con-point))
         (placement current-point current-angle)]))
         
         #|
         Collected parent angle + current angle
           rotate connection point around that angle
           add that connection point to the collected position
              (still need to do some work on that collected position?)


         
            point on parent minus its parent rotated by total angle (up to and including parent angle)
            add child angle to total angle

                rotate child-point about total angle? (I can't decide if conceptually this should be part of it)
                    (it feels like the angle definitely needs to include the child angle to make the most scale-point-dimension-wise    
                    which would then mean the point should also inclue the child point)
                    I think to decide I need to think about how I actually use this information
                    e.g. to render a polygon, which position do you need?

                    I'm leaning towards it should include this



    (cond 
        [(equal? (polygon-tree-parent tree) #f)
            (rotate-point (polygon-tree-connection-point tree) (polygon-tree-angle tree))]
        [else
            (+ (polygon-tree-angle tree) 
                (polygon-tree-absolute-angle-in-tree (polygon-tree-parent tree)))]))
|#
;(add-points 
 ;               (rotate-point-around-point 
  ;                  (polygon-tree-connection-point
   ;                 )))

;child point rotated around parent point
;add em

#|
(define (absolute-points parent-connection absolute-parent-connection-point absolute-parent-angle)
      (define origin-point (get-field child-point parent-connection))
      (define total-angle (+ absolute-parent-angle (get-field angle parent-connection)))

      (define points-with-child-as-origin
        (map (lambda (point)
               (subtract-points point origin-point))
             (vector->list points)))

      (define rotated-points
        (map (lambda (point)
               (rotate-point point total-angle))
             points-with-child-as-origin))

      (map (lambda (point)
               (add-points point absolute-parent-connection-point))
             rotated-points))|#

;TODO we probably don't need this method
(define (polygon-tree-absolute-angle-in-tree tree)
    (cond 
        [(equal? (polygon-tree-parent tree) #f)
            (polygon-tree-angle tree)]
        [else
            (+ (polygon-tree-angle tree) 
                (polygon-tree-absolute-angle-in-tree (polygon-tree-parent tree)))]))

#|(define (offset-for-connection parent-connection origin-point absolute-parent-connection-point absolute-parent-angle)
      (define add-to-offset (subtract-points (get-field parent-point parent-connection) origin-point))
      (define rotated-add-to-offset (rotate-point add-to-offset absolute-parent-angle))
      (add-points absolute-parent-connection-point rotated-add-to-offset))

    (define (absolute-points parent-connection absolute-parent-connection-point absolute-parent-angle)
      (define origin-point (get-field child-point parent-connection))
      (define total-angle (+ absolute-parent-angle (get-field angle parent-connection)))

      (define points-with-child-as-origin
        (map (lambda (point)
               (subtract-points point origin-point))
             (vector->list points)))

      (define rotated-points
        (map (lambda (point)
               (rotate-point point total-angle))
             points-with-child-as-origin))

      (map (lambda (point)
               (add-points point absolute-parent-connection-point))
             rotated-points))

    (define/public (aboslute-point->current-bone-point absolute-point parent-connection absolute-parent-connection-point absolute-parent-angle)
      (define origin-point (get-field child-point parent-connection))
      (define total-angle (+ absolute-parent-angle (get-field angle parent-connection)))

      (add-points
        (rotate-point
          (subtract-points absolute-point absolute-parent-connection-point)
          (- total-angle))
        origin-point))

(define/public (absolute-point->bone-point-without-parent absolute-point bone)
     (abolute-point->bone-point absolute-point bone (connection-zero) point-zero 0))

    (define/public (abolute-point->bone-point absolute-point bone parent-connection absolute-parent-connection-point absolute-parent-angle)
      (cond 
        [(equal? bone this) 
          (aboslute-point->current-bone-point absolute-point parent-connection absolute-parent-connection-point absolute-parent-angle)]
        [else 
          (define absolute-angle (+ absolute-parent-angle (get-field angle parent-connection)))
          (define origin-point (get-field child-point parent-connection))
          (define children-intersected
           (remove* (list null)
                   (map (lambda (child-connection)
                          (define child-offset (offset-for-connection child-connection origin-point absolute-parent-connection-point absolute-angle))
                          (send (get-field child-bone child-connection) abolute-point->bone-point absolute-point bone child-connection child-offset absolute-angle))
                        connections)))
          (if (empty? children-intersected)
             null
             (car children-intersected))]))
|#

;(set! connections (append connections (list connection)))
#|
(define thing%
  (class object%

    (init-field
     [parent #f]
     [child #f]
     [value #f])

    (super-new)
    ))


  (define parent 
    (new thing% 
        [parent #f] 
        [child #f]
        [value 1]))

(define child 
    (new thing%
        [parent parent]
        [child #f]
        [value 2]))

(set-field! child parent child)
(println (get-field value parent))
(set-field! value (get-field parent child) 5)
(println (get-field value parent))

(struct thing2 (parent child value)
  #:auto-value 0
  #:transparent
  #:mutable)

(define parent2 
    (thing2 #f #f 1))

(define child2
    (thing2 parent2 #f 2))

(set-thing2-child! parent2 child2)

(println (thing2-value parent2))
(set-thing2-value! (thing2-parent child2) 5)
(println (thing2-value parent2))
|#