#lang br

(require "integrationTestLayout.rkt")

(define newParams (make-hash))
(hash-set! newParams 'scapulaLength 10)
(set-parameters! Parameters newParams)


(recalculate)
(display "\n")
(write Parameters)
