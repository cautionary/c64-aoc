;============================================================
;    specify output file
;============================================================

!cpu 6502
!to "build/d01p01.prg",cbm    ; output file

;============================================================
; BASIC loader
;============================================================

!source "inc/basic-boot.asm"

* = $c000     				            ; start address for 6502 code

d01p01          jsr clear_screen
                jsr test_init
                lda subtrahend
                sta multiplier
                lda subtrahend+1
                sta multiplier+1
                lda difference
                sta multiplicand
                lda difference+1
                sta multiplicand+1
                jsr mult_16_16
                lda product
                sta answer
                lda product+1
                sta answer+1
                lda product+2
                sta answer+2
                lda product+3
                sta answer+3
                jsr rev_prnt_bytes
forever         jmp forever

minuend         !byte $00, $00              ;high number for subtraction problem which we will set to 2020 for this problem
subtrahend      !byte $00, $00              ;low number for subtraction problem
difference      !byte $00, $00              ;result of subtraction problem
x_loop          !byte $00                   ;since we have more than 256 bytes of input data need to keep track \
y_loop          !byte $00                   ;  of which block of input we are in for both x and y. these should only be 0 or 1
multiplier      !word $0000
multiplicand    !word $0000
product         !byte $00, $00, $00, $00
answer          !byte $00, $00, $00, $00
answer_length   !byte $04

;importing our reverse and print bytes routine
;   gives us the routine `rev_prnt_bytes` which expects the labels `answer` and `answer_length`

!source "inc/reverse-and-print-bytes.asm"

;importing our clear screen routine called `clear_screen`
!source "inc/clear-screen.asm"

;importing multiplication routine
;routine called `mult_16_16`
;multiplies `multiplier` by `multiplicand` and stores in `product`
!source "inc/mult-16-16.asm"

;subtract one 2 byte number from another 2 byte number
;gives us the `sub_16_16` routine
!source "inc/subtr-16-16.asm"

; set 2020 as the high number for our subtraction
test_init       ldx #$00
                ldy #$00
                lda #$E4
                sta minuend      ;low byte of the higher number to be used in sub_16_16 later
                lda #$07
                sta minuend+1    ;high byte of the higher number to be used in sub_16_16 later
                ;2020 dec = 7E4 hex. E4 07
; cycle through input numbers and subtract from 2020
test_nums       lda x_loop          ;check if we are
                cmp #$01            ;   in the first or
                beq second_x        ;   second chunk of input
first_x         lda input,x         ;load the number from input and
                sta subtrahend      ;   and use it as the lower number
                inx                 ;   in our subtraction list
                lda input,x
                jmp x_loaded
second_x        lda input2,x   
                sta subtrahend
                inx
                lda input2,x
x_loaded        sta subtrahend+1
                jsr sub_16_16         ;now that the numbers are loaded, jump to the subtraction routine
                inx                 ;move on to the next input byte for later
                ; set y to x + 2 so we aren't comparing a num to itself or repeating previous pairs
                txa
                clc
                adc #$02            ;using clc and adc in case we are crossing the 255 barrier
                tay
                lda x_loop          ;if xloop is 0, but adding 2 to the x reg rolls us over, then 
                adc #$00            ;   y is in next loop
                sta y_loop          ;   otherwise y is in the same loop as x
;compare both bytes of numbers
cmp_snd_nums    lda y_loop          ;start of the loop for the second number
                cmp #$01            ;similar to x values, we check if we need to pull from input
                beq second_y        ;   or input2 and load them into the a register
first_y         lda input,y         
                iny
                cmp difference    ;then we compare them to the result of our subtraction problem
                bne no_match        ;   where we took 2020 - x
                lda input,y
                jmp y_loaded
second_y        lda input2,y
                iny
                cmp difference
                bne no_match
                lda input2,y
y_loaded        cmp difference+1
                beq match           ;if we match here we are done and have found the answer!
no_match        iny                 ;otherwise, we move on to the next y
                cpy #$FE            ;check if we have reached the end of the first input
                beq inc_y_loop
                cpy #$92            ;check if we are at the end of the second input
                bne cmp_snd_nums
                lda y_loop
                cmp #$01            ;if we are at y=$92 and yloop=1 then move into the next x
                bne cmp_snd_nums    
next_x          cpx #$FE            ;and then do the same checks for x
                beq inc_x_loop
                cpx #$92
                bne test_nums
                lda x_loop
                cmp #$01
                bne test_nums
match           rts                 
                
inc_y_loop      lda #$01            ;sets the y_loop to 1 so we start checking input2
                sta y_loop
                jmp cmp_snd_nums

inc_x_loop      lda #$01            ;sets x_loop to 1 so we start checking input2
                sta x_loop
                jmp test_nums


;store our input in a separate file
!source "input-d01.asm"
