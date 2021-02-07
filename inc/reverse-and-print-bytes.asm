;============================================================
; Takes the starting address `answer` and 
;   prints two bytes' hex values in reverse order
;============================================================

rev_prnt_bytes  ldx answer_length   ;takes the value from answer
                dex                 
                ldy #$00            ;   splits each byte into two nibbles 
loop_text       lda answer,x        ;   converts those to their petscii value
                and #$F0            
                lsr
                lsr
                lsr
                lsr
                jsr prep_char
                sta $0630,y         ; ...and store in screen ram near the center
                iny
next_nibble     lda answer,x
                and #$0F
                jsr prep_char
                sta $0630,y
                iny
next_byte       dex
                cpx #$FF
                bne loop_text       ; loop if we are not done yet
                rts

prep_char       cmp #$0A            ;check if the value is greater or equal than $0A
                bcs prep_let
prep_num        clc
                adc #$30            ;if less then 0A, then add 30 to get to petscii for 0-9
                rts
prep_let        sec                 ;if greater or equal then subtract 9 to get down to petscii for A-F
                sbc #$09
                rts
