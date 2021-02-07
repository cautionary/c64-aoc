;============================================================
;   converts a 32-bit hex value to a decimal representation
;       in 5 bytes.
;   uses memory labels `num_hex` for the input and `num_dec` 
;       for the output
;============================================================
h2d_32      sed         ; Switch to decimal mode
            lda #$00      ; Ensure the result is clear
            sta num_dec+0
            sta num_dec+1
            sta num_dec+2
            sta num_dec+3
            sta num_dec+4
            ldx #$20     ; The number of source bits
                                           
cnvbit      asl num_hex+0   ; Shift out one bit
            rol num_hex+1
            rol num_hex+2
            rol num_hex+3
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
            dex         ; And repeat for next bit
            bne cnvbit
            cld         ; Back to binary
            rts         ; All Done.
