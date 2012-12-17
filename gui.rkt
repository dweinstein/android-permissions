#lang racket/gui

(require "permissions.rkt")

(require framework/gui-utils)

;(require sgl sgl/gl-vectors)

;(application:current-app-name "Analyzer")
; Make a frame by instantiating the frame% class

(define frame (new frame% [label "Analyzer"] [width 300] [height 300]))
 
; Make a static text message in the frame
(define msg (new message% [parent frame]
                          [label "No events so far..."]))


; Make a button in the frame
(new button% [parent frame]
             [label "Click Me"]
             ; Callback procedure for a button click:
             [callback (lambda (button event)
                         (send msg set-label "Button click"))])

(new button% [parent frame]
             [label "Pause"]
             [callback (lambda (button event) (sleep 5))])

(new combo-field%
     [parent frame]
     [label "platforms"]
     [init-value "froyo"]
     [choices (get-platform-strings)]
     [callback (lambda (c e)
                 (let ([v (send c get-value)])
                   (printf "user selected ~a~n" v)
                   (current-platform (string->symbol v))
                   (send permission-list set (get-permission-strings))))])



(define (shorten-list-of-strings l)
  (if (not (empty? l))
      (map (curryr gui-utils:trim-string 200)
           l)
      empty))


(define filter-perm
  (new text-field%
       [parent frame]
       [label "filter permissions:"]
       [callback (lambda (t e)
                   (let ([v (send t get-value)])
                     (send permission-list
                           set
                           (filter (curry regexp-match v)
                                   (get-permission-strings)))
                     
                     (send msg
                           set-label
                           v)))]))

(define permission-list (new list-box%
                             [parent frame]
                             [choices (get-permission-strings)]
                             [label "permissions:"]
                             ;; [style '(multiple)]
                             [callback (lambda (c e)
                                         (printf "user selected ~a~n" (send c get-string-selection))
                                         ;; (send c set-first-visible-item (send c get-selection))
                                         (send (send filter-perm get-editor) erase)
                                         (send methods-list set
                                               (shorten-list-of-strings
                                                    (lookup/perm->apis
                                                     (send c get-string-selection)))
                                                    ))]))

(define filter-method
  (new text-field%
     [parent frame]
     [label "filter methods:"]
     [callback (lambda (t e)
                 (let ([v (send t get-value)])
                   (send methods-list set (shorten-list-of-strings (lookup-api/re v)))
                   (send msg set-label v)))]))

(define methods-list
  (new list-box%
       [parent frame]
       [choices (shorten-list-of-strings (lookup-api/re ""))]
       [label "methods:   "]
       [callback (lambda (c e)
                   (let* ([v (send c get-string-selection)]
                          [maybe-perms (lookup/api->perm v)])
                     (printf "user selected ~a~n" v)
                     (send (send filter-method get-editor) erase)
                     (when maybe-perms
                       (for-each (lambda (p)
                                   (send permission-list
                                         set-string-selection
                                         p))
                                 maybe-perms))
                     ))]
       ))

; Show the frame by calling its show method
(send frame show #t) 
; Derive a new canvas (a drawing window) class to handle events
(define my-canvas%
  (class canvas% ; The base clnass is canvas%
    ; Define overriding method to handle mouse events
    (define/override (on-event event)
      (send msg set-label "Canvas mouse"))
    ; Define overriding method to handle keyboard events
    (define/override (on-char event)
      (send msg set-label "Canvas keyboard"))
    ; Call the superclass init, passing on all init args
    (super-new)))

(define (draw-circle-at-x-y dc x-y width height)
  (let ([x (first x-y)]
        [y (second x-y)])
    (send dc draw-ellipse x y width height)))

(define (draw-circle-at-x-y-with-text dc x-y text)
  (let ([x (first x-y)]
        [y (second x-y)])
    (send dc draw-ellipse x y 27 27)
    (send dc draw-text text (+ x 4) (+ y 4))))


(define (gen-random-pos count x y)
  (for/fold ([accum null]) ([indx (build-list count values)])
      (values (cons `(,(random (add1 x)) ,(random (add1 y))) accum))))

(define positions
  (gen-random-pos 30 500 500))

; Make a canvas that handles events in the frame
(define canvas (new my-canvas%
     [parent frame]
     [style '(vscroll hscroll border)] ;; gl no-autoclear
     [paint-callback
      (lambda (canvas dc)
        (send dc set-scale 1 1)
        ;(send dc draw-rectangle 0 0 10 10)
        ;(send dc draw-rectangle 10 0 10 10)
        ;(map (curryr (curry draw-circle-at-x-y dc) (random 10) (random 10)) positions)
        (draw-circle-at-x-y-with-text dc '(10 10) "test")
        ;(send dc draw-ellipse 10 10 20 20)
        ;; (send canvas with-gl-context
        ;;       (lambda ()
        ;;         (gl-begin 'triangles)
        ;;         (gl-vertex 1 2 3)
        ;;         (gl-vertex-v (gl-float-vector 1 2 3 4))
        ;;         (gl-end)))
        ;(send canvas set-canvas-background (make-object color% "light blue"))
        ;(send dc set-text-foreground "blue")
        ;; (send dc draw-text "Don't Panic!" 0 0)
        )]))




(define panel (new horizontal-panel% [parent frame]))
(new button% [parent panel]
             [label "Left"]
             [callback (lambda (button event)
                         (send msg set-label "Left click"))])
(new button% [parent panel]
             [label "Right"]
             [callback (lambda (button event)
                         (send msg set-label "Right click"))])
