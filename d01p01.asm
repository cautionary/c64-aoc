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
                jsr mult_results
                jsr print_answer
forever         jmp forever


subtr_num1      !byte $00, $00              ;high number for subtraction problem which we will set to 2020 for this problem
subtr_num2      !byte $00, $00              ;low number for subtraction problem
subtr_result    !byte $00, $00              ;result of subtraction problem
answer_prod     !byte $00, $00, $00, $00    ;result of multiplying subtr_num2 and subtr_result
x_loop          !byte $00                   ;since we have more than 256 bytes of input data need to keep track \
y_loop          !byte $00                   ;  of which block of input we are in for both x and y. these should only be 0 or 1


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
                lda #$E4
                sta subtr_num1      ;low byte of the higher number to be used in sub_16b later
                lda #$07
                sta subtr_num1+1    ;high byte of the higher number to be used in sub_16b later
                ;2020 dec = 7E4 hex. E4 07
; cycle through input numbers and subtract from 2020
test_nums       lda x_loop          ;check if we are
                cmp #$01            ;   in the first or
                beq second_x        ;   second chunk of input
first_x         lda input,x         ;load the number from input and
                sta subtr_num2      ;   and use it as the lower number
                inx                 ;   in our subtraction list
                lda input,x
                jmp x_loaded
second_x        lda input2,x   
                sta subtr_num2
                inx
                lda input2,x
x_loaded        sta subtr_num2+1
                jsr sub_16b         ;now that the numbers are loaded, jump to the subtraction routine
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
                cmp subtr_result    ;then we compare them to the result of our subtraction problem
                bne no_match        ;   where we took 2020 - x
                lda input,y
                jmp y_loaded
second_y        lda input2,y
                iny
                cmp subtr_result
                bne no_match
                lda input2,y
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

mult_results    lda #$00            ;after we find our values that add up to 2020
                sta answer_prod+2   ;   this routine multiplies them together
                ldx #$10            ;   and stores the result in a 4 byte area called answer_prod
l1              lsr subtr_result+1
                ror subtr_result
                bcc l2
                tay
                clc
                lda subtr_num2
                adc answer_prod+2
                sta answer_prod+2
                tya
                adc subtr_num2+1
l2              ror 
                ror answer_prod+2
                ror answer_prod+1
                ror answer_prod
                dex
                bne l1
                sta answer_prod+3
                rts


print_answer    ldx #$03            ;takes the value from answer_prod
                ldy #$00            ;   splits each byte into two nibbles 
loop_text       lda answer_prod,x   ;   converts those to their petscii value
                and #$F0            
                lsr
                lsr
                lsr
                lsr
                jsr prep_char
                sta $0630,y         ; ...and store in screen ram near the center
                iny
                lda answer_prod,x
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
!source "input-d01p01.asm"
