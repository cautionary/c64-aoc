;routine to clear the screen before we print our answer

clear_screen    lda #$20     ; #$20 is the spacebar screencode
                sta $0400,x  ; fill four areas with 256 spacebar characters
                sta $0500,x 
                sta $0600,x 
                ;sta $06e8,x 
                inx         
                bne clear_screen
                rts 
