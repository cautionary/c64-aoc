;============================================================
; Subtract a 16-bit number from a 16-but number
; `minuend` - `subtrahend` = `difference`
;============================================================

sub_16_16       sec                 ;set the carry bit for upcoming subtraction
                lda minuend      ;low byte of our higher number for subtraction
                sbc subtrahend      ;subtract the low byte of our lower number
                sta difference    ;store it in the low byte of our result
                lda minuend+1    ;high byte of our higher number for subtraction
                sbc subtrahend+1    ;subtract the high byte of our lower number
                sta difference+1  ;store it in the high byte of our result
                rts
