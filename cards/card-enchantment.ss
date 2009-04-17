#!r6rs

(library
 (card-enchantment)
 (export card-enchantment)
 (import (rnrs base (6))
         (magic object)
         (magic cards card-permanent))

 ;Class: card-enchantment
 (define (card-enchantment name color cost game player picture . this-a)
   (define (get-linked-creature)
     #f)
   
   (define (supports-type? type)
     (or (eq? type card-enchantment) (super 'supports-type? type)))
   (define (get-type)
     card-enchantment)
   
   (define (obj-card-enchantment msg . args)
     (case msg
       ((supports-type?) (apply supports-type? args))
       ((get-type) (apply get-type args))
       (else (apply super msg args))))

   (define this (extract-this obj-card-enchantment this-a))
   (define super (card-permanent name color cost game player picture this))
   
   obj-card-enchantment)

 )