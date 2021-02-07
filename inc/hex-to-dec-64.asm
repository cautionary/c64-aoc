;============================================================
;   converts a 64-bit hex value to a decimal representation
;       in 10 bytes.
;   uses memory labels `num_hex` for the input and `num_dec` 
;       for the output
;============================================================
h2d_64      sed         ; Switch to decimal mode
            lda #$00      ; Ensure the result is clear
            sta num_dec+0
            sta num_dec+1
            sta num_dec+2
            sta num_dec+3
            sta num_dec+4
            sta num_dec+5
            sta num_dec+6
            sta num_dec+7
            sta num_dec+8
            sta num_dec+9
            ldx #$40     ; The number of source bits
                                           
cnvbit      asl num_hex+0   ; Shift out one bit
            rol num_hex+1
            rol num_hex+2
            rol num_hex+3
            rol num_hex+4
            rol num_hex+5
            rol num_hex+6
            rol num_hex+7
            lda num_dec+0   ; And add into result
            adc num_dec+0
            sta num_dec+0
            lda num_dec+1   ; propagating any carry
            adc num_dec+1
            sta num_dec+1
            lda num_dec+2   ; ... thru whole result
            adc num_dec+2
            sta num_dec+2
            lda num_dec+3
            adc num_dec+3
            sta num_dec+3
            lda num_dec+4
            adc num_dec+4
            sta num_dec+4
            lda num_dec+5
            adc num_dec+5
            sta num_dec+5
            lda num_dec+6
            adc num_dec+6
            sta num_dec+6
            lda num_dec+7
            adc num_dec+7
            sta num_dec+7
            lda num_dec+8
            adc num_dec+8
            sta num_dec+8
            lda num_dec+9
            adc num_dec+9
            sta num_dec+9
            dex         ; And repeat for next bit
            bne cnvbit
            cld         ; Back to binary
            rts         ; All Done.


