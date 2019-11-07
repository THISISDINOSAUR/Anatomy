#lang racket

(provide (all-defined-out))

(require 
"parameter.rkt"
"structs/point.rkt")

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

;TODO refactor linebreaks out of this

(define (bone->description-string bone)
      (string-append
       (get-field name bone) ":\n"
       indent "points:\n"
       indent indent (string-join
                      (map point->description-string (vector->list (get-field points bone))) ", ") "\n"
       indent "connections:\n"
       indent indent (string-join
                       (map (lambda (bone-connection)
                              (string-append
                               (get-field name bone)
                               " ~ "
                               (get-field name (get-field child-bone bone-connection))
                               " = "
                               (connection->description-string bone-connection)))
                            (get-field connections bone))
                       (string-append "\n" indent indent))
       "\n"))

(define (connection->description-string connection)
        (string-append
         (point->description-string (get-field parent-point connection)) " ~ " (point->description-string (get-field child-point connection)) ", " (number->string (get-field angle connection)) "°"))

(define (section->description-string section)
      (string-append
       (get-field name section) ": " (string-join
                      (map (lambda (bone)
                             (get-field name bone))
                           (get-field bones section))
                      ", ")
       "\n"))