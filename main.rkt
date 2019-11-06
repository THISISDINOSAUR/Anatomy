#lang br/quicklang
(require "reader/parser.rkt" "reader/tokenizer.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module basic-mod anatomy/expander/expander
       #,parse-tree)))

(module+ reader
  (provide read-syntax))
