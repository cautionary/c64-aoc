;============================================================
;    specify output file
;============================================================

!cpu 6502
!to "build/d01p02.prg",cbm    ; output file

;============================================================
; BASIC loader
;============================================================

!source "inc/basic-boot.asm"

* = $c000     				            ; start address for 6502 code

d01p01          jsr clear_screen
                jsr test_init
                jsr mult_results
                lda product
                sta num_hex
                lda product+1
                sta num_hex+1
                lda product+2
                sta num_hex+2
                lda product+3
                sta num_hex+3
                lda product+4
                sta num_hex+4
                lda product+5
                sta num_hex+5
                jsr h2d_48
                lda num_dec
                sta answer
                lda num_dec+1
                sta answer+1
                lda num_dec+2
                sta answer+2
                lda num_dec+3
                sta answer+3
                lda num_dec+4
                sta answer+4
                lda num_dec+5
                sta answer+5
                lda num_dec+6
                sta answer+6
                lda num_dec+7
                sta answer+7
                jsr rev_prnt_bytes
forever         jmp forever


minuend         !byte $00, $00              ;high number for subtraction problems
subtrahend      !byte $00, $00              ;low number for subtraction problem
difference      !byte $00, $00              ;result of subtraction problem
answer_prod     !byte $00, $00, $00, $00    ;result of multiplying subtrahend and difference
test_num_1      !byte $00, $00              ;since part 2 requires adding three numbers together
test_num_2      !byte $00, $00              ;   we'll need to use minuend, etc. multiple times, so we'll
test_num_3      !byte $00, $00              ;   store the numbers under test in these memory locations
current_z       !byte $00                   ;we are in the z loop the longest, so we'll offload that to memory while doing y and z
x_loop          !byte $00                   ;since we have more than 256 bytes of input data need to keep track \
y_loop          !byte $00                   ;  of which block of input we are in for both x and y. these should only be 0 or 1
z_loop          !byte $00
multiplier      !byte $00, $00
multiplicand    !byte $00, $00, $00, $00
product         !byte $00, $00, $00, $00, $00, $00
num_hex         !byte $00, $00, $00, $00, $00, $00
num_dec         !byte $00, $00, $00, $00, $00, $00, $00, $00
answer          !byte $00, $00, $00, $00, $00, $00, $00, $00
answer_length   !byte $08

;importing our reverse and print bytes routine
;   gives us the routine `rev_prnt_bytes` which expects the labels `answer` and `answer_length`

!source "inc/reverse-and-print-bytes.asm"

;importing our clear screen routine called `clear_screen`
!source "inc/clear-screen.asm"

;importing our clear screen routine called `mult_16_32`
;`multiplier` * `multiplicard` = `product`
!source "inc/mult-16-32.asm"

;subtract one 2 byte number from another 2 byte number
;gives us the `sub_16_16` routine
!source "inc/subtr-16-16.asm"

;convert a 48-bit hex number into a decimal number 6 bytes -> 8 bytes
;routine: `h2d_48` input: `num_hex` output: `num_dec`
!source "inc/hex-to-dec-48.asm"

; set 2020 as the high number for our subtraction
test_init       ldx #$00
                ldy #$00
test_loop       lda #$E4
                sta minuend      ;low byte of the higher number to be used in sub_16_16 later
                lda #$07
                sta minuend+1    ;high byte of the higher number to be used in sub_16_16 later
                ;2020 dec = 7E4 hex. E4 07
                ldx current_z
                lda z_loop
                sta x_loop
                cmp #$01
                beq second_z
                lda input,x
                sta subtrahend
                sta test_num_1
                inx
                lda input,x
                jmp z_loaded
second_z        lda input2,x
                sta subtrahend
                sta test_num_1
                inx
                lda input2,x
z_loaded        sta subtrahend+1
                sta test_num_1+1
                inx
                stx current_z
                cpx #$FE
                bne sub_from_2020
                lda #$01
                sta z_loop
                sta x_loop
                lda #$00
                sta current_z
                ldx #$02
sub_from_2020   jsr sub_16_16
                lda difference
                sta minuend
                lda difference+1
                sta minuend+1
; cycle through input numbers and subtract from 2020
test_nums       lda x_loop          ;check if we are
                cmp #$01            ;   in the first or
                beq second_x        ;   second chunk of input
first_x         lda input,x         ;load the number from input and
                sta subtrahend      ;   and use it as the lower number
                sta test_num_2
                inx                 ;   in our subtraction list
                lda input,x
                jmp x_loaded
second_x        lda input2,x   
                sta subtrahend
                sta test_num_2
                inx
                lda input2,x
x_loaded        sta subtrahend+1
                sta test_num_2+1
                jsr sub_16_16         ;now that the numbers are loaded, jump to the subtraction routine
                bcc inc_then_next_x ;if carry is clear, our subtraction is less than 0 and there is no way this x can work
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
                sta test_num_3
                iny
                cmp difference    ;then we compare them to the result of our subtraction problem
                bne no_match        ;   where we took 2020 - x
                lda input,y
                jmp y_loaded
second_y        lda input2,y
                sta test_num_3
                iny
                cmp difference
                bne no_match
                lda input2,y
                sta test_num_3+1
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
                bne next_x_loop     ;our test_nums loop is too far away, so branching to next_x_loop then jumping to test_nums
                lda x_loop
                cmp #$01
                bne next_x_loop
next_z_loop     jmp test_loop
match           rts                 

inc_then_next_x inx
                jmp next_x        

next_x_loop     jmp test_nums

inc_y_loop      lda #$01            ;sets the y_loop to 1 so we start checking input2
                sta y_loop
                jmp cmp_snd_nums

inc_x_loop      lda #$01            ;sets x_loop to 1 so we start checking input2
                sta x_loop
                jmp test_nums

mult_results    lda test_num_1      ;after we have our result, we'll multiply them together in two operations
                sta multiplier      ;first we'll take test_num_1 and store it in multiplier
                lda test_num_1+1
                sta multiplier+1
                lda test_num_2      ;and take test_num_2 and store it in multiplicand
                sta multiplicand
                lda test_num_2+1
                sta multiplicand+1  
                lda #$00            ;but since test_num_2 is 16 bit and our multiplication routine takes a 32-bit
                sta multiplicand+2  ;   number as a multiplicand, so padding it with two extra zero bytes
                sta multiplicand+3
                jsr mult_16_32      ;calling in the multiplication routine
                lda product         ;now that multiplication is done, product contains the result
                sta multiplicand    ;   of multiplying test_num_1 and test_num_2
                lda product+1       ;   so now we multiply the product of that with test_num_3
                sta multiplicand+1  ;   setting product as multiplicand because it is 32-bit
                lda product+2
                sta multiplicand+2
                lda product+3
                sta multiplicand+3
                lda test_num_3      ;   setting test_num_3 as multiplier because it is 16-bit
                sta multiplier
                lda test_num_3+1
                sta multiplier+1
                jsr mult_16_32      ;call the multiplication routine and we are done 
                rts
                

;store our input in a separate file
;day 1 part 2 uses the same input as part 1
!source "input-d01.asm"
