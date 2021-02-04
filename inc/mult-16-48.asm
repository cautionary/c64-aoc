;============================================================
; Multiply a 16-bit number by a 32-bit number
; 16-bit `multiplier` * 32-bit `multiplicand` = `product`
;============================================================

mult_16_48      lda #$00            
                sta product        
                sta product+1     
                sta product+2       ;first, zero out the product since we run this multiple times
                sta product+3
                sta product+4
                sta product+5
                sta product+6
                sta product+7
                ldx #$30            ;setting x to 48-dec since we have a 48-bit multiplicand 
l1              lsr multiplicand+5
                ror multiplicand+4
                ror multiplicand+3
                ror multiplicand+2
                ror multiplicand+1
                ror multiplicand    ;shift the entire multiplicand one to the right and 
                bcc l2              ;   check if the lowest bit is 1. if so we need to add in the multiplier
                tay                 ;a contains the high byte of our product, dump it in y temporarily
                clc
                lda multiplier      ;load the low byte of the multiplier 
                adc product+6       ;   and add it to the second highest byte of the product
                sta product+6    
                tya                 ;get our high byte of our product back from y
                adc multiplier+1    ;add in the high byte of the multiplier
l2              ror                 ;rotate the product down the chain
                ror product+6
                ror product+5
                ror product+4
                ror product+3
                ror product+2
                ror product+1
                ror product
                dex                 ;decrement x and when we are done with all 32 bits we are done
                bne l1
                sta product+7       ;store that high byte of our product once we're all done
                rts
