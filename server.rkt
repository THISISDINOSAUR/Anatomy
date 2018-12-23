#lang racket

(require racket/list
	 web-server/http
         web-server/servlet-env
         web-server/dispatch
         web-server/http/bindings
	 json)

(require "integrationTestLayout.rkt") 

(define (response
	 #:code    [code/kw 200]
	 #:message [message/kw "OK"]
	 #:seconds [seconds/kw (current-seconds)]
	 #:mime    [mime/kw #f]
	 #:headers [headers/kw empty]
	 #:body    [body/kw empty])
  (define mime
    (cond ((string? mime/kw)
	   (string->bytes/utf-8 mime/kw))
          ((bytes? mime/kw)
           mime/kw)
	  (else
	   #f)))
  (define message
    (cond ((bytes? message/kw)
	   message/kw)
	  ((string? message/kw)
	   (string->bytes/utf-8 message/kw))
          (else
           #f)))
  (define body
    (cond ((string? body/kw)
	   (list (string->bytes/utf-8 body/kw)))
	  ((bytes? body/kw)
	   (list body/kw))
	  ((list? body/kw)
           body/kw)
	  (#t
	   body/kw)))
  (response/full
   code/kw
   message
   seconds/kw
   mime
   headers/kw
   body))

(define (raw-request-bindings->parameter-hash bindings)
  (define newParams (make-hash))
  (for ([param bindings])
    (hash-set! newParams
               (string->symbol (bytes->string/utf-8 (binding-id param)))
               (string->number (bytes->string/utf-8 (binding:form-value param)))))
  newParams)
  
;TODO check params actually exist and handle appropriately
;TODO check allowed range of params
(define (get-dinosaur req)
  (define newParams (raw-request-bindings->parameter-hash (request-bindings/raw req)))
  (reset-parameters! Parameters)
  (set-parameters! Parameters newParams)
  (recalculate)
  (response #:body (jsexpr->bytes (send scapula json))
            #:mime "application/json"))

(define (get-parameters req)
  (response #:body (jsexpr->bytes (send Parameters json))
            #:mime "application/json"))

(define (not-found req)
  (response #:code 404
	    #:message "Not Found"))

(define (bad-request)
  (response #:code 400
            #:message "Bad Request"))

(define (internal-server-error)
  (response #:code 500
            #:message "Internal Server Error"))

(define-values (go _)
  (dispatch-rules
   [("dinosaur") #:method "get" get-dinosaur]
   [("parameters") #:method "get" get-parameters] ;TODO: how to do dinosaur/parameters?
   [else not-found]))

(module+ main
  (serve/servlet
   go
   #:port 6892
   #:command-line? #t
   #:servlet-regexp #rx""))