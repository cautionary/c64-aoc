;============================================================
;    specify output file
;============================================================

!cpu 6502
!to "build/d02p01.prg",cbm    ; output file


;============================================================
; BASIC loader
;============================================================

!source "inc/basic-boot.asm"

* = $c000     				            ; start address for 6502 code

d02p01          jsr clear_screen
                jsr init_test
                lda valid_count
                sta answer
                lda valid_count+1
                sta answer+1
                jsr rev_prnt_bytes
forever         jmp forever

cur_char_pos    = $FB          ;zeropage memory address for the current character we want to look at

valid_count     !word $0000         ;every time we find a valid password, increment this value
range_first     !byte $00           ;first number of the current rule's range
range_second    !byte $00           ;second number of the current rule's range
target_letter   !byte $00
letter_count    !byte $00
answer          !word $0000         ;we'll move the answer here and it is used by the rev_pr_bt_2 routine
answer_length   !byte $02

;importing our reverse and print bytes routine
;   gives us the routine `rev_prnt_bytes` which expects the labels `answer` and `answer_length`

!source "inc/reverse-and-print-bytes.asm"

;importing our clear screen routine called `clear_screen`
!source "inc/clear-screen.asm"

init_test       lda #$00            ;populate our zeropage address with $1000 so that we can use it as a pointer
                sta cur_char_pos    ;low byte of our pointer
                lda #$10
                sta cur_char_pos+1  ;high byte of our pointer
string_loop     lda #$00
                ldy #$00
                sta letter_count
first_num       lda (cur_char_pos),y
                tax
                iny
                lda (cur_char_pos),y
                cmp #$2D            ;check if char is PETSCII '-'
                beq stor_rang_1
                clc
add_tens_1      adc #$0A            ;if the character isn't a '-' then we just add 10 to the second digit
                dex                 ;count down for digit in the 10s place
                cpx #$30            ;since we have a PETSCII value, not a true number we count down to PETSCII 0 which is $30
                bne add_tens_1
                tax
                iny                 ;since there can only be 2 digit numbers, we know the next char is a '-' so skip it
stor_rang_1     txa
                sec
                sbc #$30            ;the byte stores the numbers PETSCII value, not the actual number, so need to subtract $30
                sta range_first
second_num      iny                 ;same process as before, but getting the high boundary of our range
                lda (cur_char_pos),y
                tax
                iny
                lda (cur_char_pos),y
                cmp #$20            ;PETSCII ' ' space
                beq stor_rang_2
                clc
add_tens_2      adc #$0A
                dex
                cpx #$30
                bne add_tens_2
                tax
                iny
stor_rang_2     txa
                sec
                sbc #$30
                sta range_second
targ_lett       iny                 ;next we get the PETSCII value of the number we are checking for
                lda (cur_char_pos),y
                sta target_letter
                iny                 ;skipping over ':'
                iny                 ;skipping over ' '
                iny                 ;we should now be at our string of chars
char_loop       lda (cur_char_pos),y
                cmp #$21            ;we put a '!' at the end of our data, so if we get there we are done
                beq check_range
check_digit     cmp #$39            ;now we go through every letter character until we find a number and see if it is our target letter
                beq check_range     ;if our byte is less than or equal to hex-39, then we are on to the next line
                bcc check_range
                iny
                cmp target_letter   ;if the letter we are looking at is our target letter than add one to letter count
                bne char_loop
                inc letter_count
                jmp char_loop       ;get the next character when we are done
check_range     lda letter_count    ;if our letter count is less than the lower boundary of the range, then we do not have a valid password
                cmp range_first
                bcc upd_pntr
                lda range_second    ;or if our letter count is greater than the upper boundary of the range we also do not have a valid pw
                cmp letter_count
                bcc upd_pntr        
                clc                 ;if it falls in the range, add one two our valid password count which is 2 bytes because it could be up to 1,000
                lda valid_count
                adc #$01
                sta valid_count
                lda valid_count+1
                adc #$00
                sta valid_count+1
upd_pntr        lda (cur_char_pos),y;now we take our y value and add it to our current pointer so our loop knows where the start of the next line is
                cmp #$21            ;PETSCII '!'
                beq all_done
                clc
                tya
                adc cur_char_pos
                sta cur_char_pos
                lda cur_char_pos+1
                adc #$00
                sta cur_char_pos+1
                jmp string_loop
all_done        rts

;store our input in a separate file
* = $1000
!source "input-d02.asm"
