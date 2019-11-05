#lang racket

(provide (all-defined-out))

(require "point.rkt"
         json
         racket/gui/base)

(define indent "  ")

(define bone%
  (class object%

    (init-field
     [points #f]
     [parent-connection #f]
     [connections (list)]
     [name ""]
     [highlighted? #f]
      [selected? #f])

    (define/public (add-connection! bone connection)
      (set! connections (append connections (list connection)))
      (set-field! parent-connection bone connection))

    (define/public (point-at-index index)
      (vector-ref points index))

    (define/public (operation-on-index! op point index)
      (vector-set! points index (op (vector-ref points index) point)))

    (define/public (operation-on-range! op point start end)
      (for ([i (in-range start (+ end 1))])
        (operation-on-index! op point i)
        ))

    (define/public (operation-on-dimension-of-index! op dimension val index)
      (vector-set! points index
                   (operation-on-point-dimension op dimension (vector-ref points index) val)))
    
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
      )

    (define (scale-connections! x y z)
      (for ([(connection) connections])
        (send connection scale-parent! x y z))
      )      

    (define (points->json)
      (vector->list (vector-map (lambda (point) (point->list point)) points)))

    (define (connections->json)
      (map (lambda (bone-connection)
             (send bone-connection json))
           connections))

    (define/public (json)
      (hasheq 'name name
              'points (points->json)
              'connections (connections->json)))
    
    (define/public (description)
      (string-append
       name ":\n"
       indent "points:\n"
       indent indent (string-join
                      (map describe-point (vector->list points)) ", ") "\n"
       indent "connections:\n"
       indent indent (string-join
                       (map (lambda (bone-connection)
                              (string-append
                               name
                               " ~ "
                               (get-field name (get-field child-bone bone-connection))
                               " = "
                               (send bone-connection description)))
                            connections)
                       (string-append "\n" indent indent))
       "\n"))

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
      (bounding-rect-for-points
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
            (draw-point-labels dc points-to-draw)
            (send dc set-brush (make-object color% 200 100 100 0.3) 'solid)]
        [highlighted?
            (draw-point-labels dc points-to-draw)
            (send dc set-brush (make-object color% 20 20 100 0.3) 'solid)]
        [else
          (send dc set-brush (make-object color% 255 246 222 0.3) 'solid)])
      (send dc set-pen (make-object color% 60 60 60 0.8) 8 'solid)
      (send dc draw-path (points->path points-to-draw))

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
      (send dc draw-text (describe-point-2d-rounded draw-point) (point-x text-draw-point) (point-y text-draw-point)))

    (define (draw-point-labels dc points)
      (define index 0)
      (for ([(point) points])
        (draw-point-label dc point index)
        (set! index (+ index 1))))
    
    (define (draw-point-label dc draw-point index)
      (send dc set-pen "white" 0 'transparent)
      (send dc set-brush (make-object color% 61 252 201 0.9) 'solid)
      (define draw-size 6)
      (define p (subtract-points draw-point (point (/ draw-size 2) (/ draw-size 2) 0)))
      (send dc draw-ellipse (point-x p) (point-y p) draw-size draw-size)

      (send dc set-font (make-font #:size 10 #:family 'modern #:weight 'bold))
      (send dc set-text-foreground (make-object color% 0 204 150))
      (send dc set-text-background "red")
      (define text-draw-point (add-points draw-point (point 0 (/ draw-size 2) 0)))
      (define text (string-append (~a index) ":" (describe-point-2d-rounded draw-point)))
      (send dc draw-text text (point-x text-draw-point) (point-y text-draw-point)))
    
    (super-new)
    ))

(define section%
  (class object%

    (init-field
     [bones #f]
     [name ""])

    (define/public (scale! x y z)
      (map (lambda (bone)
             (send bone scale! x y z))
           bones)
      (void))

    (define/public (description)
      (string-append
       name ": " (string-join
                      (map (lambda (bone)
                             (get-field name bone))
                           bones)
                      ", ")
       "\n"))

    (super-new)
    ))

(define connection%
  (class object%

    (init-field
     [parent-point #f]
     [child-point #f]
     [angle #f]
     [child-bone #f])

    (define/public (scale-parent! x y z)
      (set! parent-point (scale-point-dimension-wise parent-point x y z)))

    (define/public (scale-child! x y z)
      (set! child-point (scale-point-dimension-wise child-point x y z)))

    (define/public (json)
      (hasheq 'parent_point (point->list parent-point)
                     'child_point (point->list child-point)
                     'angle angle
                     'bone (send child-bone json)))

    (define/public (description)
        (string-append
         (describe-point parent-point) " ~ " (describe-point child-point) ", " (number->string angle) "°"))


    (super-new)
    ))

(define (connection-zero)
  (new connection%
       [parent-point point-zero]
       [child-point point-zero]
       [angle 0]))
      
(struct parameter (lower-bound upper-bound default)
  #:auto-value 0
  #:transparent
  #:mutable)

(define (is-valid-parameter-value? param value)
  (<= (parameter-lower-bound param) value (parameter-upper-bound param)))

(define (describe-parameter parameter1)
  (string-append (~a (parameter-lower-bound parameter1)) "  > < " (~a (parameter-upper-bound parameter1)) " = " (~a (parameter-default parameter1))))

(define (parameter->json parameter1)
  (hasheq 'lower-bound (parameter-lower-bound parameter1)
          'upper-bound (parameter-upper-bound parameter1)
          'default (parameter-default parameter1)))

(define parameters%
  (class object%

    (init-field
     [parameters #f]
     [setters #f]
     [ordering #f])

    (define/public (json)
      (map (lambda (param-name)
             (hasheq param-name (parameter->json (hash-ref parameters param-name))))
           ordering))

    (define/public (description)
      (string-join
       (map (lambda (param-name)
              (string-append (symbol->string param-name)
                             ": "
                             (describe-parameter (hash-ref parameters param-name))))
            ordering)
       "\n"))

    (super-new)))