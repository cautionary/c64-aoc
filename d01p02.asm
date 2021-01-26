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
                jsr print_answer
forever         jmp forever


subtr_num1      !byte $00, $00              ;high number for subtraction problems
subtr_num2      !byte $00, $00              ;low number for subtraction problem
subtr_result    !byte $00, $00              ;result of subtraction problem
answer_prod     !byte $00, $00, $00, $00    ;result of multiplying subtr_num2 and subtr_result
test_num_1      !byte $00, $00              ;since part 2 requires adding three numbers together
test_num_2      !byte $00, $00              ;   we'll need to use subtr_num1, etc. multiple times, so we'll
test_num_3      !byte $00, $00              ;   store the numbers under test in these memory locations
current_z       !byte $00                   ;we are in the z loop the longest, so we'll offload that to memory while doing y and z
x_loop          !byte $00                   ;since we have more than 256 bytes of input data need to keep track \
y_loop          !byte $00                   ;  of which block of input we are in for both x and y. these should only be 0 or 1
z_loop          !byte $00
multiplier      !byte $00, $00
multiplicand    !byte $00, $00, $00, $00
product         !byte $00, $00, $00, $00, $00, $00

clear_screen    lda #$20     ; #$20 is the spacebar screencode
                sta $0400,x  ; fill four areas with 256 spacebar characters
                sta $0500,x 
                sta $0600,x 
                ;sta $06e8,x 
                inx         
                bne clear_screen
                rts 

;subtract one 2 byte number from another 2 byte number
sub_16b         sec                 ;set the carry bit for upcoming subtraction
                lda subtr_num1      ;low byte of our higher number for subtraction
                sbc subtr_num2      ;subtract the low byte of our lower number
                sta subtr_result    ;store it in the low byte of our result
                lda subtr_num1+1    ;high byte of our higher number for subtraction
                sbc subtr_num2+1    ;subtract the high byte of our lower number
                sta subtr_result+1  ;store it in the high byte of our result
                rts

; set 2020 as the high number for our subtraction
test_init       ldx #$00
                ldy #$00
test_loop       lda #$E4
                sta subtr_num1      ;low byte of the higher number to be used in sub_16b later
                lda #$07
                sta subtr_num1+1    ;high byte of the higher number to be used in sub_16b later
                ;2020 dec = 7E4 hex. E4 07
                ldx current_z
                lda z_loop
                sta x_loop
                cmp #$01
                beq second_z
                lda input,x
                sta subtr_num2
                sta test_num_1
                inx
                lda input,x
                jmp z_loaded
second_z        lda input2,x
                sta subtr_num2
                sta test_num_1
                inx
                lda input2,x
z_loaded        sta subtr_num2+1
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
sub_from_2020   jsr sub_16b
                lda subtr_result
                sta subtr_num1
                lda subtr_result+1
                sta subtr_num1+1
; cycle through input numbers and subtract from 2020
test_nums       lda x_loop          ;check if we are
                cmp #$01            ;   in the first or
                beq second_x        ;   second chunk of input
first_x         lda input,x         ;load the number from input and
                sta subtr_num2      ;   and use it as the lower number
                sta test_num_2
                inx                 ;   in our subtraction list
                lda input,x
                jmp x_loaded
second_x        lda input2,x   
                sta subtr_num2
                sta test_num_2
                inx
                lda input2,x
x_loaded        sta subtr_num2+1
                sta test_num_2+1
                jsr sub_16b         ;now that the numbers are loaded, jump to the subtraction routine
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
                cmp subtr_result    ;then we compare them to the result of our subtraction problem
                bne no_match        ;   where we took 2020 - x
                lda input,y
                jmp y_loaded
second_y        lda input2,y
                sta test_num_3
                iny
                cmp subtr_result
                bne no_match
                lda input2,y
                sta test_num_3+1
y_loaded        cmp subtr_result+1
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
                jsr do_mult         ;calling in the multiplication routine
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
                jsr do_mult         ;call the multiplication routine and we are done
                rts
                
do_mult         lda #$00            ;after we find our values that add up to 2020
                sta product         ;   this routine multiplies them together
                sta product+1       ;   and stores the result in a 6 byte area called product
                sta product+2       ;first, zero out the product since we run this multiple times
                sta product+3
                sta product+4
                sta product+5
                ldx #$20            ;setting x to 32-dec since we have a 32-bit multiplicand 
l1              lsr multiplicand+3
                ror multiplicand+2
                ror multiplicand+1
                ror multiplicand    ;shift the entire multiplicand one to the right and 
                bcc l2              ;   check if the lowest bit is 1. if so we need to add in the multiplier
                tay                 ;a contains the high byte of our product, dump it in y temporarily
                clc
                lda multiplier      ;load the low byte of the multiplier 
                adc product+4       ;   and add it to the second highest byte of the product
                sta product+4    
                tya                 ;get our high byte of our product back from y
                adc multiplier+1    ;add in the high byte of the multiplier
l2              ror                 ;rotate the product down the chain
                ror product+4
                ror product+3
                ror product+2
                ror product+1
                ror product
                dex                 ;decrement x and when we are done with all 32 bits we are done
                bne l1
                sta product+5       ;store that high byte of our product once we're all done
                rts


print_answer    ldx #$05            ;takes the value from answer_prod
                ldy #$00            ;   splits each byte into two nibbles 
loop_text       lda product,x   ;   converts those to their petscii value
                and #$F0            
                lsr
                lsr
                lsr
                lsr
                jsr prep_char
                sta $0630,y         ; ...and store in screen ram near the center
                iny
                lda product,x
                and #$0F
                jsr prep_char
                sta $0630,y
                iny
                lda #$20
                sta $0630,y
                iny
                dex
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

;store our input in a separate file
;day 1 part 2 uses the same input as part 1
!source "input-d01p01.asm"
