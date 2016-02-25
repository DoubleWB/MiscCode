;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname |Centipede Final Draft With Tests|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require 2htdp/image)
(require 2htdp/universe)


;; CONSTANTS - things that don't change

(define GRID-WIDTH 25)
(define GRID-HEIGHT 40)
(define CELL-SIZE 15)
(define BG (empty-scene (* CELL-SIZE GRID-WIDTH) (* CELL-SIZE GRID-HEIGHT)))

(define PLAYER (square CELL-SIZE 'solid 'black))
(define BULLET (rectangle 3 8 'solid 'orange))
(define CENTIPEDE-CELL (square CELL-SIZE 'solid 'green))
(define TONGUE (triangle 5 'solid 'red))
(define LEFT-HEAD (overlay/align "left" "middle" (rotate 90 TONGUE) CENTIPEDE-CELL))
(define RIGHT-HEAD (overlay/align "right" "middle" (rotate 30 TONGUE) CENTIPEDE-CELL))

(define MUSHROOM-RADIUS (/ CELL-SIZE 2))
(define MUSHROOM-0-C 'LightSalmon)
(define MUSHROOM-1-C 'Salmon)
(define MUSHROOM-2-C 'OrangeRed)
(define MUSHROOM-3-C 'DarkRed)

(define WINNER (text "WINNER" 72 'black))
(define LOSER (text "LOSER" 72 'black))

(define CENT-SPEED 5)
(define SHOT-SPEED 3)
(define BULL-SPEED 1)

;; DATA - things that change

;; A Segment is a (make-posn Number Number)
;; where the first number is less than GRID-WIDTH
;; and the second is less than GRID-HEIGHT

;; A Body is one of
;; empty
;; [Listof Segments]

;;Template:
#;(define (body-temp b)
    (cond [(empty? b) ...]
          [(cons? b) ... (first b) ... (body-temp (rest b)) ... ]))

;; A Direction is one of
;; 'r
;; 'l
;; 'u
;; 'd
;; and represents a cardinal direction

;; A Centipede is a (make-centipede Direction Body Boolean)
(define-struct centipede (dir body down?))
;; A (make-centipede dir body) is interpreted as a centipede with all of the segments in body, traveling in direction dir
;; And generally traveling down if down? is true
;; The head of the centipede is the first element of the Body

;;Template:
#;(define (cent-temp c)
    (... (centipede-dir c) ... (centipede-body c)...))

;; A Swarm is one of
;; empty
;; [Listof Centipede]

;;Template
#;(define (swarm-temp s)
    (cond [(empty? s) ...]
          [(cons? s) ... (first s) ... (swarm-temp (rest s)) ... ]))

;;A ShooterSymbol is one of
;; 'right
;; 'left
;; 'waiting


;; A Shooter is a (make-shooter (make-posn Number Number) ShooterSymbol)
;; where the first is a positive number less than GRID-WIDTH
;; and the second is 0
(define-struct shooter (posn symbol))

;; A Bullet is a (make-bullet (make-posn Number Number) Boolean)
;; where the first number is a positive number less than GRID-WIDTH
;; and the second number is a positive number less than GRID-HEIGHT
;; and the Boolean determines whether the bullet is firing or not
(define-struct bullet (posn firing?))

;; A Mushroom is a (make-mushroom Posn Number)
(define-struct mushroom (posn health))
;; A (make-mushroom (posn health)) is interpreted as a mushroom at the position pos with health health, which is a number from 0 - 3 inclusive

;; Template:
#;(define (mush-temp m)
    ( ... (mushroom-posn m) ... (mushroom-health m) ...))

;; A Mushroom-Field is one of
;; empty
;; [Listof Mushroom]

;;Template
#;(define (mush-field-temp m)
    (cond [(empty? m) ...]
          [(cons? m) ... (first m) ... (mush-field-temp (rest m))]))

;; A World is a (make-world Mushroom-Field Swarm Shooter Bullet)
(define-struct world (mushroom-field swarm shooter bullet tick))
;; A (make-world (mushroom-field swarm shooter bullet) is interpreted as a world with mushroom-field mushrooms, swarm centipedes,
;; the shooter, and the bullet, on the tick given by tick

;; Template
#;(define (world-temp w)
    ( ... (world-mushroom-field w) ... (world-swarm w) ... (world-shooter w) ... (world-bullet w) ... (world-tick w) ...))

;; DRAWING FUNCTIONS - translates the game into an animation

;; place-grid+image : Image Number Number Image -> Image
;; Places the first image at grid coordinates (firstNum, secondNum) on top of the last image
(define (place-grid+image i1 x y i2)
  (place-image i1
               (+ (* x CELL-SIZE) (ceiling (/ CELL-SIZE 2)))
               (- (- (* CELL-SIZE GRID-HEIGHT) (* y CELL-SIZE)) (ceiling (/ CELL-SIZE 2)))
               i2))

;; Examples
(check-expect (place-grid+image CENTIPEDE-CELL 0 0 BG) 
              (place-image CENTIPEDE-CELL 
                           (+ 0 (ceiling (/ CELL-SIZE 2)))
                           (- (- (* CELL-SIZE GRID-HEIGHT) 0) (ceiling (/ CELL-SIZE 2)))
                           BG))
(check-expect (place-grid+image CENTIPEDE-CELL 2 3 BG) 
              (place-image CENTIPEDE-CELL 
                           (+ 30 (ceiling (/ CELL-SIZE 2)))
                           (- (- (* CELL-SIZE GRID-HEIGHT) 45) (ceiling (/ CELL-SIZE 2)))
                           BG))
(check-expect (place-grid+image CENTIPEDE-CELL 25 40 BG) 
              (place-image CENTIPEDE-CELL 
                           (+ 375 (ceiling (/ CELL-SIZE 2)))
                           (- (- (* CELL-SIZE GRID-HEIGHT) 600) (ceiling (/ CELL-SIZE 2)))
                           BG))

;; Draw centipede(s)

;; segment+image : Segment Image -> Image
;; Draws the given Segment on the given Image
(define (segment+image seg i)
  (place-grid+image CENTIPEDE-CELL (posn-x seg) (posn-y seg) i))

;;Examples
(check-expect (segment+image (make-posn 3 4) BG) (place-grid+image CENTIPEDE-CELL 3 4 BG))
(check-expect (segment+image (make-posn 0 0) BG) (place-grid+image CENTIPEDE-CELL 0 0 BG))

;; head+image : Direction Segment Image -> Image
;; Draw the head at the given segment position with the right direction on top of the given image
(define (head+image dir head i)
  (cond [(symbol=? dir 'l) (place-grid+image LEFT-HEAD (posn-x head) (posn-y head) i)]
        [(symbol=? dir 'r) (place-grid+image RIGHT-HEAD (posn-x head) (posn-y head) i)]))

;;Examples
(check-expect (head+image 'l (make-posn 3 3) BG) (place-grid+image LEFT-HEAD 3 3 BG))
(check-expect (head+image 'r (make-posn 2 2) BG) (place-grid+image RIGHT-HEAD 2 2 BG))

;; body+image : Body Image -> Image
;; Draws the given Body on the given image
(define (body+image body i)
  (cond [(empty? body) i]
        [(cons? body) (segment+image (first body) (body+image (rest body) i))]))

;;Examples
(check-expect (body+image (cons (make-posn 3 3) (cons (make-posn 3 2) empty)) BG) 
              (place-grid+image CENTIPEDE-CELL 3 3 (place-grid+image CENTIPEDE-CELL 3 2 BG)))

;; centipede+image : Centipede Image -> Image
;; Draws the given Centipede on the given image
(define (centipede+image cent i)
  (head+image (centipede-dir cent) (first (centipede-body cent)) (body+image (rest (centipede-body cent)) i)))

;;Examples
(check-expect (centipede+image (make-centipede 'r (cons (make-posn 3 3) (cons (make-posn 3 2) empty)) true) BG)
              (head+image 'r (make-posn 3 3) (body+image (cons (make-posn 3 2) empty) BG)))

;; swarm+image : Swarm Image : -> Image
;; Draws the given Swarm on the given image
(define (swarm+image swarm i)
  (cond [(empty? swarm) i]
        [(cons? swarm) (centipede+image (first swarm) (swarm+image (rest swarm) i))]))

;;Examples
(check-expect (swarm+image (cons (make-centipede 'r (cons (make-posn 3 3) (cons (make-posn 2 3) empty)) true) 
                                 (cons (make-centipede 'l (cons (make-posn 5 5) (cons (make-posn 6 5) (cons (make-posn 7 5) empty))) true) empty)) BG)
              (centipede+image (make-centipede 'r (cons (make-posn 3 3) (cons (make-posn 2 3) empty)) true) 
                               (centipede+image (make-centipede 'l (cons (make-posn 5 5) (cons (make-posn 6 5) (cons (make-posn 7 5) empty))) true) BG)))

;; shooter+image : Shooter Image -> Image
;; Draws the given shooter on the given image
(define (shooter+image shooter i)
  (place-grid+image PLAYER (posn-x (shooter-posn shooter)) (posn-y (shooter-posn shooter)) i))

;; Examples
(check-expect (shooter+image (make-shooter (make-posn 0 0) 'right) BG)
              (place-grid+image PLAYER 0 0 BG))
(check-expect (shooter+image (make-shooter (make-posn 4 0) 'left) BG)
              (place-grid+image PLAYER 4 0 BG))
(check-expect (shooter+image (make-shooter (make-posn 25 0) 'waiting) BG)
              (place-grid+image PLAYER 25 0 BG))

;; bullet+image : Bullet Image -> Image
;; Draws the bullet onto the given image
(define (bullet+image bullet i)
  (place-grid+image BULLET (posn-x (bullet-posn bullet)) (posn-y (bullet-posn bullet)) i))

;; Examples
(check-expect (bullet+image (make-bullet (make-posn 0 0) false) BG) (place-grid+image BULLET 0 0 BG))
(check-expect (bullet+image (make-bullet (make-posn 5 5) true) BG) (place-grid+image BULLET 5 5 BG))

;; mushroom+image : Mushroom Image -> Image
;; Draws a mushroom onto the given image
(define (mushroom+image mushroom i)
  (place-grid+image (cond
                      [(= (mushroom-health mushroom) 0) (circle MUSHROOM-RADIUS 'solid MUSHROOM-0-C)]
                      [(= (mushroom-health mushroom) 1) (circle MUSHROOM-RADIUS 'solid MUSHROOM-1-C)]
                      [(= (mushroom-health mushroom) 2) (circle MUSHROOM-RADIUS 'solid MUSHROOM-2-C)]
                      [(= (mushroom-health mushroom) 3) (circle MUSHROOM-RADIUS 'solid MUSHROOM-3-C)])
                    (posn-x (mushroom-posn mushroom))
                    (posn-y (mushroom-posn mushroom))
                    i))

;; Examples
(check-expect (mushroom+image (make-mushroom (make-posn 2 3) 0) BG)
              (place-grid+image (circle MUSHROOM-RADIUS 'solid MUSHROOM-0-C) 2 3 BG))
(check-expect (mushroom+image (make-mushroom (make-posn 1 4) 1) BG)
              (place-grid+image (circle MUSHROOM-RADIUS 'solid MUSHROOM-1-C) 1 4 BG))
(check-expect (mushroom+image (make-mushroom (make-posn 1 4) 2) BG)
              (place-grid+image (circle MUSHROOM-RADIUS 'solid MUSHROOM-2-C) 1 4 BG))
(check-expect (mushroom+image (make-mushroom (make-posn 1 4) 3) BG)
              (place-grid+image (circle MUSHROOM-RADIUS 'solid MUSHROOM-3-C) 1 4 BG))

;; mushroom-field+image : MushroomField Image -> Image
;; Draws the mushroomfield onto the given image
(define (mushroom-field+image mushf i)
  (cond [(empty? mushf) i]
        [(cons? mushf) (mushroom+image (first mushf) (mushroom-field+image (rest mushf) i))]))

;; Examples
(check-expect (mushroom-field+image (cons (make-mushroom (make-posn  2 3) 0) (cons (make-mushroom (make-posn  4 7) 2) empty)) BG)
              (mushroom+image (make-mushroom (make-posn  2 3) 0) (mushroom+image (make-mushroom (make-posn  4 7) 2) BG)))

;; winner+image : Number Image -> Image
;; Draws the text "WINNER" onto the center of the given image with the given score
(define (winner+image n i)
  (place-image WINNER  (/ (image-width i) 2) (/ (image-height i) 2) 
               (place-image (text (string-append "Score: " (number->string n)) 72 'black) (/ (image-width i) 2) (+ (/ (image-height i) 2) 60) i)))

;; Examples
(check-expect (winner+image 0 BG) (place-image WINNER 188 300 (place-image (text "Score: 0" 72 'black) 188 360 BG)))
(check-expect (winner+image 10 BG) (place-image WINNER 188 300 (place-image (text "Score: 10" 72 'black) 188 360 BG)))

;; loser+image : Image -> Image
;; Draws the text "LOSER" onto the center of the given image
(define (loser+image i)
  (place-image LOSER  (/ (image-width i) 2) (/ (image-height i) 2) i))

;; Examples
(check-expect (loser+image BG) (place-image LOSER 188 300 BG))

;; LOGIC FUNCTIONS - the formula by which the game works

;; same-posn? : Posn Posn -> Boolean
;; same-posn? takes in two posns and determines if they are equal
(define (same-posn? p1 p2)
  (and (= (posn-x p1) (posn-x p2)) (= (posn-y p1) (posn-y p2))))

;; Examples
(check-expect (same-posn? (make-posn 3 3) (make-posn 3 3)) true)
(check-expect (same-posn? (make-posn 3 3) (make-posn 2 2)) false)

;; in-field? : Mushroom-Field Mushroom -> Boolean
;; in-field? determines if the given mushroom is in the given mushroom-field
(define (in-field? mushf m)
  (cond
    [(empty? mushf) false]
    [(cons? mushf) (or (same-posn? (mushroom-posn m) (mushroom-posn (first mushf))) (in-field? (rest mushf) m))]))

;; Examples
(check-expect (in-field? (cons (make-mushroom (make-posn 0 0) 3) (cons (make-mushroom (make-posn 1 1) 3) empty))
                         (make-mushroom (make-posn 0 0) 3)) true)
(check-expect (in-field? (cons (make-mushroom (make-posn 0 0) 3) (cons (make-mushroom (make-posn 1 1) 3) empty))
                         (make-mushroom (make-posn 1 0) 3)) false)

;; random-posn : Number Number -> Posn
;; random-posn returns a random posn which has an x-value between 0 and the first number and y-value between 0 and the second number (non-inclusive)
(define (random-posn x-lim y-lim)
  (make-posn (random x-lim) (+ (random (- y-lim 2)) 1)))

;;Examples
(check-expect (posn? (random-posn GRID-WIDTH GRID-HEIGHT)) true)
(check-expect (> GRID-WIDTH (posn-x (random-posn GRID-WIDTH GRID-HEIGHT))) true)
(check-expect (> GRID-HEIGHT (posn-y (random-posn GRID-WIDTH GRID-HEIGHT))) true)

;; new-mushroom : Mushroom-Field Mushroom -> Mushroom-Field
;; new-mushroom returns the mushroom-field with the mushroom if the mushroom is not already in the mushroom field
(define (new-mushroom mushf m)
  (if
   (in-field? mushf m)
   mushf
   (cons m mushf)))

;;Examples
(check-expect (new-mushroom (list (make-mushroom (make-posn 0 0) 3) (make-mushroom (make-posn 1 1) 3)) (make-mushroom (make-posn 0 0) 3))
              (list (make-mushroom (make-posn 0 0) 3) (make-mushroom (make-posn 1 1) 3)))
(check-expect (new-mushroom (list (make-mushroom (make-posn 0 0) 3) (make-mushroom (make-posn 1 1) 3)) (make-mushroom (make-posn 0 1) 3))
              (list (make-mushroom (make-posn 0 1) 3) (make-mushroom (make-posn 0 0) 3) (make-mushroom (make-posn 1 1) 3)))

;; list-size : List -> Number
;; list-size returns the size of the list
(define (list-size l)
  (cond
    [(empty? l) 0]
    [(cons? l) (+ 1 (list-size (rest l)))]))

;;Examples
(check-expect (list-size empty) 0)
(check-expect (list-size (list (make-mushroom (make-posn 0 0) 3) (make-mushroom (make-posn 1 1) 3)))
              2)
(check-expect (list-size (list (make-mushroom (make-posn 0 1) 3) (make-mushroom (make-posn 0 0) 3) (make-mushroom (make-posn 1 1) 3)))
              3)

;; add-mushrooms : Mushroom-Field Number -> Mushroom-Field
;; add-mushrooms takes in a mushroom-field and adds random mushrooms to the mushroom-field until it is size n, where 0 <= n <= 950
(define (add-mushrooms mushf n)
  (cond
    [(= (list-size mushf) n) mushf]
    [else
     (add-mushrooms (new-mushroom mushf (make-mushroom (random-posn GRID-WIDTH GRID-HEIGHT) 3)) n)]))

;;Examples
(check-expect (list-size (add-mushrooms empty 10)) 10)
(check-expect (list-size (add-mushrooms empty 50)) 50)

;; add-centipede : Number Body-> Centipede
;; add-centipede takes a number (0<n<=25) and a body returns a new centipede at the start of the game of that length,
(define (add-centipede n body)
  (cond[(= (list-size body) n) (make-centipede 'r body true)]
       [else (add-centipede n (cons (make-posn (+ 1 (posn-x (first body))) (- GRID-HEIGHT 1)) body))]))

;;Examples 
(check-expect (add-centipede 4 (list (make-posn 0 39)))
              (make-centipede 'r (list (make-posn 3 39) (make-posn 2 39) (make-posn 1 39) (make-posn 0 39)) true))
(check-expect (add-centipede 1 (list (make-posn 0 39)))
              (make-centipede 'r (list (make-posn 0 39)) true))

;;============================================================================================
(define WORLD0 (make-world (add-mushrooms empty 30) 
                           (list (add-centipede 10 (list (make-posn 0 40)))) 
                           (make-shooter (make-posn (floor (/ GRID-WIDTH 2)) 0) 'waiting)
                           (make-bullet (make-posn (floor (/ GRID-WIDTH 2)) 0) false) 0))
;;============================================================================================

;; new-head : Direction Segment -> Segment
;; new-head returns a new segment advanced one unit in the direction from the given segment
(define (new-head dir seg)
  (cond [(symbol=? 'r dir) (make-posn (+ 1(posn-x seg)) (posn-y seg))]
        [(symbol=? 'l dir) (make-posn (- (posn-x seg) 1) (posn-y seg))]
        [(symbol=? 'u dir) (make-posn (posn-x seg) (+ 1 (posn-y seg)))]
        [(symbol=? 'd dir) (make-posn (posn-x seg) (- (posn-y seg) 1))]))

;;Examples 
(check-expect (new-head 'r (make-posn 1 1)) (make-posn 2 1))
(check-expect (new-head 'l (make-posn 1 1)) (make-posn 0 1))
(check-expect (new-head 'u (make-posn 1 1)) (make-posn 1 2))
(check-expect (new-head 'd (make-posn 1 1)) (make-posn 1 0))

;; remove-tail : Body -> Body
;; remove-tail takes a body and removes the last segment of the body
(define (remove-tail body)
  (cond [(empty? (rest body)) empty]
        [(cons? body) (cons (first body) (remove-tail (rest body)))]))

;;Examples
(check-expect (remove-tail (list (make-posn 3 3) (make-posn 2 3) (make-posn 1 3)))
              (list (make-posn 3 3) (make-posn 2 3)))
(check-expect (remove-tail (list (make-posn 3 3) (make-posn 2 3) (make-posn 1 3) (make-posn 0 3)))
              (list (make-posn 3 3) (make-posn 2 3) (make-posn 1 3)))

;; move-centipede-body : Direction Body -> Body
;; Add a new head to the body in the given dir and remove the last segment of the body
(define (move-centipede-body dir body)
  (cons (new-head dir (first body)) (remove-tail body)))

;;Examples
(check-expect (move-centipede-body 'r (list (make-posn 3 3) (make-posn 2 3) (make-posn 1 3) (make-posn 0 3)))
              (cons (new-head 'r (make-posn 3 3)) (remove-tail (list (make-posn 3 3) (make-posn 2 3) (make-posn 1 3) (make-posn 0 3)))))
(check-expect (move-centipede-body 'l (list (make-posn 3 3)))
              (cons (new-head 'l (make-posn 3 3)) (remove-tail (list (make-posn 3 3)))))

;; move-centipede : Centipede -> Centipede
;; move-centipede takes a centipede and moves it to the next position in its current direction
(define (move-centipede cent)
  (make-centipede (centipede-dir cent) (move-centipede-body (centipede-dir cent) (centipede-body cent)) (centipede-down? cent)))

;;Examples
(check-expect (move-centipede (make-centipede 'r (list (make-posn 3 3) (make-posn 2 3) (make-posn 1 3) (make-posn 0 3)) true))
              (make-centipede 'r (list (make-posn 4 3) (make-posn 3 3) (make-posn 2 3) (make-posn 1 3)) true))
(check-expect (move-centipede (make-centipede 'l (list (make-posn 5 5)) true))
              (make-centipede 'l (list (make-posn 4 5)) true))

;; move-swarm : Swarm -> Swarm
;; move-swarm takes a swarm and moves each of the centipedes within it
(define (move-swarm s)
  (cond [(empty? s) empty]
        [(cons? s) (cons (move-centipede (first s)) (move-swarm (rest s)))]))

(check-expect (move-swarm (cons (make-centipede 'r (cons (make-posn 5 5) (cons (make-posn 4 5) empty)) true)
                                (cons (make-centipede 'l (cons (make-posn 10 10) (cons (make-posn 9 10) empty)) true) empty)))
              (cons (make-centipede 'r (cons (make-posn 6 5) (cons (make-posn 5 5) empty)) true)
                    (cons (make-centipede 'l (cons (make-posn 9 10) (cons (make-posn 10 10) empty)) true) empty)))
(check-expect (move-swarm (cons (make-centipede 'r (cons (make-posn 5 5) empty) true) empty))
              (cons (make-centipede 'r (cons (make-posn 6 5) empty) true) empty))
(check-expect (move-swarm empty) empty)

;; in-centipede? : Body Posn-> boolean
;; in-centipede? checks if the given position is anywhere within the body
(define (in-centipede? body posn)
  (cond
    [(empty? body) false]
    [(cons? body) (or (same-posn? posn (first body)) (in-centipede? (rest body) posn))]))

;; Examples
(check-expect (in-centipede? (cons (make-posn 10 10) (cons (make-posn 9 10) empty)) (make-posn 4 4)) false)
(check-expect (in-centipede? (cons (make-posn 10 10) (cons (make-posn 9 10) empty)) (make-posn 9 10)) true)
(check-expect (in-centipede? empty (make-posn 0 0)) false)

;; in-swarm? : Swarm Posn-> boolean
;; in-swarm? checks if the given position is anywhere within the swarm
(define (in-swarm? swarm posn)
  (cond [(empty? swarm) false]
        [(cons? swarm) (or (in-centipede? (centipede-body (first swarm)) posn) (in-swarm? (rest swarm) posn))]))

(check-expect (in-swarm? empty (make-posn 3 2)) false)
(check-expect (in-swarm? (cons (make-centipede 'r (cons (make-posn 5 5) (cons (make-posn 4 5) empty)) true)
                               (cons (make-centipede 'l (cons (make-posn 10 10) (cons (make-posn 9 10) empty)) true) empty)) (make-posn 10 10))
              true)
(check-expect (in-swarm? (cons (make-centipede 'r (cons (make-posn 5 5) (cons (make-posn 4 5) empty)) true)
                               (cons (make-centipede 'l (cons (make-posn 10 10) (cons (make-posn 9 10) empty)) true) empty)) (make-posn 5 5))
              true)

;; move-shooter : Shooter -> Shooter
;; move-shooter takes the given shooter and moves it in the direction of the ShooterSymbol, otherwise stays put
(define (move-shooter shooter)
  (cond [(symbol=? 'right (shooter-symbol shooter)) (make-shooter (make-posn (+ 1 (posn-x (shooter-posn shooter))) 0) 'right)]
        [(symbol=? 'left (shooter-symbol shooter)) (make-shooter (make-posn (- (posn-x (shooter-posn shooter)) 1) 0) 'left)]
        [else shooter]))

;;Examples
(check-expect (move-shooter (make-shooter (make-posn 5 0) 'waiting))
              (make-shooter (make-posn 5 0) 'waiting))
(check-expect (move-shooter (make-shooter (make-posn 5 0) 'right))
              (make-shooter (make-posn 6 0) 'right))
(check-expect (move-shooter (make-shooter (make-posn 5 0) 'left))
              (make-shooter (make-posn 4 0) 'left))

;; press : World Key -> World
;; press changes the direction of the shooter if the left or right arrow keys are pressed, and fires the bullet if space is pressed
(define (press w key)
  (cond [(string=? key "right") (make-world (world-mushroom-field w) (world-swarm w) (make-shooter (shooter-posn (world-shooter w)) 'right) (world-bullet w) (world-tick w))]
        [(string=? key "left") (make-world (world-mushroom-field w) (world-swarm w) (make-shooter (shooter-posn (world-shooter w)) 'left) (world-bullet w) (world-tick w))]
        [(string=? key " ") (make-world (world-mushroom-field w) (world-swarm w) (world-shooter w) (make-bullet (bullet-posn(world-bullet w)) true) (world-tick w))]
        [else w]))

;;Examples
(check-expect (press WORLD0 "right")
              (make-world (world-mushroom-field WORLD0) 
                          (world-swarm WORLD0)
                          (make-shooter (make-posn (floor (/ GRID-WIDTH 2)) 0) 'right)
                          (world-bullet WORLD0) 0))
(check-expect (press WORLD0 "left")
              (make-world (world-mushroom-field WORLD0) 
                          (world-swarm WORLD0)
                          (make-shooter (make-posn (floor (/ GRID-WIDTH 2)) 0) 'left)
                          (world-bullet WORLD0) 0))
(check-expect (press WORLD0 " ")
              (make-world (world-mushroom-field WORLD0) 
                          (world-swarm WORLD0)
                          (world-shooter WORLD0)
                          (make-bullet (bullet-posn (world-bullet WORLD0)) true) 0))

;; release : World Key -> World
;; stops moving the shooter if it is moving in a direction
(define (release w key)
  (cond [(and (string=? key "right") (symbol=? (shooter-symbol (world-shooter w)) 'right))
         (make-world (world-mushroom-field w) (world-swarm w) (make-shooter (shooter-posn (world-shooter w)) 'waiting) (world-bullet w) (world-tick w))]
        [(and (string=? key "left") (symbol=? (shooter-symbol (world-shooter w)) 'left))
         (make-world (world-mushroom-field w) (world-swarm w) (make-shooter (shooter-posn (world-shooter w)) 'waiting) (world-bullet w) (world-tick w))]
        [else w]))

;;Example
(check-expect (release (make-world (world-mushroom-field WORLD0) (world-swarm WORLD0) (make-shooter (make-posn 0 0) 'right) (world-bullet WORLD0) 0)
                       "right")
              (make-world (world-mushroom-field WORLD0) (world-swarm WORLD0) (make-shooter (make-posn 0 0) 'waiting) (world-bullet WORLD0) 0))
(check-expect (release (make-world (world-mushroom-field WORLD0) (world-swarm WORLD0) (make-shooter (make-posn 25 0) 'left) (world-bullet WORLD0) 0)
                       "left")
              (make-world (world-mushroom-field WORLD0) (world-swarm WORLD0) (make-shooter (make-posn 25 0) 'waiting) (world-bullet WORLD0) 0))
(check-expect (release WORLD0 "right")
              WORLD0)

;; floor-ceiling-shift : Centipede -> Centipede
;; floor-ceiling-shift shifts the segment of the centipede up or down if the centipede hits the ceiling or floor
(define (floor-ceiling-shift cent)
  (cond
    [(> (posn-y (first (centipede-body cent))) (- GRID-HEIGHT 1))
     (make-centipede (centipede-dir cent)
                     (cons (new-head 'd (new-head 'd (first (centipede-body cent)))) (rest (centipede-body cent)))
                     true)]
    [(< (posn-y (first (centipede-body cent))) 0)
     (make-centipede (centipede-dir cent)
                     (cons (new-head 'u (new-head 'u (first (centipede-body cent)))) (rest (centipede-body cent)))
                     false)]
    [else cent]))

;; Examples
(check-expect (floor-ceiling-shift (make-centipede 'r (cons (make-posn 24 40) (cons (make-posn 25 40) empty)) false))
              (make-centipede 'r (cons (make-posn 24 38) (cons (make-posn 25 40) empty)) true))
(check-expect (floor-ceiling-shift (make-centipede 'l (cons (make-posn 0 -1) (cons (make-posn 0 0) empty)) true))
              (make-centipede 'l (cons (make-posn 0 1) (cons (make-posn 0 0) empty)) false))
(check-expect (floor-ceiling-shift (make-centipede 'r (cons (make-posn 25 10) (cons (make-posn 24 10) empty)) true))
              (make-centipede 'r (cons (make-posn 25 10) (cons (make-posn 24 10) empty)) true))

;; centipede-turn : Centipede -> Centipede
;; centipede-turn moves the centipede down a row and changes its direction
(define (centipede-turn cent)
  (cond [(symbol=? (centipede-dir cent) 'r)
         (floor-ceiling-shift (make-centipede 'l
                                              (cons (new-head 'l (new-head (cond
                                                                             [(centipede-down? cent) 'd]
                                                                             [else 'u])
                                                                           (first (centipede-body cent)))) (rest (centipede-body cent)))
                                              (centipede-down? cent)))]
        [(symbol=? (centipede-dir cent) 'l)
         (floor-ceiling-shift (make-centipede 'r
                                              (cons (new-head 'r (new-head (cond
                                                                             [(centipede-down? cent) 'd]
                                                                             [else 'u])
                                                                           (first (centipede-body cent)))) (rest (centipede-body cent)))
                                              (centipede-down? cent)))]))

;; Examples
(check-expect (centipede-turn (make-centipede 'r (cons (make-posn 25 3) (cons (make-posn 24 3) empty)) true))
              (make-centipede 'l (cons (make-posn 24 2) (cons (make-posn 24 3) empty)) true))
(check-expect (centipede-turn (make-centipede 'l (cons (make-posn 0 3) (cons (make-posn 1 3) empty)) true))
              (make-centipede 'r (cons (make-posn 1 2) (cons (make-posn 1 3) empty)) true))
(check-expect (centipede-turn (make-centipede 'r (cons (make-posn 25 3) (cons (make-posn 24 3) empty)) false))
              (make-centipede 'l (cons (make-posn 24 4) (cons (make-posn 24 3) empty)) false))
(check-expect (centipede-turn (make-centipede 'l (cons (make-posn 0 3) (cons (make-posn 1 3) empty)) false))
              (make-centipede 'r (cons (make-posn 1 4) (cons (make-posn 1 3) empty)) false))

;; adjust-shooter+bullet : World Number ShooterSymbol -> World
;; adjust-shooter+bullet moves the bullet and shooter if the bullet is not firing Number (where n -s either negative or positive 1) distance
(define (adjust-shooter+bullet w num dir)
  (if (not(bullet-firing? (world-bullet w)))
      (make-world (world-mushroom-field w) 
                  (world-swarm w) 
                  (make-shooter (make-posn (+ num (posn-x (shooter-posn (world-shooter w))))
                                           0) dir)
                  (make-bullet (make-posn (+ num (posn-x (bullet-posn (world-bullet w))))
                                          0) false)
                  (world-tick w))
      (make-world (world-mushroom-field w) 
                  (world-swarm w) 
                  (make-shooter (make-posn (+ num (posn-x (shooter-posn (world-shooter w))))
                                           0) dir)
                  (world-bullet w)
                  (world-tick w))))

;;Examples
(check-expect (adjust-shooter+bullet WORLD0 1 'right)
              (make-world (world-mushroom-field WORLD0)
                          (world-swarm WORLD0)
                          (make-shooter (make-posn 13 0) 'right)
                          (make-bullet (make-posn 13 0) false)
                          (world-tick WORLD0)))
(check-expect (adjust-shooter+bullet 
               (make-world (world-mushroom-field WORLD0)
                           (world-swarm WORLD0)
                           (world-shooter WORLD0)
                           (make-bullet (make-posn 12 1) true)
                           (world-tick WORLD0)) 1 'right)
              (make-world (world-mushroom-field WORLD0)
                          (world-swarm WORLD0)
                          (make-shooter (make-posn 13 0) 'right)
                          (make-bullet (make-posn 12 1) true)
                          (world-tick WORLD0)))

;; shooter+bullet : World ShooterSymbol -> World
;; shooter+bullet adjusts the bullet and shooter according to adjust-shooter+bullet
(define (shooter+bullet w dir)
  (cond [(symbol=? dir 'right) (adjust-shooter+bullet w 1 'right)]
        [(symbol=? dir 'left) (adjust-shooter+bullet w -1 'left)]))

(check-expect (shooter+bullet WORLD0 'right)
              (make-world (world-mushroom-field WORLD0)
                          (world-swarm WORLD0)
                          (make-shooter (make-posn 13 0) 'right)
                          (make-bullet (make-posn 13 0) false)
                          (world-tick WORLD0)))
(check-expect (shooter+bullet WORLD0 'left)
              (make-world (world-mushroom-field WORLD0)
                          (world-swarm WORLD0)
                          (make-shooter (make-posn 11 0) 'left)
                          (make-bullet (make-posn 11 0) false)
                          (world-tick WORLD0)))
(check-expect (shooter+bullet (make-world (world-mushroom-field WORLD0)
                                          (world-swarm WORLD0)
                                          (world-shooter WORLD0)
                                          (make-bullet (make-posn 12 1) true)
                                          (world-tick WORLD0))'right)
              (make-world (world-mushroom-field WORLD0)
                          (world-swarm WORLD0)
                          (make-shooter (make-posn 13 0) 'right)
                          (make-bullet (make-posn 12 1) true)
                          (world-tick WORLD0)))
(check-expect (shooter+bullet (make-world (world-mushroom-field WORLD0)
                                          (world-swarm WORLD0)
                                          (world-shooter WORLD0)
                                          (make-bullet (make-posn 12 1) true)
                                          (world-tick WORLD0)) 'left)
              (make-world (world-mushroom-field WORLD0)
                          (world-swarm WORLD0)
                          (make-shooter (make-posn 11 0) 'left)
                          (make-bullet (make-posn 12 1) true)
                          (world-tick WORLD0)))

;; on-tick-shooter : World -> World
;; on-tick-shooter takes the shooter of the given world and returns a new world with the shooter moved appropriately
(define (on-tick-shooter w)
  (cond [(and (symbol=? (shooter-symbol (world-shooter w)) 'right)
              (< (posn-x (shooter-posn (world-shooter w))) (- GRID-WIDTH 1))) (shooter+bullet w 'right)]
        [(and (symbol=? (shooter-symbol (world-shooter w)) 'left)
              (> (posn-x (shooter-posn (world-shooter w))) 0)) (shooter+bullet w 'left)]
        [else w]))

;; Examples
(check-expect (on-tick-shooter WORLD0) WORLD0)
(check-expect (on-tick-shooter (make-world 
                                (world-mushroom-field WORLD0)
                                (world-swarm WORLD0)
                                (make-shooter (make-posn 12 0) 'right)
                                (make-bullet (make-posn 12 0) false)
                                (world-tick WORLD0)))
              (shooter+bullet (make-world 
                               (world-mushroom-field WORLD0)
                               (world-swarm WORLD0)
                               (make-shooter (make-posn 12 0) 'right)
                               (make-bullet (make-posn 12 0) false)
                               (world-tick WORLD0)) 'right))
(check-expect (on-tick-shooter (make-world 
                                (world-mushroom-field WORLD0)
                                (world-swarm WORLD0)
                                (make-shooter (make-posn 12 0) 'left)
                                (make-bullet (make-posn 12 0) false)
                                (world-tick WORLD0)))
              (shooter+bullet (make-world 
                               (world-mushroom-field WORLD0)
                               (world-swarm WORLD0)
                               (make-shooter (make-posn 12 0) 'left)
                               (make-bullet (make-posn 12 0) false)
                               (world-tick WORLD0)) 'left))

;; reset-bullet : Shooter -> Bullet
;; reset-bullet takes a shooter and returns a bullet behind the shooter
(define (reset-bullet shooter)
  (make-bullet (shooter-posn shooter) false))

;; Examples
(check-expect (reset-bullet (make-shooter (make-posn 5 0) 'right)) (make-bullet (make-posn 5 0) false))
(check-expect (reset-bullet (make-shooter (make-posn 10 0) 'left)) (make-bullet (make-posn 10 0) false))
(check-expect (reset-bullet (make-shooter (make-posn 15 0) 'waiting)) (make-bullet (make-posn 15 0) false))

;; field-damage Posn MushroomField -> MushroomField
;; field-damage takes the posn of a bullet and changes the mushroom field accordingly
(define (field-damage posn mushf)
  (cond
    [(empty? mushf) empty]
    [(cons? mushf) (if (same-posn? posn (mushroom-posn (first mushf)))
                       (if (> (mushroom-health (first mushf)) 0)
                           (cons (make-mushroom (mushroom-posn (first mushf)) (- (mushroom-health (first mushf)) 1))
                                 (field-damage posn (rest mushf)))
                           (field-damage posn (rest mushf)))
                       (cons (first mushf) (field-damage posn (rest mushf))))]))

;; Examples
(check-expect (field-damage (make-posn 5 5)
                            (cons (make-mushroom (make-posn 3 3) 3) (cons (make-mushroom (make-posn 5 5) 3) empty)))
              (cons (make-mushroom (make-posn 3 3) 3) (cons (make-mushroom (make-posn 5 5) 2) empty)))
(check-expect (field-damage (make-posn 4 4)
                            (cons (make-mushroom (make-posn 3 3) 3) (cons (make-mushroom (make-posn 4 4) 1) empty)))
              (cons (make-mushroom (make-posn 3 3) 3) (cons (make-mushroom (make-posn 4 4) 0) empty)))
(check-expect (field-damage (make-posn 3 3)
                            (cons (make-mushroom (make-posn 3 3) 0) (cons (make-mushroom (make-posn 4 4) 3) empty)))
              (cons (make-mushroom (make-posn 4 4) 3) empty))

;; mush-hit : World -> World
;; mush-hit takes a world where a bullet is intersecting a mushroom and changes the mushroom and bullet accordingly
(define (mush-hit w)
  (make-world (field-damage (bullet-posn (world-bullet w)) (world-mushroom-field w)) 
              (world-swarm w) 
              (world-shooter w) 
              (reset-bullet (world-shooter w)) 
              (world-tick w)))

;; Examples
(check-expect (mush-hit (make-world
                         (list (make-mushroom (make-posn 0 0) 3))
                         (world-swarm WORLD0)
                         (world-shooter WORLD0)
                         (make-bullet (make-posn 0 0) true)
                         (world-tick WORLD0)))
              (make-world
               (field-damage (make-posn 0 0) (list (make-mushroom (make-posn 0 0) 3)))
               (world-swarm WORLD0)
               (world-shooter WORLD0)
               (reset-bullet (world-shooter WORLD0))
               (world-tick WORLD0)))

;; split-centipede : Body Body Direction Boolean Posn -> Swarm
;; split-centipede removes centipede segments where the posn is and creates two centipedes in the given direction, given that the second body starts as empty
(define (split-centipede body growing-body dir down? posn)
  (cond [(empty? (rest body)) (if (= (list-size growing-body) 0)
                                  empty
                                  (list (make-centipede dir growing-body down?)))]
        [(cons? body) (if (same-posn? posn (first body))
                          (cond[(= (list-size growing-body) 0) (list (make-centipede dir (rest body) down?))]
                               [else (cons (make-centipede dir growing-body down?) (list (make-centipede dir (rest body) down?)))])
                          (split-centipede (rest body) (append growing-body (list (first body))) dir down? posn))]))

;; Examples
(check-expect (split-centipede (list (make-posn 0 0) (make-posn 0 1) (make-posn 0 2) (make-posn 0 3)) empty 'l true (make-posn 0 2))
              (list (make-centipede 'l (list (make-posn 0 0) (make-posn 0 1)) true) (make-centipede 'l (list (make-posn 0 3)) true)))
(check-expect (split-centipede (list (make-posn 0 0)) empty 'r true (make-posn 0 0))
              empty)
(check-expect (split-centipede (list (make-posn 0 0) (make-posn 0 1)) empty 'r true (make-posn 0 0))
              (list (make-centipede 'r (list (make-posn 0 1)) true)))
(check-expect (split-centipede (list (make-posn 0 0) (make-posn 0 1)) empty 'r true (make-posn 0 1))
              (list (make-centipede 'r (list (make-posn 0 0)) true)))


;; split-swarm : Swarm Posn -> Swarm
;; split-swarm removes swarm segments where the posn is 
(define (split-swarm swarm posn)
  (cond [(empty? swarm) empty]
        [(cons? swarm) (if (in-centipede? (centipede-body (first swarm)) posn)
                           (append (split-centipede (centipede-body (first swarm)) empty (centipede-dir (first swarm)) (centipede-down? (first swarm)) posn) 
                                   (split-swarm (rest swarm) posn))
                           (cons (first swarm) (split-swarm (rest swarm) posn)))]))

;;Examples
(check-expect (split-swarm (list (make-centipede 'r (list (make-posn 2 0) (make-posn 1 0) (make-posn 0 0)) true)) (make-posn 4 5))
              (list (make-centipede 'r (list (make-posn 2 0) (make-posn 1 0) (make-posn 0 0)) true)))
(check-expect (split-swarm (list (make-centipede 'r (list (make-posn 2 0) (make-posn 1 0) (make-posn 0 0)) true)) (make-posn 1 0))
              (split-centipede (list (make-posn 2 0) (make-posn 1 0) (make-posn 0 0)) empty 'r true (make-posn 1 0)))

;; cent-hit : World -> World
;; cent-hit takes a(n) centipede(s) and splits them where the bullet hits, creates a mushroom there, and resets the bullet
(define (cent-hit w)
  (make-world
   (cons (make-mushroom (bullet-posn (world-bullet w)) 3) (world-mushroom-field w))
   (split-swarm (world-swarm w) (bullet-posn (world-bullet w)))
   (world-shooter w)
   (reset-bullet (world-shooter w))
   (world-tick w)))

;;Examples
(check-expect (cent-hit (make-world (world-mushroom-field WORLD0)
                                    (list (make-centipede 'r (list (make-posn 0 0)) true))
                                    (world-shooter WORLD0)
                                    (make-bullet (make-posn 0 0) true)
                                    (world-tick WORLD0)))
              
              (make-world 
               (cons (make-mushroom (make-posn 0 0) 3) (world-mushroom-field WORLD0))
               (split-swarm (list (make-centipede 'r (list (make-posn 0 0)) true)) (make-posn 0 0))
               (world-shooter WORLD0)
               (reset-bullet (world-shooter WORLD0))
               (world-tick WORLD0)))

;; bullet-collision-check : World -> World
;; bullet-collision-check checks if the bullet has hit anything or left the screen, and changes the world accordingly
(define (bullet-collision-check w)
  (cond [(in-field? (world-mushroom-field w) (make-mushroom (bullet-posn (world-bullet w)) 3)) (mush-hit w)]
        [(in-swarm? (world-swarm w) (bullet-posn (world-bullet w))) (cent-hit w)]
        [(> (posn-y (bullet-posn (world-bullet w))) GRID-HEIGHT) 
         (make-world
          (world-mushroom-field w)
          (world-swarm w)
          (world-shooter w)
          (reset-bullet (world-shooter w))
          (world-tick w))]
        [else w]))

;;Examples
(check-expect (bullet-collision-check WORLD0) WORLD0)
(check-expect (bullet-collision-check (make-world (list (make-mushroom (make-posn 0 0) 3))
                                                  (world-swarm WORLD0)
                                                  (world-shooter WORLD0)
                                                  (make-bullet (make-posn 0 0) true)
                                                  (world-tick WORLD0)))
              (mush-hit (make-world (list (make-mushroom (make-posn 0 0) 3))
                                    (world-swarm WORLD0)
                                    (world-shooter WORLD0)
                                    (make-bullet (make-posn 0 0) true)
                                    (world-tick WORLD0))))
(check-expect (bullet-collision-check (make-world (world-mushroom-field WORLD0)
                                                  (list (make-centipede 'r (list (make-posn 0 0)) true))
                                                  (world-shooter WORLD0)
                                                  (make-bullet (make-posn 0 0) true)
                                                  (world-tick WORLD0)))
              (cent-hit (make-world (world-mushroom-field WORLD0)
                                    (list (make-centipede 'r (list (make-posn 0 0)) true))
                                    (world-shooter WORLD0)
                                    (make-bullet (make-posn 0 0) true)
                                    (world-tick WORLD0))))
(check-expect (bullet-collision-check (make-world (world-mushroom-field WORLD0)
                                                  (world-swarm WORLD0)
                                                  (world-shooter WORLD0)
                                                  (make-bullet (make-posn 600 600) true)
                                                  (world-tick WORLD0)))
              WORLD0)

;; on-tick-bullet : World -> World
;; on-tick-bullet takes the bullet of the given world and returns a new world with the bullet moved appropriately
(define (on-tick-bullet w)
  (if (bullet-firing? (world-bullet w)) 
      (bullet-collision-check (make-world (world-mushroom-field w) 
                                          (world-swarm w) 
                                          (world-shooter w)
                                          (make-bullet (make-posn (posn-x (bullet-posn (world-bullet w))) 
                                                                  (+ 1 (posn-y (bullet-posn (world-bullet w))))) true)
                                          (world-tick w)))
      w))

;; Examples
(check-expect (on-tick-bullet WORLD0) WORLD0)
(check-expect (on-tick-bullet (make-world (world-mushroom-field WORLD0)
                                          (world-swarm WORLD0)
                                          (world-shooter WORLD0)
                                          (make-bullet (make-posn 0 0) true)
                                          (world-tick WORLD0)))
              (make-world (world-mushroom-field WORLD0)
                          (world-swarm WORLD0)
                          (world-shooter WORLD0)
                          (make-bullet (make-posn 0 1) true)
                          (world-tick WORLD0)))

;; centipede-hit? : Centipede MushroomField -> Boolean
;; centipede-hit? determines if the head of the centipede hits a mushroom or wall
(define (centipede-hit? cent mushf)
  (or
   (or (< (posn-x (first (centipede-body cent))) 0) (> (posn-x (first (centipede-body cent))) (- GRID-WIDTH 1)))
   (in-field? mushf (make-mushroom (first (centipede-body cent)) 3))))

;;Examples
(check-expect (centipede-hit? (make-centipede 'r (list (make-posn -1 0)) true) (list (make-mushroom (make-posn 0 0) 3)))
              true)
(check-expect (centipede-hit? (make-centipede 'r (list (make-posn 0 0)) true) (list (make-mushroom (make-posn 0 0) 3)))
              true)
(check-expect (centipede-hit? (make-centipede 'r (list (make-posn 1 0)) true) (list (make-mushroom (make-posn 0 0) 3)))
              false)

;; swarm-hit? Swarm MushroomField -> Boolean
;; swarm-hit? determines if any of the centipedes in the swarm hit a wall or mushroom
(define (swarm-hit? swarm mushf)
  (cond
    [(empty? swarm) false]
    [(cons? swarm) (or (centipede-hit? (first swarm) mushf) (swarm-hit? (rest swarm) mushf))]))

;;Examples
(check-expect (swarm-hit? (list (make-centipede 'r (list (make-posn 0 0)) true)) (list (make-mushroom (make-posn 0 0) 3)))
              true)
(check-expect (swarm-hit? (list (make-centipede 'r (list (make-posn 1 0)) true)) (list (make-mushroom (make-posn 0 0) 3)))
              false)

;; swarm-turn : Swarm MushroomField -> Swarm
;; swarm-turn takes in a swarm and a mushroomfield and turns any centipede that hits something
(define (swarm-turn swarm mushf)
  (cond
    [(empty? swarm) empty]
    [(cons? swarm) (if
                    (centipede-hit? (first swarm) mushf)
                    (cons (centipede-turn (first swarm)) (swarm-turn (rest swarm) mushf))
                    (cons (first swarm) (swarm-turn (rest swarm) mushf)))]))

(check-expect (swarm-turn (world-swarm WORLD0) (world-mushroom-field WORLD0))
              (world-swarm WORLD0))
(check-expect (swarm-turn (list (make-centipede 'r (list (make-posn 0 0)) true)) (list (make-mushroom (make-posn 0 0) 3)))
              (list (centipede-turn  (make-centipede 'r (list (make-posn 0 0)) true))))


;; swarm-hit : World -> World
;; swarm-hit takes in the swarm in the given world and moves it appropriately in the given world
(define (swarm-hit w)
  (make-world (world-mushroom-field w)
              (swarm-turn (world-swarm w) (world-mushroom-field w))
              (world-shooter w)
              (world-bullet w)
              (world-tick w)))

;;Examples
(check-expect (swarm-hit WORLD0)
              (make-world (world-mushroom-field WORLD0)
                          (swarm-turn (world-swarm WORLD0) (world-mushroom-field WORLD0))
                          (world-shooter WORLD0)
                          (world-bullet WORLD0)
                          (world-tick WORLD0)))

;; centipede-collision-check : World ->World
;; centipede-collision-check checks the centipedes for collisions and moves them accordingly
(define (centipede-collision-check w)
  (cond [(swarm-hit? (world-swarm w) (world-mushroom-field w)) (swarm-hit w)]
        [else w]))

;;Examples
(check-expect (centipede-collision-check WORLD0) WORLD0)
(check-expect (centipede-collision-check (make-world (list (make-mushroom (make-posn 3 3) 3))
                                                     (list (make-centipede 'r (list (make-posn 3 3)) true))
                                                     (world-shooter WORLD0)
                                                     (world-bullet WORLD0)
                                                     (world-tick WORLD0)))
              (swarm-hit (make-world (list (make-mushroom (make-posn 3 3) 3))
                                                     (list (make-centipede 'r (list (make-posn 3 3)) true))
                                                     (world-shooter WORLD0)
                                                     (world-bullet WORLD0)
                                                     (world-tick WORLD0))))

;; on-tick-centipede World -> World
;; on-tick-centipede takes the centipedes of the current world and moves them accordingly
(define (on-tick-centipede w)
  (centipede-collision-check (make-world
                              (world-mushroom-field w)
                              (move-swarm (world-swarm w))
                              (world-shooter w)
                              (world-bullet w)
                              (world-tick w))))

;;Examples
(check-expect (on-tick-centipede WORLD0)
              (make-world (world-mushroom-field WORLD0)
                          (move-swarm (world-swarm WORLD0))
                          (world-shooter WORLD0)
                          (world-bullet WORLD0)
                          (world-tick WORLD0)))
                                        

;; won-game? : World -> Boolean
;; won-game? takes the given world and determines if you have won the game
(define (won-game? w)
  (= (list-size (world-swarm w)) 0))

;;Examples
(check-expect (won-game? WORLD0) false)
(check-expect (won-game? (make-world (world-mushroom-field WORLD0)
                                     empty
                                     (world-shooter WORLD0)
                                     (world-bullet WORLD0)
                                     (world-tick WORLD0)))
              true)

;; lost-game? : World -> Boolean
;; lost-game? takes the given world and determines if you have lost the game
(define (lost-game? w)
  (in-swarm? (world-swarm w) (shooter-posn (world-shooter w))))

;;Examples
(check-expect (lost-game? WORLD0) false)
(check-expect (lost-game? (make-world (world-mushroom-field WORLD0)
                                     (list (make-centipede 'r (list (make-posn 12 0)) true))
                                     (world-shooter WORLD0)
                                     (world-bullet WORLD0)
                                     (world-tick WORLD0)))
              true)

;; world-advance : World -> World
;; world-advance adds one to the tick of the world
(define (world-advance w)
  (make-world
   (world-mushroom-field w)
   (world-swarm w)
   (world-shooter w)
   (world-bullet w)
   (+ 1 (world-tick w))))

;;Examples
(check-expect (world-advance WORLD0)
              (make-world
               (world-mushroom-field WORLD0)
               (world-swarm WORLD0)
               (world-shooter WORLD0)
               (world-bullet WORLD0)
               1))

;; world->world : World -> World
;; world->world takes the current world and advances it to the next world
(define (world->world w)
  (world-advance 
   (cond [(= (modulo (world-tick w) (* BULL-SPEED SHOT-SPEED CENT-SPEED)) 0)
          (on-tick-bullet (on-tick-shooter (on-tick-centipede w)))]
         [(= (modulo (world-tick w) (* BULL-SPEED SHOT-SPEED)) 0)
          (on-tick-bullet (on-tick-shooter w))]
         [(= (modulo (world-tick w) (* BULL-SPEED CENT-SPEED)) 0)
          (on-tick-bullet (on-tick-centipede w))]
         [(= (modulo (world-tick w) (* CENT-SPEED SHOT-SPEED)) 0) ;; As BULL-SPEED is currently 1, this clause is impossible to reach, 
                                                                  ;;but we added it to make room for future changes
          (on-tick-shooter (on-tick-centipede w))]
         [(= (modulo (world-tick w) BULL-SPEED) 0)
          (on-tick-bullet w)]
         [(= (modulo (world-tick w) SHOT-SPEED) 0) ;; As BULL-SPEED is currently 1, this clause is impossible to reach, 
                                                   ;;but we added it to make room for future changes
          (on-tick-shooter w)]
         [(= (modulo (world-tick w) CENT-SPEED) 0) ;; As BULL-SPEED is currently 1, this clause is impossible to reach, 
                                                   ;;but we added it to make room for future changes
          (on-tick-centipede w)])))

;;Examples
(check-expect (world->world WORLD0)
              (world-advance (on-tick-bullet (on-tick-shooter (on-tick-centipede WORLD0)))))
(check-expect (world->world (make-world (world-mushroom-field WORLD0)
                                        (world-swarm WORLD0)
                                        (world-shooter WORLD0)
                                        (world-bullet WORLD0)
                                        1))
              (world-advance (on-tick-bullet (make-world (world-mushroom-field WORLD0)
                                        (world-swarm WORLD0)
                                        (world-shooter WORLD0)
                                        (world-bullet WORLD0)
                                        1))))
(check-expect (world->world (make-world (world-mushroom-field WORLD0)
                                        (world-swarm WORLD0)
                                        (world-shooter WORLD0)
                                        (world-bullet WORLD0)
                                        3))
              (world-advance (on-tick-shooter (on-tick-bullet (make-world (world-mushroom-field WORLD0)
                                        (world-swarm WORLD0)
                                        (world-shooter WORLD0)
                                        (world-bullet WORLD0)
                                        3)))))
(check-expect (world->world (make-world (world-mushroom-field WORLD0)
                                        (world-swarm WORLD0)
                                        (world-shooter WORLD0)
                                        (world-bullet WORLD0)
                                        5))
              (world-advance (on-tick-centipede (on-tick-bullet (make-world (world-mushroom-field WORLD0)
                                        (world-swarm WORLD0)
                                        (world-shooter WORLD0)
                                        (world-bullet WORLD0)
                                        5)))))


;; draw-world : World -> Image
;; draw-world takes in a world and produces an image
(define (draw-world w)
  (cond [(won-game? w) (winner+image (list-size (world-mushroom-field w)) BG)]
        [(lost-game? w) (loser+image BG)]
        [else (shooter+image (world-shooter w)
                             (bullet+image (world-bullet w)
                                           (swarm+image (world-swarm w)
                                                        (mushroom-field+image (world-mushroom-field w) BG))))]))

;; Examples
(check-expect (draw-world WORLD0) (shooter+image (world-shooter WORLD0)
                                                 (bullet+image (world-bullet WORLD0)
                                                               (swarm+image (world-swarm WORLD0)
                                                                            (mushroom-field+image (world-mushroom-field WORLD0) BG)))))
(check-expect (draw-world (make-world
                           (world-mushroom-field WORLD0)
                           empty
                           (world-shooter WORLD0)
                           (world-bullet WORLD0)
                           0))
              (winner+image 30 BG))
(check-expect (draw-world (make-world
                           (world-mushroom-field WORLD0)
                           (list (make-centipede 'r (list (make-posn 12 0)) true))
                           (world-shooter WORLD0)
                           (world-bullet WORLD0)
                           0))
              (loser+image BG))

;; game-over? : World -> Boolean
;; game-over? determines if the game should stop
(define (game-over? w)
  (or (won-game? w) (lost-game? w)))

;; Examples
(check-expect (game-over? (make-world
                           (world-mushroom-field WORLD0)
                           empty
                           (world-shooter WORLD0)
                           (world-bullet WORLD0)
                           0))
              true)
(check-expect (game-over? (make-world
                           (world-mushroom-field WORLD0)
                           (world-swarm WORLD0)
                           (world-shooter WORLD0)
                           (world-bullet WORLD0)
                           0))
              false)

;;main : Number Number Number -> Game
;;main creates a Centipede(c) game with a centipede of the size of the first number, and the second number of mushrooms, at the third number fps
(define (main cent-length mush-num fps)
  (big-bang (make-world (add-mushrooms empty mush-num) 
                        (list (add-centipede cent-length (list (make-posn 0 39)))) 
                        (make-shooter (make-posn (floor (/ GRID-WIDTH 2)) 0) 'waiting)
                        (make-bullet (make-posn (floor (/ GRID-WIDTH 2)) 0) false) 0) 
            (on-tick world->world (/ 1 fps))
            (to-draw draw-world)
            (on-key press)
            (on-release release)
            (stop-when game-over?)))
