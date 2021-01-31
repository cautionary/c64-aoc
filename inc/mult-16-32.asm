;============================================================
; Multiply a 16-bit number by a 32-bit number
; 16-bit `multiplier` * 32-bit `multiplicand` = `product`
;============================================================

mult_16_32      lda #$00            ;after we find our values that add up to 2020
                sta product         ;   this routine multiplies them together
                sta product+1       ;   and stores the result in a 6 byte area called product
                sta product+2       ;first, zero out the product since we run this multiple times
                sta product+3
                sta product+4
                sta product+5
                ldx #$20            ;setting x to 32-dec since we have a 32-bit multiplicand 
l1              lsr multiplicand+3
                ror multiplicand+2
                ror multiplicand+1
                ror multiplicand    ;shift the entire multiplicand one to the right and 
                bcc l2              ;   check if the lowest bit is 1. if so we need to add in the multiplier
                tay                 ;a contains the high byte of our product, dump it in y temporarily
                clc
                lda multiplier      ;load the low byte of the multiplier 
                adc product+4       ;   and add it to the second highest byte of the product
                sta product+4    
                tya                 ;get our high byte of our product back from y
                adc multiplier+1    ;add in the high byte of the multiplier
l2              ror                 ;rotate the product down the chain
                ror product+4
                ror product+3
                ror product+2
                ror product+1
                ror product
                dex                 ;decrement x and when we are done with all 32 bits we are done
                bne l1
                sta product+5       ;store that high byte of our product once we're all done
                rts
