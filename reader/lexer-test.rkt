#lang br
(require "lexer.rkt" brag/support rackunit)

(define (lex str)
  (apply-lexer anatomy-lexer str))

(check-equal? (lex "") empty)
(check-equal?
 (lex " ")
 (list (srcloc-token (token " " #:skip? #t)
                     (srcloc 'string #f #f 1 1))))
(check-equal?
 (lex "//comment ignored\n")
 (list (srcloc-token (token '|//comment ignored| #:skip? #t)
                     (srcloc 'string #f #f 1 17))
       (srcloc-token (token 'NEWLINE "\n")
                     (srcloc 'string #f #f 18 1))))
(check-equal?
 (lex "12")
 (list (srcloc-token (token 'INTEGER 12)
                     (srcloc 'string #f #f 1 2))))
(check-equal?
 (lex "1.2")
 (list (srcloc-token (token 'DECIMAL 1.2)
                     (srcloc 'string #f #f 1 3))))
(check-equal?
 (lex "12.")
 (list (srcloc-token (token 'DECIMAL 12.)
                     (srcloc 'string #f #f 1 3))))
(check-equal?
 (lex ".12")
 (list (srcloc-token (token 'DECIMAL .12)
                     (srcloc 'string #f #f 1 3))))
(check-equal?
 (lex "\"foo\"")
 (list (srcloc-token (token 'STRING "foo")
                     (srcloc 'string #f #f 1 5))))
(check-equal?
 (lex "'foo'")
 (list (srcloc-token (token 'STRING "foo")
                     (srcloc 'string #f #f 1 5))))