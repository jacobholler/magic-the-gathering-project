#!r6rs

(library
 (card-tappable)
 (export card-tappable)
 (import (rnrs base (6))
         (magic object)
         (magic cards card-permanent))

 (define (card-tappable name color cost game player picture . this-a)
   (define tapped #f)
   
   (define (tapped?)
     tapped)
   (define (tap!)
     (set! tapped #t)
     (game 'update-all-guis))
   (define (untap!)
     (set! tapped #f)
     (game 'update-all-guis))
   
   (define (supports-type? type)
     (or (eq? type card-tappable) (super 'supports-type? type)))
   (define (get-type)
     card-tappable)
   
   (define (obj-card-tappable msg . args)
     (case msg
       ((tapped?) (apply tapped? args))
       ((tap!) (apply tap! args))
       ((untap!) (apply untap! args))
       ((supports-type?) (apply supports-type? args))
       ((get-type) (apply get-type args))
       (else (apply super msg args))))
   
   (define this (extract-this obj-card-tappable this-a))
   (define super (card-permanent name color cost game player picture this))
   
   obj-card-tappable)

 )