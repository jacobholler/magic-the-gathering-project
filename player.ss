#!r6rs


(library
 (export player)
 (import (rnrs base (6))
         (magic mana)
         (magic fields)
 
 (define (player)
   (define my-field (player-field player))
   (define my-mana (manapool))
   (define my-view '())
   (define life 20)
   
   (define (get-life-counter)
     life)
   
   (define (set-life-counter! val)
     (set! life val))
   
   (define (check-dead)
     (<= life 0))
   
   (define (get-view)
     my-view)
   
   (define (get-manapool)
     my-mana)
   
   (define (obj-player msg . args)
     (case msg
       ((get-life-counter) (apply get-life-counter args))
       ((set-life-counter!) (apply set-life-counter! args))
       ((check-dead) (apply check-dead args))
       ((get-view) (apply get-view args))
       (else (assertion-failure 'player "message not understood" msg))))
   
   (field 'add-player-field! my-field)
   (set! my-view (player-view obj-player))
   
   obj-player)
 )

     
 