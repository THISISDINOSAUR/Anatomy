#lang racket

(provide (all-defined-out))

(define DEFAULT-MODE 'default)
(define NAME-BONE-MODE 'name-bone)
(define DRAW-MODE 'draw)

(define DEFAULT-MODE-LABEL "Select mode")
(define NAME-BONE-MODE-LABEL "Name new bone: ")
(define DRAW-MODE-LABEL "Draw mode")

;todo, maybe selected bones should be part of default mode state (and thus shouldnt be selected in other modes anymore)

(struct name-bone-mode-state (name
                              draw-origin
                              draw-origin-in-parent-bone
                              parent-polygon)
  #:auto-value #f
  #:transparent
  #:mutable)

(struct draw-mode-state (just-entered?
                         use-initial-mouse-as-origin?
                         drawn-points
                         drawn-points-relative-to-initial-mouse
                         draw-origin
                         draw-origin-in-parent-bone
                         name
                         parent-polygon)
  #:auto-value #f
  #:transparent
  #:mutable)
