#lang racket

;TODO: should unit test this file (specifically the operations)

(provide (all-defined-out))

(require "structs/point.rkt"
         "structs/rect.rkt"
         "structs/polygon.rkt"
         "structs/polygon-tree.rkt"
         "string.rkt"
         racket/gui/base)

(define bone%
  (class object%

    (init points)

    (init-field
     [connections '()] ;connections are only required for when the name of child bones is required (e.g. printing bones, converting to JSON). It is a list of child bones. TODO: we should rename to be more descriptive
     [name ""]
     [polygon-tree #f])

    (super-new)

    (set! polygon-tree
      (points->root-polygon-tree (vector->list points)))
    
    (define/public (add-connection! bone
                                    point-on-parent
                                    point-on-child
                                    angle)
      (set! connections (append connections (list bone)))

      (polygon-tree-add-child! 
        polygon-tree 
        (get-field polygon-tree bone)
        point-on-parent
        point-on-child
        angle))

    (define/public (point-at-index index)
      (list-ref (polygon-tree-polygon polygon-tree) index))

    (define/public (operation-on-index! op point index)
      (set-polygon-tree-polygon! polygon-tree 
        (list-set 
          (polygon-tree-polygon polygon-tree)
          index
          (op 
            (list-ref (polygon-tree-polygon polygon-tree) index)
            point))))

    (define/public (operation-on-range! op point start end)
      (for ([i (in-range start (+ end 1))])
        (operation-on-index! op point i)))

    (define/public (operation-on-dimension-of-index! op dimension val index)                   
      (set-polygon-tree-polygon! polygon-tree 
        (list-set 
          (polygon-tree-polygon polygon-tree)
          index
          (operation-on-point-dimension op dimension
            (list-ref (polygon-tree-polygon polygon-tree) index)
            val))))
    
    (define/public (operation-on-dimension-of-range! op dimension val start end)
      (for ([i (in-range start (+ end 1))])
        (operation-on-dimension-of-index! op dimension val i)
        ))

    (define/public (scale! x y z)
      (scale-root-only-of-polygon-tree! polygon-tree x y z)) 
    ))
      