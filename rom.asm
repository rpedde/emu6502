        ;;
        ;; Exercise a blinker on FPGA (LED is msb of $0000)
        ;;

        ;; This fits in an 8k rom, from $E000 to $FFFF

        .org    $E000

        blinker = $00

reset_routine:
        lda #$00
        sta blinkerval

full_loop:
        lda blinkerval
        sta blinker

        ldy #$80

y_loop:
        ldx #$00

x_loop:
        inx
        bne x_loop

        iny
        bne y_loop

        inc blinkerval

        jmp full_loop

blinkerval:
        .dw 00

irq_routine:
nmi_routine:
        rti

        .org $fffa

v_nmi:          dw nmi_routine
v_reset:        dw reset_routine
v_irq:          dw irq_routine
