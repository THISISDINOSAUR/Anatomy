#lang info
(define collection "anatomy")
(define version "1.0")
(define test-omit-paths '("lexer-test.rkt" "parse-test.rkt"))
(define deps '("base"
               "beautiful-racket-lib"
               "br-parser-tools-lib"
               "brag"
               "draw-lib"
               "gui-lib"
               "rackunit-lib"
               "syntax-color-lib"
               "web-server"
               "json"
               "list"))
(define build-deps '("racket-doc"))
