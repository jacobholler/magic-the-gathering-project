; ADT double-linked-position-list< T >
;=======================================
; Specification:
;---------------------------------------
; double-linked-position-list: ( ( T T -> boolean ) . list< T > -> double-linked-position-list< T > )
; length: ( -> number )
; full?: ( -> boolean )
; empty?: ( -> boolean )
; map: ( ( T -> T ) ( T T -> boolean ) -> double-linked-position-list< T > )
; map!: ( ( T -> T ) ( T T -> boolean ) -> {#t} )
; foldl: ( ( T T -> T ) T -> T )
; foldr: ( ( T T -> T ) T -> T )
; first-position: ( -> double-linked-position< T > )
; last-position: ( -> double-linked-position< T > )
; find: ( T -> double-linked-position< T > )
; delete!: ( double-linked-position< T > -> #<void> )
; add-before!: ( T . double-linked-position< T > -> #<void> )
; add-after!: ( T . double-linked-position< T > -> #<void> )
; next: ( double-linked-position< T > -> double-linked-position< T > )
; prev: ( double-linked-position< T > -> double-linked-position< T > )
; has-prev?: ( double-linked-position< T > -> boolean )
; has-next?: ( double-linked-position< T > -> boolean )
; value: ( double-linked-position< T > -> T )
; print: ( -> #<void> )
; Implements?: ( symbol -> boolean )
; (): ( -> double-linked-position< T > )

#!r6rs

(library (position-list)
         (export position-list)
         (import (rnrs base (6))
                 (rnrs io simple))
         
         (define (double-linked-position-list ==? . lst) ;lst is used if creating from scheme list
           (define (double-linked-position prev next val)
             (define (has-prev?)
               (not (null? prev)))
             (define (has-next?)
               (not (null? next)))
             (define (getprev)
               (if (has-prev?)
                   prev
                   (error 'double-linked-position "prev requested, but this position has no previous")))
             (define (getnext)
               (if (has-next?)
                   next
                   (error 'double-linked-position "next requested, but this position has no next")))
             (define (getvalue)
               val)
             (define (prev! x)
               (set! prev x))
             (define (next! x)
               (set! next x))
             (define (value! x)
               (set! val x))
             (define (obj-d-l-position msg . args)
               (case msg
                 ((has-prev?) (apply has-prev? args))
                 ((has-next?) (apply has-next? args))
                 ((prev) (apply getprev args))
                 ((next) (apply getnext args))
                 ((value) (apply getvalue args))
                 ((prev!) (apply prev! args))
                 ((next!) (apply next! args))
                 ((value!) (apply value! args))
                 ((print) (display "[")
                          (display prev)
                          (display ",")
                          (display val)
                          (display ",")
                          (display next)
                          (display "]"))
                 (else (error 'double-linked-position "message not understood" (car msg)))))
             obj-d-l-position)
           
           (define first '())
           (define last '())
           (define size 0)
           
           ; Helper functions
           
           (define (cleanup-list)
             (set! first '())
             (set! last '())
             (set! size 0))
           (define (detach-first pos)
             (let ((next (pos 'next)))
               (next 'prev! '())
               (set! first next))
             (set! size (- size 1)))
           (define (detach-last pos)
             (let ((prev (pos 'prev)))
               (prev 'next! '())
               (set! last prev))
             (set! size (- size 1)))
           (define (detach-middle pos)
             (let ((next (pos 'next))
                   (prev (pos 'prev)))
               (next 'prev! prev)
               (prev 'next! next))
             (set! size (- size 1)))
           
           (define (attach-first val)
             (if (empty?)
                 (let ((newpos (double-linked-position '() '() val)))
                   (set! first newpos)
                   (set! last newpos))
                 (let ((newpos (double-linked-position '() first val)))
                   (first 'prev! newpos)
                   (set! first newpos)))
             (set! size (+ size 1)))
           
           (define (attach-before-middle val pos)
             (let* ((prev (pos 'prev))
                    (newpos (double-linked-position prev pos val)))
               (prev 'next! newpos)
               (pos 'prev! newpos))
             (set! size (+ size 1)))
           
           (define (attach-after-middle val pos)
             (let* ((next (pos 'next))
                    (newpos (double-linked-position pos next val)))
               (next 'prev! newpos)
               (pos 'next! newpos))
             (set! size (+ size 1)))
           
           (define (attach-last val)
             (if (empty?)
                 (let ((newpos (double-linked-position '() '() val)))
                   (set! first newpos)
                   (set! last newpos))
                 (let ((newpos (double-linked-position last '() val)))
                   (last 'next! newpos)
                   (set! last newpos)))
             (set! size (+ size 1)))
           
           
           ; Public functions
           
           (define (from-scheme-list lst)
             (if (not (null? lst))
                 (begin (add-after! (car lst))
                        (from-scheme-list (cdr lst)))))
           (define (length)
             size)
           (define (full?)
             #f)
           (define (empty?)
             (= (length) 0))
           (define (map func new==?)
             (let ((res (double-linked-position-list new==?)))
               (define (iter thispos)
                 (res 'add-after! (func (thispos 'value)))
                 (if (thispos 'has-next?)
                     (iter (thispos 'next))))
               (if (not (empty?))
                   (iter first))
               res))
           (define (map! func new==?)
             (define (iter thispos)
               (thispos 'value! (func (thispos 'value)))
               (if (thispos 'has-next?)
                   (iter (thispos 'next))))
             (set! ==? new==?)
             (if (not (empty?))
                 (iter first))
             #t)
           (define (for-each func)
             (define (iter thispos)
               (func (thispos 'value))
               (if (thispos 'has-next?)
                   (iter (thispos 'next))))
             (if (not (empty?))
                 (iter first))
             #t)
           (define (foldl comb zero)
             (define (iter thispos res)
               (if (thispos 'has-next?)
                   (iter (thispos 'next) (comb res (thispos 'value)))
                   (comb res (thispos 'value))))
             (if (empty?)
                 zero
                 (iter first zero)))
           (define (foldr comb zero)
             (define (iter thispos res)
               (if (thispos 'has-prev?)
                   (iter (thispos 'prev) (comb res (thispos 'value)))
                   (comb res (thispos 'value))))
             (if (empty?)
                 zero
                 (iter last zero)))
           (define (first-position)
             (if (empty?)
                 (error 'double-linked-position-list "first position requested, but list is empty!")
                 first))
           (define (last-position)
             (if (empty?)
                 (error 'double-linked-position-list "last position requested, but list is empty!")
                 last))
           (define (find value) 
             (define (iter pos)
               (cond ((==? (pos 'value) value) pos)
                     ((pos 'has-next?) (iter (pos 'next)))
                     (else #f)))
             (if (empty?)
                 #f
                 (iter first)))
           (define (delete! pos)
             (cond ((null? pos) (error 'double-linked-position-list.delete! "Cannot delete null position"))
                   ((<= size 0) (error 'double-linked-position-list.delete! "Utterly weird error occurred: delete! invoked with valid position, but list size is ~S" size))
                   (else (cond ((and (eq? pos first) (eq? pos last)) (cleanup-list))
                               ((eq? pos first) (detach-first pos))
                               ((eq? pos last) (detach-last pos))
                               (else (detach-middle pos))))))
           (define (add-before! val . pos)
             (let ((afterpos (if (null? pos)
                                 first
                                 (car pos))))
               (if (eq? afterpos first)
                   (attach-first val)
                   (attach-before-middle val afterpos))))
           (define (add-after! val . pos)
             (let ((afterpos (if (null? pos)
                                 last
                                 (car pos))))
               (if (eq? afterpos last)
                   (attach-last val)
                   (attach-after-middle val afterpos))))
           
           (define (getnext pos)
             (pos 'next))
           
           (define (getprev pos)
             (pos 'prev))
           
           (define (getval pos)
             (pos 'value))
           
           (define (gethas-next? pos)
             (pos 'has-next?))
           
           (define (gethas-prev? pos)
             (pos 'has-prev?))
           
           (define (duplicate)
             (define (iter lst pos)
               (lst 'add-after! (pos 'value))
               (if (pos 'has-next?)
                   (iter lst (pos 'next))
                   lst))
             (if (empty?)
                 (double-linked-position-list ==?)
                 (iter (double-linked-position-list ==?) first)))
           
           (define (debug-print-complete)
             (define (iter pos)
               (pos 'print)
               (display " ")
               (if (pos 'has-next?)
                   (iter (pos 'next))))
             (cond ((empty?) (display "()")
                             (newline))
                   (else (display "(")
                         (iter first)
                         (display ")"))))
           
           (define (to-scheme-list)
             (define (rec pos)
               (if (pos 'has-next?)
                   (cons (pos 'value) (rec (pos 'next)))
                   (cons (pos 'value) '())))
             (if (empty?)
                 '()
                 (rec (first-position))))
           
           (define (all-true? pred)
             (let ([predmap (map pred eq?)])
               (predmap 'foldl
                        (lambda (x y)
                          (and x y))
                        #t)))
           
           (define (all-false? pred)
             (let ([predmap (map pred eq?)])
               (not (predmap 'foldl 
                             (lambda (x y)
                               (or x y))
                             #f))))
           
           (define (obj-d-l-position-list msg . args)
             (case msg
               ((length) (apply length args))
               ((full?) (apply full? args))
               ((empty?) (apply empty? args))
               ((map) (apply map args))
               ((map!) (apply map! args))
               ((for-each) (apply for-each args))
               ((foldl) (apply foldl args))
               ((foldr) (apply foldr args))
               ((first-position) (apply first-position args))
               ((last-position) (apply last-position args))
               ((find) (apply find args))
               ((delete!) (apply delete! args))
               ((add-before!) (apply add-before! args))
               ((add-after!) (apply add-after! args))
               ((next) (apply getnext args))
               ((prev) (apply getprev args))
               ((value) (apply getval args))
               ((has-next?) (apply gethas-next? args))
               ((has-prev?) (apply gethas-prev? args))
               ((print) (apply debug-print-complete args))
               ((duplicate) (apply duplicate args))
               ((to-scheme-list) (apply to-scheme-list args))
               ((all-true?) (apply all-true? args))
               ((all-false?) (apply all-false? args))
               (else (assertion-violation 'double-linked-position-list "message not understood" msg))))

           (if (not (null? lst))
             (from-scheme-list (car lst)))
           
           obj-d-l-position-list)
         
         
         ; Makes the type of position list selectable by load
         (define position-list double-linked-position-list))