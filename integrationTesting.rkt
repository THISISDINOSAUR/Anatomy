#lang br

(require "integrationTestLayout.rkt")

;(set! scapulaLength 2)

;(write scapulaLength)
(display "\n")


(define newParams (make-hash))
(hash-set! newParams 'scapulaLength 10)
(set-parameters! Parameters newParams)
;(set-parameter! scapulaLength 2)
(display "\n")
(write scapulaLength)
(display "\n")

(a-print scapula)

(recalculate)
(display "\n")
(a-print scapula)

;(write a-test-program)
