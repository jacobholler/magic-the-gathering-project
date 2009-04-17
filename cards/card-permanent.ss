#!r6rs

(library
 (card-permanent)
 (export card-permanent)
 (import (rnrs base (6))
         (magic object)
         (magic cards card))

 ;Class: card-permanent
 (define (card-permanent name color cost game player picture . this-a)
   
   (define (play)
     #f)
   (define (destroy)
     #f)
   (define (turn-begin)
     #f)
   (define (phase-begin)
     #f)
   (define (phase-end)
     #f)
   (define (turn-end)
     #f)
   
   (define (supports-type? type)
     (or (eq? type card-permanent) (super 'supports-type? type)))
   (define (get-type)
     card-permanent)
   
   (define (can-play?)
     (eq? ((game 'get-phases) 'get-current-type) 'main-phase)
     (eq? (game 'get-active-player) player))
   
   (define (obj-card-permanent msg . args)
     (case msg
       ((play) (apply play args))
       ((destroy) (apply destroy args))
       ((turn-begin) (apply turn-begin args))
       ((phase-begin) (apply phase-begin args))
       ((phase-end) (apply phase-end args))
       ((turn-end) (apply turn-end args))
       ((can-play?) (apply can-play? args))
       ((supports-type?) (apply supports-type? args))
       ((get-type) (apply get-type args))
       (else (apply super msg args))))
   
   (define this (extract-this obj-card-permanent this-a))
   (define super (card name color cost game player picture this))

   obj-card-permanent)
)