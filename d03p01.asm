;============================================================
;    specify output file
;============================================================

!cpu 6502
!to "build/d03p01.prg",cbm    ; output file


;============================================================
; BASIC loader
;============================================================

!source "inc/basic-boot.asm"

* = $c000     				            ; start address for 6502 code

d03p01          jsr clear_screen
                jsr init_test
                lda tree_count
                sta num_hex
                lda tree_count+1
                sta num_hex+1
                jsr h2d_16
                lda num_dec
                sta answer
                lda num_dec+1
                sta answer+1
                lda num_dec+2
                sta answer+2
                jsr rev_prnt_bytes
forever         jmp forever

cur_char_pos    = $FB          ;zeropage memory address for the current character we want to look at

tree_count      !word $0000         ;every time we find a tree (# char), increment this value
num_hex         !word $0000         
num_dec         !byte 00, 00, 00
answer          !byte 00, 00, 00
answer_length   !byte $03

;importing our reverse and print bytes routine
;   gives us the routine `rev_prnt_bytes` which expects the labels `answer` and `answer_length`
!source "inc/reverse-and-print-bytes.asm"

;importing our hex to dec conversion routine
;   gives us the routine `h2d_16` which converts `num_hex` to `num_dec`
!source "inc/hex-to-dec-16.asm"


;importing our clear screen routine called `clear_screen`
!source "inc/clear-screen.asm"

;we need to start at the first byte and move 3 bytes right and one byte down in each step
;   each row is 31 dec / 1F hex bytes
;   when we reach the end of the row we flip back to the beginning
;   when we get pas the last row, we are done
;   our input is starting at $1000 and we have $271D bytes or 323 rows ($143 hex rows) 
;   so if we get to $371D, we are done
init_test       ldy #$00            ;the y register is going to keep track of which char position in each row we are on
                lda #$00            ;populate our zeropage address with $1000 so that we can use it as a pointer
                sta cur_char_pos    ;low byte of our pointer
                lda #$10
                sta cur_char_pos+1  ;high byte of our pointer
inc_row         clc                  
                lda cur_char_pos    ;there are 31-dec/$1F-hex bytes in each row, so we add $1F to get to the start of the next row
                adc #$1F           
                sta cur_char_pos    
                lda cur_char_pos+1  ;we added $1F to the low byte, so next ad $00 to the high byte with the carry
                adc #$00
                sta cur_char_pos+1
inc_col_3       tya                 ;y register stores our column position, so adding 3 to get the next value we want
                adc #$03
                cmp #$1F
                bcc get_char
                sec
                sbc #$1F
get_char        tay
                lda (cur_char_pos),y
                cmp #$23            ;check if is PETSCII '#'
                bne check_done      ;if not move on to the next character
                clc                 ;    if it is, increment tree count
                lda tree_count
                adc #$01
                sta tree_count
                lda tree_count+1
                adc #$00
                sta tree_count+1
check_done      lda cur_char_pos+1  ;check if our high byte has reached to the $37th memory page
                cmp #$37            
                bne inc_row         ;if not, move on to our next character
                lda cur_char_pos    ;   if it is, we are done at $371D
                cmp #$1D
                bne inc_row
                rts

;store our input in a separate file
* = $1000
!source "input-d03.asm"
