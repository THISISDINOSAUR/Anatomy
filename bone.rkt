#lang racket

(provide (all-defined-out))

(require "structs/point.rkt"
         "structs/rect.rkt"
         "structs/polygon.rkt"
         "structs/polygon-tree.rkt"
         "string.rkt"
         "connection.rkt"
         racket/gui/base)

(define bone%
  (class object%

    (init-field
     [points #f]
     [parent-connection #f]
     [connections (list)]
     [name ""]
     [highlighted? #f]
     [selected? #f]
     [polygon-tree #f]
      )

    (super-new)

    (set! polygon-tree
      (points->root-polygon-tree (vector->list points)))
    
  ;(define (polygon-tree-add-child! parent child point-on-parent point-on-child angle)

#|(define connection%
  (class object%

    (init-field
     [parent-point #f]
     [child-point #f]
     [angle #f]
     [child-bone #f])|#

    (define/public (add-connection! bone connection)
      (set! connections (append connections (list connection)))
      (set-field! parent-connection bone connection)

      (polygon-tree-add-child! 
        polygon-tree 
        ;todo: the bone presumably has a polygon tree already we should use
        (points->root-polygon-tree (vector->list (get-field points bone)) )
        (get-field parent-point connection)
        (get-field child-point connection)
        (get-field angle connection))
      )

    (define/public (point-at-index index)
      (list-ref (polygon-tree-polygon polygon-tree) index))
      ;(vector-ref points index))

    (define/public (operation-on-index! op point index)
      (vector-set! points index (op (vector-ref points index) point))
      
      (set-polygon-tree-polygon! polygon-tree 
        (list-set 
          (polygon-tree-polygon polygon-tree)
          (op 
            (list-ref (polygon-tree-polygon polygon-tree) index)
            point)
          index))
      )

    (define/public (operation-on-range! op point start end)
      (for ([i (in-range start (+ end 1))])
        (operation-on-index! op point i)
        ))

    (define/public (operation-on-dimension-of-index! op dimension val index)
      (vector-set! points index
                   (operation-on-point-dimension op dimension (vector-ref points index) val))
                   
      (set-polygon-tree-polygon! polygon-tree 
        (list-set 
          (polygon-tree-polygon polygon-tree)
          (operation-on-point-dimension op dimension
            (list-ref (polygon-tree-polygon polygon-tree) index)
            val)
          index))
    )
    
    (define/public (operation-on-dimension-of-range! op dimension val start end)
      (for ([i (in-range start (+ end 1))])
        (operation-on-dimension-of-index! op dimension val i)
        ))

    (define/public (scale! x y z)
      (vector-map! (lambda (point)
           (scale-point-dimension-wise point x y z))
         points)
      (scale-connections! x y z)
      (send parent-connection scale-child! x y z) ;TODO: check what happens when no parent

      (scale-polygon-tree! polygon-tree x y z)
      )

    (define (scale-connections! x y z)
      (for ([(connection) connections])
        (send connection scale-parent! x y z))
      )      

    (define (offset-for-connection parent-connection origin-point absolute-parent-connection-point absolute-parent-angle)
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

    (define/public (bone-intersected-by-absolute-point-without-parent absolute-point)
      (bone-intersected-by-absolute-point absolute-point (connection-zero) point-zero 0))

    (define/public (bone-intersected-by-absolute-point absolute-point parent-connection absolute-parent-connection-point absolute-parent-angle)
      (define bone-points (absolute-points parent-connection absolute-parent-connection-point absolute-parent-angle))
      (cond
        [(point-intersects-polygon? absolute-point bone-points) this]
        [else
         (define absolute-angle (+ absolute-parent-angle (get-field angle parent-connection)))
         (define origin-point (get-field child-point parent-connection))
         (define children-intersected
           (remove* (list null)
                   (map (lambda (child-connection)
                          (define child-offset (offset-for-connection child-connection origin-point absolute-parent-connection-point absolute-angle))
                          (send (get-field child-bone child-connection) bone-intersected-by-absolute-point absolute-point child-connection child-offset absolute-angle))
                        connections)))
         (if (empty? children-intersected)
             null
             (car children-intersected))]))


    (define (absolute-bounding-rect parent-connection absolute-parent-connection-point absolute-parent-angle)
      (points->bounding-rect
       (absolute-points parent-connection absolute-parent-connection-point absolute-parent-angle)))

    (define/public (tree-bounding-rect-without-parent)
      (tree-bounding-rect (connection-zero) point-zero 0))
    
    (define/public (tree-bounding-rect parent-connection absolute-parent-connection-point absolute-parent-angle)      
      (define offset-bounding-rect (absolute-bounding-rect parent-connection absolute-parent-connection-point absolute-parent-angle))

      (define total-angle (+ absolute-parent-angle (get-field angle parent-connection)))
      (define origin-point (get-field child-point parent-connection))
      (cond
        [(null? connections) offset-bounding-rect]
        [else
          (define child-rects
            (map (lambda (child-connection)
                   (define child-offset (offset-for-connection child-connection origin-point absolute-parent-connection-point total-angle))

                   (send (get-field child-bone child-connection) tree-bounding-rect child-connection child-offset total-angle))
                 connections))
      
          (bounding-rect-containing-bounding-rects offset-bounding-rect
                                                   (bounding-rect-containing-bounding-rects-list child-rects))
          ])
      )

    (define/public (set-tree-highlighted flag)
      (set! highlighted? flag)
      (for ([(child-connection) connections])
        (send (get-field child-bone child-connection) set-tree-highlighted flag)))

    (define/public (set-tree-selected flag)
      (set! selected? flag)
      (for ([(child-connection) connections])
        (send (get-field child-bone child-connection) set-tree-selected flag)))

    (define/public (render-without-parent dc)
      (render dc (connection-zero) point-zero 0))

    (define/public (render dc parent-connection absolute-parent-connection-point absolute-parent-angle)

      (define points-to-draw (absolute-points parent-connection absolute-parent-connection-point absolute-parent-angle))
      (cond 
        [selected?
            (send dc set-brush (make-object color% 200 100 100 0.3) 'solid)]
        [highlighted?
            (send dc set-brush (make-object color% 20 20 100 0.3) 'solid)]
        [else
          (send dc set-brush (make-object color% 255 246 222 0.3) 'solid)])
      (send dc set-pen (make-object color% 60 60 60 0.8) 8 'solid)
      (send dc draw-path (points->path points-to-draw))

      (cond 
        [selected?
            (draw-point-labels dc (vector->list points) points-to-draw)]
        [highlighted?
            (draw-point-labels dc (vector->list points) points-to-draw)]
        [else
          null])

      (define absolute-angle (+ absolute-parent-angle (get-field angle parent-connection)))
      (define origin-point (get-field child-point parent-connection))
      (for ([(child-connection) connections])
        ;distance between current bones parent connection and the connection point for the new bone
        (define child-offset (offset-for-connection child-connection origin-point absolute-parent-connection-point absolute-angle))

        (draw-connection-point dc child-offset)
        (send (get-field child-bone child-connection) render dc child-connection child-offset absolute-angle)
      ))
    
    (define (draw-connection-point dc connection-point)
      (send dc set-pen (make-object color% 200 50 50 0.9) 6 'solid)
      (send dc set-brush "white" 'transparent)
      (define draw-size 20)
      (define draw-point (subtract-points connection-point (point (/ draw-size 2) (/ draw-size 2) 0)))
      (send dc draw-ellipse (point-x draw-point) (point-y draw-point) draw-size draw-size)

      ;TODO: only render connection points when highlighted (but also render parent connection point)
      (send dc set-font (make-font #:size 15 #:family 'modern))
      (send dc set-text-foreground "red")
      (define text-draw-point (add-points connection-point (point 0 (/ draw-size 2) 0)))
      (send dc draw-text (point->description-string-2d-rounded draw-point) (point-x text-draw-point) (point-y text-draw-point)))

    (define (draw-point-labels dc bone-points draw-points)
      (define index 0)
      (map (lambda (bone-point draw-point)
             (draw-point-label dc bone-point draw-point index)
        (set! index (+ index 1)))
           bone-points draw-points))
    
    (define (draw-point-label dc bone-point draw-point index)
      (send dc set-pen "white" 0 'transparent)
      (send dc set-brush (make-object color% 61 252 201 0.9) 'solid)
      (define draw-size 6)
      (define p (subtract-points draw-point (point (/ draw-size 2) (/ draw-size 2) 0)))
      (send dc draw-ellipse (point-x p) (point-y p) draw-size draw-size)

      (send dc set-font (make-font #:size 10 #:family 'modern #:weight 'bold))
      (send dc set-text-foreground (make-object color% 0 204 150))
      (send dc set-text-background "red")
      (define text-draw-point (add-points draw-point (point 0 (/ draw-size 2) 0)))
      (define text (string-append (~a index) ":" (point->description-string-2d-rounded bone-point)))
      (send dc draw-text text (point-x text-draw-point) (point-y text-draw-point)))
    
    ))
      