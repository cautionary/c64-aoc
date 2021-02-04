;============================================================
;    specify output file
;============================================================

!cpu 6502
!to "build/d03p02.prg",cbm    ; output file


;============================================================
; BASIC loader
;============================================================

!source "inc/basic-boot.asm"

* = $c000     				            ; start address for 6502 code

;part 2 requires checking different slopes and then multiplying the answers
;   right 1, down 1
;   right 3, down 1
;   right 5, down 1
;   right 7, down 1
;   right 1, down 2

d03p02          jsr clear_screen
r1d1            lda #$01                ;we'll run our test with each combination and store them in their own words in memory
                sta num_right           ;first right 1 down 1
                lda #$1F                ;there are 31-dec/$1F-hex characters in each row, so to go down one, we add $1F
                sta num_down
                jsr init_test
                lda tree_count
                sta result_r1d1
                lda tree_count+1
                sta result_r1d1+1

r3d1            lda #$03                ;next right 3, down 1 and then so on and so on
                sta num_right
                lda #$1F
                sta num_down
                jsr init_test
                lda tree_count
                sta result_r3d1
                lda tree_count+1
                sta result_r3d1+1

r5d1            lda #$05
                sta num_right
                lda #$1F
                sta num_down
                jsr init_test
                lda tree_count
                sta result_r5d1
                lda tree_count+1
                sta result_r5d1+1

r7d1            lda #$07
                sta num_right
                lda #$1F
                sta num_down
                jsr init_test
                lda tree_count
                sta result_r7d1
                lda tree_count+1
                sta result_r7d1+1

r1d2            lda #$01
                sta num_right
                lda #$3E            ;down 2 is actually forward $3E
                sta num_down
                jsr init_test
                lda tree_count
                sta result_r1d2
                lda tree_count+1
                sta result_r1d2+1

mult_results    lda result_r1d1     ;loading result from right 1 down 1 as multiplier
                sta multiplier
                lda result_r1d1+1
                sta multiplier+1
                lda result_r3d1     ;and loading right 3 down 1 result as multiplicand
                sta multiplicand
                lda result_r3d1+1
                sta multiplicand+1
                lda #$00
                sta multiplicand+2  ;since we can multiply by a 48-bit multiplicand, filling the rest with 00s
                sta multiplicand+3
                sta multiplicand+4
                sta multiplicand+5
                jsr mult_16_48      ;calling a 16-bit * 48-bit multiplication routine

                lda product         ;loading the product from the previous multiplication as the multiplicand
                sta multiplicand
                lda product+1
                sta multiplicand+1
                lda product+2
                sta multiplicand+2
                lda product+3
                sta multiplicand+3
                lda product+4
                sta multiplicand+4
                lda product+5
                sta multiplicand+5
                lda result_r5d1     ;loading the 3rd result as the multiplier
                sta multiplier
                lda result_r5d1+1
                sta multiplier+1
                jsr mult_16_48

                lda product         ;previous product multiplied by the 4th result
                sta multiplicand
                lda product+1
                sta multiplicand+1
                lda product+2
                sta multiplicand+2
                lda product+3
                sta multiplicand+3
                lda product+4
                sta multiplicand+4
                lda product+5
                sta multiplicand+5
                lda result_r7d1
                sta multiplier
                lda result_r7d1+1
                sta multiplier+1
                jsr mult_16_48

                lda product         ;previous product multiplied by the 5th result
                sta multiplicand
                lda product+1
                sta multiplicand+1
                lda product+2
                sta multiplicand+2
                lda product+3
                sta multiplicand+3
                lda product+4
                sta multiplicand+4
                lda product+5
                sta multiplicand+5
                lda result_r1d2
                sta multiplier
                lda result_r1d2+1
                sta multiplier+1
                jsr mult_16_48

                lda product         ;load that final product into the answer memory space
                sta answer
                lda product+1
                sta answer+1
                lda product+2
                sta answer+2
                lda product+3
                sta answer+3
                lda product+4
                sta answer+4
                lda product+5
                sta answer+5
                lda product+6
                sta answer+6
                lda product+7
                sta answer+7

                jsr rev_prnt_bytes  ;call routine to print the answer
forever         jmp forever

cur_char_pos    = $FB          ;zeropage memory address for the current character we want to look at

tree_count      !word $0000         ;every time we find a tree (# char), increment this value
answer          !byte $00, $00, $00, $00, $00, $00, $00, $00
answer_length   !byte $08
num_right       !byte $00           ;since part 2 requries multiple combos of traversal, we'll store them here
num_down        !byte $00           ;   instead of hardcoding them. this value will need to be multiples of 1F
result_r1d1     !word $0000         ;storing each result separately
result_r3d1     !word $0000
result_r5d1     !word $0000
result_r7d1     !word $0000
result_r1d2     !word $0000
multiplier      !byte $00, $00
multiplicand    !byte $00, $00, $00, $00, $00, $00
product         !byte $00, $00, $00, $00, $00, $00, $00, $00

;importing our reverse and print bytes routine
;   gives us the routine `rev_prnt_bytes` which expects the labels `answer` and `answer_length`

!source "inc/reverse-and-print-bytes.asm"

;importing our clear screen routine called `clear_screen`
!source "inc/clear-screen.asm"

;importing our multiplication routine called `mult_16_32`
!source "inc/mult-16-48.asm"

;we need to start at the first byte and move 3 bytes right and one byte down in each step
;   each row is 31 dec / 1F hex bytes
;   when we reach the end of the row we flip back to the beginning
;   when we get pas the last row, we are done
;   our input is starting at $1000 and we have $271D bytes or 323 rows ($143 hex rows) 
;   so if we get to $371D, we are done
init_test       ldy #$00            ;the y register is going to keep track of which char position in each row we are on
                lda #$00            ;populate our zeropage address with $1000 so that we can use it as a pointer
                sta tree_count
                sta tree_count+1
                sta cur_char_pos    ;low byte of our pointer
                lda #$10
                sta cur_char_pos+1  ;high byte of our pointer
inc_row         clc                  
                lda cur_char_pos    ;there are 31-dec/$1F-hex bytes in each row, so we add $1F to get to the start of the next row
                adc num_down           
                sta cur_char_pos    
                lda cur_char_pos+1  ;we added $1F to the low byte, so next ad $00 to the high byte with the carry
                adc #$00
                sta cur_char_pos+1
inc_col_3       tya                 ;y register stores our column position, so adding 3 to get the next value we want
                adc num_right
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
                lda cur_char_pos
                cmp #$1D
                beq all_done
                cmp #$3C            ;we skip right over $371D when we increment by 2 rows, so checking for $373C too
                beq all_done
                jmp inc_row
all_done        rts

;store our input in a separate file
* = $1000
!source "input-d03.asm"
