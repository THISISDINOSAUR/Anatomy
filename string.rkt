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
  (string-append "[" (~a (exact-round (point-x point1))) "," (~a (exact-round (point-y point1))) "]"))

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
                      (map point->description-string (polygon-tree-polygon (get-field polygon-tree bone))) ", ") "\n"
       indent "connections:\n"
       indent indent (string-join
                       (map (lambda (bone-connection)
                              (string-append
                               (get-field name bone)
                               " ~ "
                               (get-field name (get-field child-bone bone-connection))
                               " = "
                               (polygon-tree->connection-description-string (get-field polygon-tree (get-field child-bone bone-connection)))))
                            (get-field connections bone))
                       (string-append "\n" indent indent))
       ))

(define (polygon-tree->connection-description-string tree)
  (string-append
   (point->description-string (polygon-tree-connection-point-on-parent tree))
   " ~ "
   (point->description-string (polygon-tree-connection-point tree))
   ", "
   (number->string (polygon-tree-angle tree))
   "°"))

(define (section->description-string section)
  (string-append
   (get-field name section)
   ": "
   (string-join
    (map (lambda (bone)
           (get-field name bone))
         (get-field bones section))
    ", ")))