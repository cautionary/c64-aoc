;============================================================
; Multiply two 16-bit numbers together
; takes labels `multiplier` and `multiplicand` and stores 
;   the result in `product`
;============================================================

mult_16_16      lda #$00            ;
                sta product+2   ;   this routine multiplies them together
                ldx #$10            ;   and stores the result in a 4 byte area called product
l1              lsr multiplicand+1
                ror multiplicand
                bcc l2
                tay
                clc
                lda multiplier
                adc product+2
                sta product+2
                tya
                adc multiplier+1
l2              ror 
                ror product+2
                ror product+1
                ror product
                dex
                bne l1
                sta product+3
                rts
