#lang br
(require brag/support)

(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define-lex-abbrev identifier (:seq alphabetic (:* (:or alphabetic numeric))))

(define-lex-abbrev reserved-terms (:or "+" "-" "*" "/" "^" "mod" "(" ")" "=" ":" ".." "var" "point" "[" "]" ","))

(define anatomy-lexer
  (lexer-srcloc
   [(eof) (return-without-srcloc eof)]
   ["\n" (token 'NEWLINE lexeme)]
   [whitespace (token lexeme #:skip? #t)]
   [(from/stop-before "//" "\n") (token lexeme #:skip? #t)]
   [reserved-terms (token lexeme lexeme)]
   [identifier (token 'ID (string->symbol lexeme))]
   [digits (token 'INTEGER (string->number lexeme))]
   [(:or (:seq (:? digits) "." digits)
         (:seq digits "."))
    (token 'DECIMAL (string->number lexeme))]
   ;[(from/to "[" "]") (token 'POINT lexeme)]
   ))

(provide anatomy-lexer)