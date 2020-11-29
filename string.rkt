#lang racket

(provide (all-defined-out))

(require 
"parameter.rkt"
"structs/point.rkt"
"structs/polygon-tree.rkt")

(define indent "  ")

(define (point->description-string point1)
  (string-append "[" (~a (point-x point1)) ", " (~a (point-y point1)) ", " (~a (point-z point1)) "]"))

(define (point->description-string-2d-rounded point1)
  (define p (round-point point1))
  (string-append "[" (~a (point-x p)) ", " (~a (point-y p)) "]"))

(define (parameter->description-string parameter1)
  (string-append (~a (parameter-lower-bound parameter1)) "  > < " (~a (parameter-upper-bound parameter1)) " = " (~a (parameter-default parameter1))))

(define (parameters->description-string parameters)
      (string-join
       (map (lambda (param-name)
              (string-append (symbol->string param-name)
                             ": "
                             (parameter->description-string (hash-ref (get-field parameters parameters) param-name))))
            (get-field ordering parameters))
       "\n"))

(define (bone->description-string bone)
      (string-append
       (get-field name bone) ":\n"
       indent "points:\n"
       indent indent (string-join
                      (map point->description-string (polygon-tree-polygon (get-field poly-tree bone))) ", ") "\n"
       indent "connections:\n"
       indent indent (string-join
                       (map (lambda (child)
                              (string-append
                               (get-field name bone)
                               " ~ "
                               (get-field name child)
                               " = "
                               (polygon-tree->connection-description-string (get-field poly-tree child))))
                            (get-field connections bone))
                       (string-append "\n" indent indent))
       ))

(define (polygon-tree->connection-description-string tree)
  (connection-description
   (point->description-string (polygon-tree-connection-point-on-parent tree))
   (point->description-string (polygon-tree-connection-point tree))
   (polygon-tree-angle tree)
   (polygon-tree-parent tree)))

(define (polygon-tree->connection-description-string-2d-rounded tree)
  (define parent (polygon-tree-connection-point-on-parent tree))
  (connection-description
   (if (equal? parent #f)
       parent
       (point->description-string-2d-rounded parent))
   (point->description-string-2d-rounded (polygon-tree-connection-point tree))
   (exact-round (polygon-tree-angle tree))
   (polygon-tree-parent tree)))

(define (connection-description point-on-parent connection-point angle parent)
  (string-append
   (if (equal? parent #f)
       ""
       (string-append
        point-on-parent
        " ~ "))
   connection-point
   ", "
   (~a angle)))

(define (section->description-string section)
  (string-append
   (get-field name section)
   ": "
   (string-join
    (map (lambda (bone)
           (get-field name bone))
         (get-field bones section))
    ", ")))