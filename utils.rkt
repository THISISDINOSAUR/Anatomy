#lang br

(provide append-symbols)

(define (append-symbols symbol1 symbol2)
  (string->symbol (string-append (symbol->string symbol1) (symbol->string symbol2))))
