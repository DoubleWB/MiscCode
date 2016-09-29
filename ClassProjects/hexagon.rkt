;Theory Credits to Jimmy Chen
;Library Research Credits to Andy Mei
;Code Credits to Will Becker



#lang racket

(require graphics/graphics)
(require htdp/draw)
(require srfi/42)

;;Creating Graphics
(open-graphics)

;;Make Lists for the heaxagon points, and the various tesselation categories
(define hexagon (list (make-posn 0 0)
                      (make-posn (* -5 4 (sqrt 3)) 20)
                      (make-posn (* -5 4 (sqrt 3)) 60)
                      (make-posn 0 80)
                      (make-posn (* 5 4 (sqrt 3)) 60)
                      (make-posn (* 5 4 (sqrt 3)) 20)))

(define pos-list (list (list (make-posn (* 5 4 (sqrt 3)) -60) .2 .2 0)
                       (list (make-posn (* 10 4 (sqrt 3)) 0) 0 .2 0)
                       (list (make-posn (* 5 4 (sqrt 3)) 60) 0 .2 .2)
                       (list (make-posn (* -5 4 (sqrt 3)) 60) 0 0 .2)
                       (list (make-posn (* -10 4 (sqrt 3)) 0) .2 0 .2)
                       (list (make-posn (* -5 4 (sqrt 3)) -60) .2 0 0)))

;;Aside from the center hexagon, all hexagons fit into one of these categories,
;;as described in the diagram. They are identifiable as d meaning decrease, and
;;s meaning same, with the three letters corresponding to r, g, and b.
(define dds (list (list (make-posn (* 5 4 (sqrt 3)) -60) .2 .2 0)
                  (list (make-posn (* -5 4 (sqrt 3)) -60) .2 0 0)
                  (list (make-posn (* 10 4 (sqrt 3)) 0) 0 .2 0)))

(define sds (list (list (make-posn (* 10 4 (sqrt 3)) 0) 0 .2 0)))

(define sdd (list (list (make-posn (* 10 4 (sqrt 3)) 0) 0 .2 0)
                  (list (make-posn (* 5 4 (sqrt 3)) 60) 0 .2 .2)
                  (list (make-posn (* -5 4 (sqrt 3)) 60) 0 0 .2)))

(define ssd (list (list (make-posn (* -5 4 (sqrt 3)) 60) 0 0 .2)))

(define dsd (list (list (make-posn (* -5 4 (sqrt 3)) 60) 0 0 .2)
                  (list (make-posn (* -10 4 (sqrt 3)) 0) .2 0 .2)
                  (list (make-posn (* -5 4 (sqrt 3)) -60) .2 0 0)))

(define dss (list (list (make-posn (* -5 4 (sqrt 3)) -60) .2 0 0)))


;;Create the viewport as well as the frames for the 6 hexagons
(define v (open-viewport "Hexagons" 900 900))
(define w (open-viewport "Color" 300 300))

(define one (open-pixmap "Hexagons" 900 900))
(define two (open-pixmap "Hexagons" 900 900))
(define three (open-pixmap "Hexagons" 900 900))
(define four (open-pixmap "Hexagons" 900 900))
(define five (open-pixmap "Hexagons" 900 900))
(define six (open-pixmap "Hexagons" 900 900))

;;Load the frames for each of the hexagons
(define (load)
  (begin
    (begin-draw 1 one)
    (begin-draw 2 two)
    (begin-draw 3 three)
    (begin-draw 4 four)
    (begin-draw 5 five)
    (begin-draw 6 six)
    )
  )

;;Draw the first hexagon, according to which in the series is desired
(define (begin-draw hexagon-num view)
  (begin
    (define start-color (* .2 (- hexagon-num 1)))
    ((draw-solid-polygon view) hexagon (make-posn 450 450) [make-rgb start-color start-color start-color])
    (if (= hexagon-num 1)
        0
        (for/list ([i pos-list]) 
          (let([ x (+ 450 (posn-x (list-ref i 0)))]
               [ y (+ 450 (posn-y (list-ref i 0)))]
               [ r (list-ref i 1)]
               [ g (list-ref i 2)]
               [ b (list-ref i 3)])
            ;;Start each branch of the 6 categories of hexagons
            (hex_rec (list (- start-color r) (- start-color g) (- start-color b)) (list x y) start-color view)
            )
          )
        )
    )
  )

(define (hex_rec color pos start view)
  (begin
    
    ;;To eliminate rounding error causing colors to sometimes be less than zero
    (define red (if (< (list-ref color 0) 0)
                    0
                    (list-ref color 0)))
    (define green (if (< (list-ref color 1) 0)
                      0
                      (list-ref color 1)))
    (define blue (if (< (list-ref color 2) 0)
                     0
                     (list-ref color 2)))
    
    ;;Paints this hexagon
    ((draw-solid-polygon view) hexagon (make-posn (list-ref pos 0) (list-ref pos 1)) [make-rgb red green blue])
    (define rec-list null)
    
    ;;If any of the values are zero, we have hit an edge, and need to stop. Used .1, again, to account for rounding issues causing non zeros
    (if (or (<= red .1) (<= green .1) (<=  blue .1))
        0
        (let()
          
          ;;Determine which category this hexagon belongs to, and set it specific directions to proceed in, as not to overpaint incorrectly
          (cond ((= blue start) (set! rec-list dds))
                ((and (= blue start) (= red start)) (set! rec-list sds))
                ((= red start) (set! rec-list sdd))
                ((and (= red start) (= green start)) (set! rec-list ssd))
                ((= green start) (set! rec-list dsd))
                ((and (= green start) (= blue start)) (set! rec-list dss)))
          
          ;;Calculate the color and position of the next hexagon according to the list currently chosen
          (for/list ([i rec-list])
            (let([ x (+ (list-ref pos 0) (posn-x (list-ref i 0)))]
                 [ y (+ (list-ref pos 1) (posn-y (list-ref i 0)))]
                 [ r (list-ref i 1)]
                 [ g (list-ref i 2)]
                 [ b (list-ref i 3)])
              (hex_rec (list (- red r) (- green g) (- blue b)) (list x y) start view)
              )
            )
          )
        )
    )
  )

;;Set starting frame as zero
(define frame 0)

;;Move frames according to mouse click
(define (mouse-callback x)
  (begin
    (define m (ready-mouse-click v))
    (define p (query-mouse-posn v))
    (define c ((get-color-pixel v) p))
    
    ;;Handle Color Window
    (if(equal? c #f)
       ((clear-viewport w))
       (let()
         ((draw-viewport w) c)
         (define nc [make-rgb (- 1 (rgb-red c)) (- 1 (rgb-green c)) (- 1 (rgb-blue c))])
         ((draw-string w) (make-posn 50 50) (string-append "R: " (~a (round (* 255 (rgb-red c))))) nc)
         ((draw-string w) (make-posn 50 100) (string-append "G: " (~a (round (* 255 (rgb-green c))))) nc)
         ((draw-string w) (make-posn 50 150) (string-append "B: " (~a (round (* 255 (rgb-blue c))))) nc)
         )
       )
    
    ;;Handle Moving of Frames and secrets
    (if (not m)
        0
        (let()
          (if (right-mouse-click? m)
              (if (= frame 5)
                  (set! frame 0)
                  (set! frame (+ frame 1))
                  )
              0
              )
          (if (left-mouse-click? m)
              (if (= frame 0)
                  (set! frame 5)
                  (set! frame (- frame 1))
                  )
              0
              )
          (if (middle-mouse-click? m)
              (Go!)
              0
              )
          (copy-viewport (list-ref frames frame) v)
          )
        )
    
    )
  )

;;Start up the program

(load)
(define frames (list one two three four five six))
((set-on-tick-event v) 1 mouse-callback)
(copy-viewport one v)
(display "Right-click to move forward, left-click to go back!\n")

































;; Secret >:3
(define (Go!)
  (begin
    ((stop-tick v))
    (ravegons .01 500)
    )
  )

(define (ravegons delay num)
  (begin
    (for ([i num])
      (display "RAVE!!!!!!!\n")
      (copy-viewport one v)
      (sleep-for-a-while delay)
      (copy-viewport two v)
      (sleep-for-a-while delay)
      (copy-viewport three v)
      (sleep-for-a-while delay)
      (copy-viewport four v)
      (sleep-for-a-while delay)
      (copy-viewport five v)
      (sleep-for-a-while delay)
      (copy-viewport six v)
      (display "RAVE!!!!!!!\n")
      (sleep-for-a-while delay)
      (copy-viewport five v)
      (sleep-for-a-while delay)
      (copy-viewport four v)
      (sleep-for-a-while delay)
      (copy-viewport three v)
      (sleep-for-a-while delay)
      (copy-viewport two v)
      (sleep-for-a-while delay)
      )
    (clear-viewport v)
    )
  )