#!r6rs

(library
 (card-instant)
 (export card-instant)
 (import (rnrs base (6))
         (magic object)
         (magic cards card-stackable))

 ;Class: card-instant
 (define (card-instant name color cost game player picture . this-a)
   
   (define (can-play?)
     #t)
   
   (define (supports-type? type)
     (or (eq? type card-instant) (super 'supports-type? type)))
   (define (get-type)
     card-instant)
   
;   (define (cast)
 ;    (
   
   (define (obj-card-instant msg . args)
     (case msg
       ((can-play?) (apply can-play? args))
       ((supports-type?) (apply supports-type? args))
       ((get-type) (apply get-type args))
       (else (apply super msg args))))

   (define this (extract-this obj-card-instant this-a))
   (define super (card-stackable name color cost game player picture this))

   obj-card-instant)
 
)