

;
; Processor       : z80 []
; Target assembler: ASxxxx by Alan R. Baldwin v1.5
       .area   idaseg (ABS)
       .hd64 ; this is needed only for HD64180

.define BUILDOPT_LASER_FIXES
.define BUILDOPT_COLECO_KBD_TBL

; ===========================================================================

; Segment type: Pure code

; =============== S U B R O U T I N E =======================================


BOOT_UP:

; FUNCTION CHUNK AT 1B6B SIZE 0000008E BYTES

                        ld      sp, #STACK
                        jp      POWER_UP
; End of function BOOT_UP

; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF
; ---------------------------------------------------------------------------
                        jp      RST_8H_RAM
; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
; ---------------------------------------------------------------------------
                        jp      RST_10H_RAM
; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
; ---------------------------------------------------------------------------
                        jp      RST_18H_RAM
; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
; ---------------------------------------------------------------------------
                        jp      RST_20H_RAM
; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
; ---------------------------------------------------------------------------
                        jp      RST_28H_RAM
; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
; ---------------------------------------------------------------------------
                        jp      RST_30H_RAM
; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
; ---------------------------------------------------------------------------

RST_38H:                                                        ; get original BIOS jump address
                        ex      (sp), hl
                        push    bc
                        push    af
                        push    hl
                        xor     a
                        ld      bc, #0x1F62                     ; base of original BIOS jump table
                        sbc     hl, bc                          ; calc offset into jump table
                        or      h                               ; valid offset?
                        jp      Z, vector_to_BIOS_routine       ; yes, go

RST_38H_exit:                                                   ; CODE XREF: ROM:0D92j
                        pop     hl
                        pop     af
                        pop     bc
                        ex      (sp), hl
                        jp      IRQ_INT_VECT
; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
; ---------------------------------------------------------------------------

NMI:
                        jp      NMI_INT_VECT
; ---------------------------------------------------------------------------
AMERICA:                .db 60
ASCII_TABLE:            .dw ASCII_TBL                           ; ptr 'A'
NUMBER_TABLE:           .dw NUMBER_TBL                          ; ptr '0'
; ---------------------------------------------------------------------------

GAME_OPT_:                                                      ; DATA XREF: ROM:GAME_OPTo
                        call    DISPLAY_LOGO
                        ld      hl, #aToSelectGameOp            ; "TO SELECT GAME OPTION,"
                        ld      bc, #22                         ; length
                        ld      de, #0x1825                     ; VDP RAM offset
                        call    VRAM_WRITE
                        ld      hl, #aPressButtonOnK            ; "PRESS BUTTON ON KEYPAD."
                        ld      bc, #23                         ; length
                        ld      de, #0x1865                     ; VDP RAM offset
                        call    VRAM_WRITE
                        ld      hl, #a1Skill1OnePlay            ; "1 = SKILL 1/ONE PLAYERS"
                        ld      de, #msg_buf
                        ld      bc, #23                         ; length
                        ldir
                        ld      ix, #msg_buf
                        ld      de, #msg_buf                    ; message
                        ld      iy, #22                         ; length
                        ld      hl, #0x18C5                     ; VDP RAM offset
                        call    PRINT_SKILL_1_4
                        inc     iy
                        ld      hl, #aTwo                       ; "TWO"
                        ld      de, # msg_buf+0xC               ; 'ONE'
                        ld      bc, #3                          ; 3 chars to patch
                        ldir                                    ; patch skill message for two players
                        ld      a, #0x31 ; '1'
                        ld      (msg_buf+0xA), a                ; patch 2nd number
                        ld      hl, #0x19E5                     ; VDP RAM offset
                        ld      de, #msg_buf                    ; message
; IX = message
; DE = message
; IY = length
; HL = VDP RAM offset

; =============== S U B R O U T I N E =======================================


PRINT_SKILL_1_4:                                                ; CODE XREF: ROM:00A2p
                        ld      b, #4                           ; 4 messages

print_skill:                                                    ; CODE XREF: PRINT_SKILL_1_4+18j
                        push    de                              ; message
                        push    bc                              ; counter
                        push    iy                              ; message length
                        pop     bc                              ; BC = message length
                        ex      de, hl                          ; HL=message, DE=VDP RAM offset
                        call    VRAM_WRITE
                        ex      de, hl                          ; HL=VDP RAM offset, HL=message
                        inc     0(ix)                           ; inc 1st number
                        inc     0xA(ix)                         ; inc 2nd number
                        pop     bc                              ; counter
                        ld      de, #0x40 ; '@'
                        add     hl, de                          ; VDP RAM offset next line
                        pop     de                              ; message
                        djnz    print_skill                     ; done? no, loop
                        ret
; End of function PRINT_SKILL_1_4


; =============== S U B R O U T I N E =======================================


delay_DE:                                                       ; CODE XREF: delay_DE+Bj
                                                                ; BOOT_UP+1B72p ...
                        ld      bc, #0

delay_BC:                                                       ; CODE XREF: delay_DE:delay_BCj
                                                                ; delay_DE+6j
                        djnz    delay_BC
                        dec     c
                        jr      NZ, delay_BC
                        dec     de
                        ld      a, d
                        or      e
                        jr      NZ, delay_DE
                        ret
; End of function delay_DE

; ---------------------------------------------------------------------------
                        push    bc
                        pop     iy
                        ld      a, #0x20 ; ' '
                        sbc     a, c
                        rra
                        ld      b, #0
                        ld      c, a
                        add     hl, bc
                        ld      b, h
                        ld      c, l
                        ld      h, d
                        ld      l, e
                        ld      d, b
                        ld      e, c
                        ld      a, #2
                        call    PUT_VRAM_
                        ret

; =============== S U B R O U T I N E =======================================


MODE_1_:                                                        ; CODE XREF: DISPLAY_LOGO+Ap
                                                                ; DATA XREF: ROM:MODE_1o
                        ld      hl, (vdp_reg_init_data)
                        ld      (VDP_MODE_WORD), hl
                        ld      hl, #mode_1_data
                        ld      de, #VRAM_ADDR_TABLE
                        ld      bc, #10
                        ldir
                        ld      c, #0xBF ; '¿'                  ; VDP_RAM_ADDR port
                        ld      b, #8                           ; num registers to write
                        ld      a, #0x80 ; '€'

mode_1_loop:                                                    ; CODE XREF: MODE_1_+1Dj
                        outi                                    ; write VDP reg value
                        out     (c), a
                        ret     Z
                        inc     a
                        jr      mode_1_loop
; End of function MODE_1_

; ---------------------------------------------------------------------------
mode_1_data:            .db    0                                ; DATA XREF: MODE_1_+6o
                        .db 0x1B
                        .db    0
                        .db 0x38 ; 8
                        .db    0
                        .db 0x18
                        .db    0
                        .db    0
                        .db    0
                        .db 0x20
vdp_reg_init_data:      .dw 0xC000                              ; DATA XREF: MODE_1_r
                        .db    6
                        .db 0x80 ; €
                        .db    0
                        .db 0x36 ; 6
                        .db    7
                        .db 0xFD ; ý
; HL = VDP RAM address
; DE = number of bytes to fill
; A = fill char

; =============== S U B R O U T I N E =======================================


FILL_VRAM_:                                                     ; CODE XREF: DISPLAY_LOGO+7p
                                                                ; DISPLAY_LOGO+3Cj
                                                                ; DATA XREF: ...
                        ld      c, a                            ; store fill char
                        ld      a, l
                        out     (0xBF), a                       ; VDP_RAM_ADDR
                        ld      a, h
                        or      #0x40 ; '@'                     ; add base address
                        out     (0xBF), a                       ; VDP_RAM_ADDR

FILL:                                                           ; CODE XREF: FILL_VRAM_+Fj
                        ld      a, c                            ; fill char
                        out     (0xBE), a                       ; VDP_DATA
                        dec     de
                        ld      a, d
                        or      e                               ; done?
                        jr      NZ, FILL                        ; no, loop
                        call    REG_READ
                        ret
; End of function FILL_VRAM_

; ---------------------------------------------------------------------------
VRAM_WRITE_P:           .dw 3                                   ; DATA XREF: ROM:WRITE_VRAMQo
                                                                ; ROM:READ_VRAMQo
                        .dw 0xFFFE
                        .dw 2
                        .dw 2
; ---------------------------------------------------------------------------
; this routine is truncated (broken)
; - it should fall into VRAM_WRITE

WRITE_VRAMQ:                                                    ; DATA XREF: ROM:WRITE_VRAMPo
                        ld      bc, #VRAM_WRITE_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      hl, (PARAM_AREA)
                        ld      de, (PARAM_AREA+2)
                        ld      bc, (PARAM_AREA+4)
; well this isn't good...
.ifdef BUILDOPT_LASER_FIXES
                        jp      VRAM_WRITE
.endif
; ---------------------------------------------------------------------------
REG_WRITEP:             .dw 2                                   ; DATA XREF: ROM:REG_WRITEQo
                        .dw 1
                        .dw 1
; ---------------------------------------------------------------------------

REG_WRITEQ:                                                     ; DATA XREF: ROM:WRITE_REGISTERPo
                        ld      bc, #REG_WRITEP
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      hl, (PARAM_AREA)
                        ld      c, h
                        ld      b, l

; =============== S U B R O U T I N E =======================================


REG_WRITE:                                                      ; CODE XREF: ROM:INIT_TABLE90p
                                                                ; DATA XREF: ROM:WRITE_REGISTERo
                        ld      a, c
                        out     (0xBF), a                       ; CTRL_PORT
                        ld      a, b
                        add     a, #0x80 ; '€'
                        out     (0xBF), a                       ; CTRL_PORT
                        ld      a, b
                        cp      #0
                        jr      NZ, NOT_REG_0
                        ld      a, c
                        ld      (VDP_MODE_WORD), a

NOT_REG_0:                                                      ; CODE XREF: REG_WRITE+Bj
                        ld      a, b
                        cp      #1
                        jr      NZ, NOT_REG_1
                        ld      a, c
                        ld      (VDP_MODE_WORD+1), a

NOT_REG_1:                                                      ; CODE XREF: REG_WRITE+14j
                        ret
; End of function REG_WRITE

; ---------------------------------------------------------------------------
WR_SPR_P:               .dw 1                                   ; DATA XREF: ROM:WR_SPR_NM_TBLQo
                        .dw 1
; ---------------------------------------------------------------------------

WR_SPR_NM_TBLQ:                                                 ; DATA XREF: ROM:WR_SPR_NM_TBLPo
                        ld      bc, #WR_SPR_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      a, (PARAM_AREA)

WR_SPR_NM_TBL_:                                                 ; DATA XREF: ROM:WR_SPR_NM_TBLo
                        ld      ix, (SPRITE_ORDER)
                        push    af
                        ld      iy, #VRAM_ADDR_TABLE
                        ld      e, 0(iy)
                        ld      d, 1(iy)
                        ld      a, e
                        out     (0xBF), a                       ; CTRL_PORT
                        ld      a, d
                        or      #0x40 ; '@'
                        out     (0xBF), a                       ; CTRL_PORT
                        pop     af

OUTPUT_LOOP_TABLE_MA:                                           ; CODE XREF: ROM:01CFj
                        ld      hl, (LOCAL_SPR_TBL)
                        ld      c, 0(ix)
                        inc     ix
                        ld      b, #0
                        add     hl, bc
                        add     hl, bc
                        add     hl, bc
                        add     hl, bc
                        ld      b, #4
                        ld      c, #0xBE ; '¾'                  ; DATA_PORT

OUTPUT_LOOP10:                                                  ; CODE XREF: ROM:01CCj
                        outi
                        nop
                        nop                                     ; delay
                        jr      NZ, OUTPUT_LOOP10
                        dec     a
                        jr      NZ, OUTPUT_LOOP_TABLE_MA
                        ret
; ---------------------------------------------------------------------------
INIT_SPR_P:             .dw 1                                   ; DATA XREF: ROM:INIT_SPR_ORDERQo
                        .dw 1
; ---------------------------------------------------------------------------

INIT_SPR_ORDERQ:                                                ; DATA XREF: ROM:INIT_SPR_ORDERPo
                        ld      bc, #INIT_SPR_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      a, (PARAM_AREA)

INIT_SPR_ORDER_:                                                ; DATA XREF: ROM:INIT_SPR_ORDERo
                        ld      b, a
                        xor     a
                        ld      hl, (SPRITE_ORDER)

INIT_SPR10:                                                     ; CODE XREF: ROM:01EBj
                        ld      (hl), a
                        inc     hl
                        inc     a
                        cp      b
                        jr      NZ, INIT_SPR10
                        ret
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PUT_VRAM_

ELSEZZ:                                                         ; CODE XREF: PUT_VRAM_+3j
                                                                ; PUT_VRAM_+Aj
                        pop     af
                        call    SET_COUNT
                        call    VRAM_WRITE
                        ret
; END OF FUNCTION CHUNK FOR PUT_VRAM_
; ---------------------------------------------------------------------------
SHIFT_CT:               .db    2                                ; DATA XREF: SET_COUNT:SET_COUNT10o
                        .db    3
                        .db    0
                        .db    3
                        .db    3
PUT_VRAM_P:             .dw 5                                   ; DATA XREF: ROM:PUT_VRAMQo
                        .dw 1
                        .dw 1
                        .dw 1
                        .dw 0xFFFE
                        .dw 2
; ---------------------------------------------------------------------------

PUT_VRAMQ:                                                      ; DATA XREF: ROM:PUT_VRAMPo
                        ld      bc, #PUT_VRAM_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      a, (PARAM_AREA)
                        ld      de, (PARAM_AREA+1)
                        ld      iy, (PARAM_AREA+5)
                        ld      hl, (PARAM_AREA+3)

; =============== S U B R O U T I N E =======================================


PUT_VRAM_:                                                      ; CODE XREF: ROM:00F9p
                                                                ; PUT_COLOR+Dp ...

; FUNCTION CHUNK AT 01EE SIZE 00000008 BYTES

                        push    af
                        cp      #0
                        jr      NZ, ELSEZZ
                        ld      a, (MUX_SPRITES)
                        cp      #1
                        jr      NZ, ELSEZZ
                        pop     af
                        push    hl
                        ld      hl, (LOCAL_SPR_TBL)
                        ld      a, e
                        sla     a
                        sla     a
                        ld      e, a
                        add     hl, de
                        ex      de, hl
                        push    iy
                        pop     bc
                        ld      a, c
                        sla     a
                        sla     a
                        ld      c, a
                        pop     hl
                        ldir
                        ret
; End of function PUT_VRAM_


; =============== S U B R O U T I N E =======================================


SET_COUNT:                                                      ; CODE XREF: PUT_VRAM_-2Fp
                                                                ; GET_VRAM_p
                        ld      (SAVED_COUNT), iy
                        ld      ix, #VRAM_ADDR_TABLE
                        ld      c, a
                        ld      b, #0
                        cp      #4
                        jr      NZ, SET_COUNT10
                        ld      a, (VDP_MODE_WORD)
                        bit     1, a
                        jr      Z, SET_COUNT20

SET_COUNT10:                                                    ; CODE XREF: SET_COUNT+Dj
                        ld      iy, #SHIFT_CT
                        add     iy, bc
                        ld      a, 0(iy)
                        cp      #0
                        jr      Z, SET_COUNT20

ADJUST_INDEX:                                                   ; CODE XREF: SET_COUNT+28j
                        sla     e
                        rl      d
                        dec     a
                        jr      NZ, ADJUST_INDEX
                        push    bc
                        ld      bc, (SAVED_COUNT)
                        ld      a, 0(iy)
                        cp      #0
                        jr      Z, END_ADJ_COUNT

ADJUST_COUNT:                                                   ; CODE XREF: SET_COUNT+3Bj
                        sla     c
                        rl      b
                        dec     a
                        jr      NZ, ADJUST_COUNT
                        ld      (SAVED_COUNT), bc

END_ADJ_COUNT:                                                  ; CODE XREF: SET_COUNT+34j
                        pop     bc

SET_COUNT20:                                                    ; CODE XREF: SET_COUNT+14j
                                                                ; SET_COUNT+21j
                        push    hl
                        add     ix, bc
                        add     ix, bc
                        ld      l, 0(ix)
                        ld      h, 1(ix)
                        add     hl, de
                        ex      de, hl
                        pop     hl
                        ld      bc, (SAVED_COUNT)
                        ret
; End of function SET_COUNT

; ---------------------------------------------------------------------------

GET_VRAMQ:                                                      ; DATA XREF: ROM:GET_VRAMPo
                        ld      bc, #GET_VRAM_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      a, (PARAM_AREA)
                        ld      de, (PARAM_AREA+1)
                        ld      iy, (PARAM_AREA+5)
                        ld      hl, (PARAM_AREA+3)

; =============== S U B R O U T I N E =======================================


GET_VRAM_:                                                      ; CODE XREF: GET_COLOR+Dp
                                                                ; ROM:054Ep ...
                        call    SET_COUNT
                        call    VRAM_READ
                        ret
; End of function GET_VRAM_

; ---------------------------------------------------------------------------
BASE_FACTORS:           .db    7                                ; DATA XREF: ROM:INIT_TABLE80o
                        .db    5
                        .db  0xB
                        .db    6
                        .db  0xA
                        .db    2
                        .db  0xB
                        .db    4
                        .db    6
                        .db    3
GET_VRAM_P:             .dw 5                                   ; DATA XREF: ROM:GET_VRAMQo
                        .dw 1
                        .dw 1
                        .dw 1
                        .dw 0xFFFE
                        .dw 2
; ---------------------------------------------------------------------------

CASE_OF_CLR10:                                                  ; CODE XREF: ROM:02D5j
                        ld      c, #0xFF
                        jr      INIT_TABLE90
; ---------------------------------------------------------------------------

CASE_OF_COLOR:                                                  ; CODE XREF: ROM:031Dj
                        ld      b, #3
                        ld      a, l
                        or      h
                        jr      NZ, CASE_OF_CLR10
                        ld      c, #0x7F ; ''
                        jr      INIT_TABLE90
; ---------------------------------------------------------------------------

CASE_OF_GEN:                                                    ; CODE XREF: ROM:0319j
                        ld      b, #4
                        ld      a, l
                        or      h
                        jr      NZ, CASE_OF_GEN10
                        ld      c, #3
                        jr      INIT_TABLE90
; ---------------------------------------------------------------------------

CASE_OF_GEN10:                                                  ; CODE XREF: ROM:02DFj
                        ld      c, #7
                        jr      INIT_TABLE90
; ---------------------------------------------------------------------------
INIT_TABLE_P:           .dw 2                                   ; DATA XREF: ROM:INIT_TABLEQo
                        .dw 1
                        .dw 2
; ---------------------------------------------------------------------------

INIT_TABLEQ:                                                    ; DATA XREF: ROM:INIT_TABLEPo
                        ld      bc, #INIT_TABLE_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      a, (PARAM_AREA)
                        ld      hl, (PARAM_AREA+1)

INIT_TABLE_:                                                    ; DATA XREF: ROM:INIT_TABLEo
                        ld      c, a
                        ld      b, #0
                        ld      ix, #VRAM_ADDR_TABLE
                        add     ix, bc
                        add     ix, bc
                        ld      0(ix), l
                        ld      1(ix), h
                        ld      a, (VDP_MODE_WORD)
                        bit     1, a
                        jr      Z, INIT_TABLE80
                        ld      a, c
                        cp      #3
                        jr      Z, CASE_OF_GEN
                        cp      #4
                        jr      Z, CASE_OF_COLOR

INIT_TABLE80:                                                   ; CODE XREF: ROM:0314j
                        ld      iy, #BASE_FACTORS
                        add     iy, bc
                        add     iy, bc
                        ld      a, 0(iy)
                        ld      b, 1(iy)

DIVIDE:                                                         ; CODE XREF: ROM:0332j
                        srl     h
                        rr      l
                        dec     a
                        jr      NZ, DIVIDE
                        ld      c, l

INIT_TABLE90:                                                   ; CODE XREF: ROM:02CFj
                                                                ; ROM:02D9j ...
                        call    REG_WRITE
                        ret
; ---------------------------------------------------------------------------

READ_VRAMQ:                                                     ; DATA XREF: ROM:READ_VRAMPo
                        ld      bc, #VRAM_WRITE_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      hl, (PARAM_AREA)
                        ld      de, (PARAM_AREA+2)
                        ld      bc, (PARAM_AREA+4)

; =============== S U B R O U T I N E =======================================


VRAM_READ:                                                      ; CODE XREF: GET_VRAM_+3p
                                                                ; PUTOBJ_-5D1p ...
                        ld      a, e
                        out     (0xBF), a                       ; CTRL_PORT
                        ld      a, d
                        out     (0xBF), a                       ; CTRL_PORT
                        push    bc
                        pop     de
                        ld      c, #0xBE ; '¾'                  ; DATA_PORT
                        ld      b, e

INPUT_LOOP:                                                     ; CODE XREF: VRAM_READ+Fj
                                                                ; VRAM_READ+13j
                        ini
                        nop
                        nop
                        jr      NZ, INPUT_LOOP
                        dec     d
                        ret     M
                        jr      NZ, INPUT_LOOP
                        ret
; End of function VRAM_READ


; =============== S U B R O U T I N E =======================================


MIRROR_U_D:                                                     ; CODE XREF: ROM:04E8p
                                                                ; ROM:0502p
                        ld      bc, #7
                        add     hl, bc
                        inc     bc

REFLECT_LOOP:                                                   ; CODE XREF: MIRROR_U_D+Cj
                        ld      a, (hl)
                        ld      (de), a
                        inc     de
                        dec     hl
                        dec     bc
                        ld      a, b
                        or      c
                        jr      NZ, REFLECT_LOOP
                        ret
; End of function MIRROR_U_D


; =============== S U B R O U T I N E =======================================


REG_READ:                                                       ; CODE XREF: FILL_VRAM_+11p
                                                                ; VRAM_WRITE+4p ...
                        in      a, (0xBF)                       ; VDP_STATUS
                        ret
; End of function REG_READ


; =============== S U B R O U T I N E =======================================


ROTATE:                                                         ; CODE XREF: ROM:04C6p
                        push    hl
                        pop     ix
                        ex      de, hl
                        ld      bc, #8

TRANSP_10:                                                      ; CODE XREF: ROTATE+39j
                        rl      0(ix)
                        rr      (hl)
                        rl      1(ix)
                        rr      (hl)
                        rl      2(ix)
                        rr      (hl)
                        rl      3(ix)
                        rr      (hl)
                        rl      4(ix)
                        rr      (hl)
                        rl      5(ix)
                        rr      (hl)
                        rl      6(ix)
                        rr      (hl)
                        rl      7(ix)
                        rr      (hl)
                        inc     hl
                        dec     c
                        jr      NZ, TRANSP_10
                        ret
; End of function ROTATE


; =============== S U B R O U T I N E =======================================


MIRROR_L_R:                                                     ; CODE XREF: ROM:0516p
                        ld      bc, #8

MIR_L_R10:                                                      ; CODE XREF: MIRROR_L_R+Fj
                        ld      b, (hl)
                        ld      a, #0x80 ; '€'

MIR_L_R20:                                                      ; CODE XREF: MIRROR_L_R+9j
                        rl      b
                        rra
                        jr      NC, MIR_L_R20
                        ld      (de), a
                        inc     hl
                        inc     de
                        dec     c
                        jr      NZ, MIR_L_R10
                        ret
; End of function MIRROR_L_R


; =============== S U B R O U T I N E =======================================


QUADRUPLE:                                                      ; CODE XREF: ROM:049Dp
                        ld      bc, #0x10
                        push    hl

QUAD_LOOP:                                                      ; CODE XREF: QUADRUPLE+13j
                        ld      a, (hl)
                        inc     hl
                        ld      (de), a
                        inc     de
                        ld      (de), a
                        inc     de
                        dec     bc
                        ld      a, c
                        cp      #8
                        jr      NZ, SKIPZZ
                        pop     hl

SKIPZZ:                                                         ; CODE XREF: QUADRUPLE+Ej
                        ld      a, c
                        or      b
                        jr      NZ, QUAD_LOOP
                        ret
; End of function QUADRUPLE


; =============== S U B R O U T I N E =======================================


MAGNIFY:                                                        ; CODE XREF: ROM:0470p
                        push    hl
                        pop     ix
                        push    de
                        pop     iy
                        ld      bc, #8

MAG_LOOP:                                                       ; CODE XREF: MAGNIFY+3Cj
                        ld      a, 0(ix)
                        inc     ix
                        ld      d, a
                        ld      e, #4

EXP_1:                                                          ; CODE XREF: MAGNIFY+1Aj
                        rl      a
                        rl      h
                        rl      d
                        rl      h
                        dec     e
                        jr      NZ, EXP_1
                        ld      e, #4

EXP_2:                                                          ; CODE XREF: MAGNIFY+27j
                        rl      a
                        rl      l
                        rl      d
                        rl      l
                        dec     e
                        jr      NZ, EXP_2
                        ld      0(iy), h
                        ld      0x10(iy), l
                        inc     iy
                        ld      0(iy), h
                        ld      0x10(iy), l
                        inc     iy
                        dec     bc
                        ld      a, c
                        or      b
                        jr      NZ, MAG_LOOP
                        ret
; End of function MAGNIFY


; =============== S U B R O U T I N E =======================================


PUT_COLOR:                                                      ; CODE XREF: ROM:04D6p
                                                                ; ROM:0505p ...
                        ld      a, #4
                        exx
                        push    hl
                        exx
                        pop     de
                        ld      hl, (WORK_BUFFER)
                        ld      iy, #1
                        call    PUT_VRAM_
                        ret
; End of function PUT_COLOR


; =============== S U B R O U T I N E =======================================


GET_COLOR:                                                      ; CODE XREF: ROM:0490p
                                                                ; ROM:04D3p ...
                        ld      a, #4
                        exx
                        push    de
                        exx
                        pop     de
                        ld      hl, (WORK_BUFFER)
                        ld      iy, #1
                        call    GET_VRAM_
                        ret
; End of function GET_COLOR


; =============== S U B R O U T I N E =======================================


PUT_TABLE:                                                      ; CODE XREF: ROM:04C9p
                                                                ; ROM:04EBp ...
                        ex      af, af'
                        push    af
                        ex      af, af'
                        pop     af
                        exx
                        push    hl
                        exx
                        pop     de
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        add     hl, bc
                        ld      iy, #1
                        call    PUT_VRAM_
                        ret
; End of function PUT_TABLE

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR COLOR_TEST

EXIT_FALSE:                                                     ; CODE XREF: COLOR_TEST+6j
                                                                ; COLOR_TEST+Dj
                        ld      a, #0
                        ret
; END OF FUNCTION CHUNK FOR COLOR_TEST

; =============== S U B R O U T I N E =======================================


COLOR_TEST:                                                     ; CODE XREF: ROM:0489p
                                                                ; ROM:04CCp ...

; FUNCTION CHUNK AT 0451 SIZE 00000003 BYTES

                        ex      af, af'
                        push    af
                        ex      af, af'
                        pop     af
                        cp      #3
                        jr      NZ, EXIT_FALSE
                        ld      hl, #VDP_MODE_WORD
                        bit     1, (hl)
                        jr      Z, EXIT_FALSE
                        ld      a, #1
                        ret
; End of function COLOR_TEST

; ---------------------------------------------------------------------------

ENLRG_:                                                         ; DATA XREF: ROM:ENLRGo
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        push    hl
                        pop     de
                        add     hl, bc
                        ex      de, hl
                        call    MAGNIFY
                        ex      af, af'
                        push    af
                        ex      af, af'
                        pop     af
                        exx
                        push    hl
                        exx
                        pop     de
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        add     hl, bc
                        ld      iy, #4
                        call    PUT_VRAM_
                        call    COLOR_TEST
                        cp      #1
                        jr      NZ, END_IF_4_GRAPHICS
                        call    GET_COLOR
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        push    hl
                        pop     de
                        add     hl, bc
                        ex      de, hl
                        call    QUADRUPLE
                        ld      a, #4
                        exx
                        push    hl
                        exx
                        pop     de
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        add     hl, bc
                        ld      iy, #4
                        call    PUT_VRAM_

END_IF_4_GRAPHICS:                                              ; CODE XREF: ROM:048Ej
                        exx
                        inc     hl
                        inc     hl
                        inc     hl
                        inc     hl
                        jp      RETURN_HERE
; ---------------------------------------------------------------------------

ROT_90_:                                                        ; DATA XREF: ROM:ROT_90o
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        push    hl
                        pop     de
                        add     hl, bc
                        ex      de, hl
                        call    ROTATE
                        call    PUT_TABLE
                        call    COLOR_TEST
                        cp      #1
                        jr      NZ, END_IF_3_GRAPHICS
                        call    GET_COLOR
                        call    PUT_COLOR

END_IF_3_GRAPHICS:                                              ; CODE XREF: ROM:04D1j
                        exx
                        inc     hl
                        jp      RETURN_HERE
; ---------------------------------------------------------------------------

RFLCT_HOR_:                                                     ; DATA XREF: ROM:RFLCT_HORo
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        push    hl
                        pop     de
                        add     hl, bc
                        ex      de, hl
                        call    MIRROR_U_D
                        call    PUT_TABLE
                        call    COLOR_TEST
                        cp      #1
                        jr      NZ, END_IF_2_GRAPHICS
                        call    GET_COLOR
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        push    hl
                        pop     de
                        add     hl, bc
                        ex      de, hl
                        call    MIRROR_U_D
                        call    PUT_COLOR

END_IF_2_GRAPHICS:                                              ; CODE XREF: ROM:04F3j
                        exx
                        inc     hl
                        jr      RETURN_HERE
; ---------------------------------------------------------------------------

RFLCT_VERT_:                                                    ; DATA XREF: ROM:RFLCT_VERTo
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #8
                        push    hl
                        pop     de
                        add     hl, bc
                        ex      de, hl
                        call    MIRROR_L_R
                        call    PUT_TABLE
                        call    COLOR_TEST
                        cp      #1
                        jr      NZ, END_IF_1_GRAPHICS
                        call    GET_COLOR
                        call    PUT_COLOR

END_IF_1_GRAPHICS:                                              ; CODE XREF: ROM:0521j
                        exx
                        inc     hl
                        jr      RETURN_HERE
; ---------------------------------------------------------------------------

RETURN_HERE:                                                    ; CODE XREF: ROM:04B9j
                                                                ; ROM:04DBj ...
                        inc     de
                        dec     bc
                        ld      a, b
                        or      c
                        exx
                        jr      NZ, MAIN_LOOP
                        pop     ix
                        ret
; ---------------------------------------------------------------------------

ENLRG:                                                          ; DATA XREF: ROM:ENLARGEo
                        ld      ix, #ENLRG_

CONTINUE_GRAPHICS:                                              ; CODE XREF: ROM:055Bj
                                                                ; ROM:0561j ...
                        exx
                        ex      af, af'
                        push    ix

MAIN_LOOP:                                                      ; CODE XREF: ROM:0532j
                        ex      af, af'
                        push    af
                        ex      af, af'
                        pop     af
                        exx
                        push    de
                        exx
                        pop     de
                        ld      iy, #1
                        ld      hl, (WORK_BUFFER)
                        call    GET_VRAM_
                        pop     ix
                        push    ix
                        jp      (ix)
; ---------------------------------------------------------------------------

RFLCT_HOR:                                                      ; DATA XREF: ROM:REFLECT_HORIZONTALo
                        ld      ix, #RFLCT_HOR_
                        jr      CONTINUE_GRAPHICS
; ---------------------------------------------------------------------------

RFLCT_VERT:                                                     ; DATA XREF: ROM:REFLECT_VERTICALo
                        ld      ix, #RFLCT_VERT_
                        jr      CONTINUE_GRAPHICS
; ---------------------------------------------------------------------------

ROT_90:                                                         ; DATA XREF: ROM:ROTATE_90o
                        ld      ix, #ROT_90_
                        jr      CONTINUE_GRAPHICS
; ---------------------------------------------------------------------------
; this differs appreciably from the Colecovision table
.ifndef BUILDOPT_COLECO_KBD_TBL
DEC_KBD_TBL:            .db  0xF                                ; DATA XREF: DECODE_1-Co
                                                                ; ROM:06CDo
                        .db    8
                        .db  0xA
                        .db    1
                        .db  0xB
                        .db    9
                        .db    3
                        .db  0xF
                        .db    7
                        .db    6
                        .db    5
                        .db  0xF
                        .db    0
                        .db    4
                        .db    2
                        .db  0xF
.else
DEC_KBD_TBL:            .db  0xF                                ; DATA XREF: DECODE_1-Co
                                                                ; ROM:06CDo
                        .db    6
                        .db    1
                        .db    3
                        .db    9
                        .db    0
                        .db  0xA
                        .db  0xF
                        .db    2
                        .db  0xB
                        .db    7
                        .db  0xF
                        .db    5
                        .db    4
                        .db    8
                        .db  0xF
.endif
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR ARM_DBNCE

ARM_ST1:                                                        ; CODE XREF: ARM_DBNCE+Dj
                        ld      a, e
                        cp      b
                        jr      Z, ARM_EXIT
                        ld      6(iy), e                        ; ARM_OLD
                        xor     a
                        ld      7(iy), a                        ; ARM_STATE

ARM_EXIT:                                                       ; CODE XREF: ARM_DBNCE-16j
                                                                ; ARM_DBNCE-2j ...
                        pop     de
                        pop     bc
                        ret
; ---------------------------------------------------------------------------

ARM_REG:                                                        ; CODE XREF: ARM_DBNCE+11j
                        ld      a, #1
                        ld      7(iy), a                        ; ARM_STATE
                        ld      3(ix), e                        ; ARM
                        jr      ARM_EXIT
; END OF FUNCTION CHUNK FOR ARM_DBNCE

; =============== S U B R O U T I N E =======================================


ARM_DBNCE:                                                      ; CODE XREF: DECODE_1+3p

; FUNCTION CHUNK AT 0579 SIZE 00000018 BYTES

                        push    bc
                        push    de
                        and     #0x40 ; '@'                     ; ARM_MASK
                        ld      e, a
                        ld      b, 6(iy)                        ; ARM_OLD
                        ld      a, 7(iy)                        ; ARM_STATE
                        cp      #0
                        jr      NZ, ARM_ST1

ARM_ST0:
                        ld      a, e
                        cp      b
                        jr      Z, ARM_REG
                        ld      6(iy), e                        ; ARM_OLD
                        jr      ARM_EXIT
; End of function ARM_DBNCE

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR JOY_DBNCE

JOY_ST1:                                                        ; CODE XREF: JOY_DBNCE+Dj
                        ld      a, e
                        cp      b
                        jr      Z, JOY_EXIT
                        ld      2(iy), e
                        xor     a
                        ld      3(iy), a

JOY_EXIT:                                                       ; CODE XREF: JOY_DBNCE-16j
                                                                ; JOY_DBNCE-2j ...
                        pop     de
                        pop     bc
                        ret
; ---------------------------------------------------------------------------

JOY_REG:                                                        ; CODE XREF: JOY_DBNCE+11j
                        ld      a, #1
                        ld      3(iy), a
                        ld      1(ix), e
                        jr      JOY_EXIT
; END OF FUNCTION CHUNK FOR JOY_DBNCE

; =============== S U B R O U T I N E =======================================


JOY_DBNCE:                                                      ; CODE XREF: DECODE_0+3p

; FUNCTION CHUNK AT 05A9 SIZE 00000018 BYTES

                        push    bc
                        push    de
                        and     #0xF                            ; JOY_MASK
                        ld      e, a
                        ld      b, 2(iy)                        ; JOY_OLD
                        ld      a, 3(iy)                        ; JOY_STATE
                        cp      #0
                        jr      NZ, JOY_ST1

JOY_ST0:
                        ld      a, e
                        cp      b
                        jr      Z, JOY_REG
                        ld      2(iy), e                        ; JOY_OLD
                        jr      JOY_EXIT
; End of function JOY_DBNCE

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR FIRE_DBNCE

FIRE_ST1:                                                       ; CODE XREF: FIRE_DBNCE+Dj
                        ld      a, e
                        cp      b
                        jr      Z, FIRE_EXIT
                        ld      0(iy), e
                        xor     a
                        ld      1(iy), a

FIRE_EXIT:                                                      ; CODE XREF: FIRE_DBNCE-Cj
                                                                ; FIRE_DBNCE+16j ...
                        pop     de
                        pop     bc
                        ret
; END OF FUNCTION CHUNK FOR FIRE_DBNCE

; =============== S U B R O U T I N E =======================================


FIRE_DBNCE:                                                     ; CODE XREF: DECODE_0+9p

; FUNCTION CHUNK AT 05D9 SIZE 0000000E BYTES

                        push    bc
                        push    de
                        and     #0x40 ; '@'                     ; FIRE_MASK
                        ld      e, a
                        ld      b, 0(iy)                        ; FIRE_OLD
                        ld      a, 1(iy)                        ; FIRE_STATE
                        cp      #0
                        jr      NZ, FIRE_ST1

FIRE_ST0:
                        ld      a, e
                        cp      b
                        jr      Z, FIRE_REG
                        ld      0(iy), e                        ; FIRE_OLD
                        jr      FIRE_EXIT
; ---------------------------------------------------------------------------

FIRE_REG:                                                       ; CODE XREF: FIRE_DBNCE+11j
                        ld      a, #1
                        ld      1(iy), a
                        ld      0(ix), e
                        jr      FIRE_EXIT
; End of function FIRE_DBNCE

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR DECODE_1

KBD_ST1:                                                        ; CODE XREF: DECODE_1+18j
                        ld      a, e
                        cp      b
                        jr      Z, KBD_EXIT
                        ld      8(iy), e
                        xor     a
                        ld      9(iy), a

KBD_EXIT:                                                       ; CODE XREF: DECODE_1-1Ej
                                                                ; DECODE_1-2j ...
                        pop     hl
                        pop     de
                        pop     bc
                        ret
; ---------------------------------------------------------------------------

KBD_REG:                                                        ; CODE XREF: DECODE_1+1Cj
                        ld      a, #1
                        ld      9(iy), a
                        ld      hl, #DEC_KBD_TBL
                        ld      d, #0
                        add     hl, de
                        ld      a, (hl)
                        ld      4(ix), a
                        jr      KBD_EXIT
; END OF FUNCTION CHUNK FOR DECODE_1

; =============== S U B R O U T I N E =======================================


DECODE_1:                                                       ; CODE XREF: ROM:0695p
                                                                ; ROM:06BFp

; FUNCTION CHUNK AT 0609 SIZE 00000020 BYTES

                        ld      c, a
                        bit     3, b                            ; ARM
                        call    NZ, ARM_DBNCE
                        ld      a, c

DEC_KBD:                                                        ; KBD
                        bit     4, b
                        ret     Z

KBD_DBNCE:
                        push    bc
                        push    de
                        push    hl
                        and     #0xF                            ; KBD_MASK
                        ld      e, a
                        ld      b, 8(iy)                        ; KBD_OLD
                        ld      a, 9(iy)                        ; KBD_STATE
                        cp      #0
                        jr      NZ, KBD_ST1

KBD_ST0:
                        ld      a, e
                        cp      b
                        jr      Z, KBD_REG
                        ld      8(iy), e                        ; KBD_OLD
                        jr      KBD_EXIT
; End of function DECODE_1


; =============== S U B R O U T I N E =======================================


DECODE_0:                                                       ; CODE XREF: ROM:068Ap
                                                                ; ROM:06B5p
                        ld      c, a
                        bit     1, b                            ; JOY
                        call    NZ, JOY_DBNCE
                        ld      a, c
                        bit     0, b
                        call    NZ, FIRE_DBNCE
                        ld      a, c

DEC_SPIN:                                                       ; SPIN
                        bit     2, b
                        ret     Z
                        ld      a, (hl)
                        add     a, 2(ix)
                        ld      2(ix), a
                        xor     a
                        ld      (hl), a
                        ret
; End of function DECODE_0

; ---------------------------------------------------------------------------

POLLER_:                                                        ; DATA XREF: ROM:POLLERo
                        call    CONT_SCAN
                        ld      iy, #DBNCE_BUFF
                        ld      ix, (CONTROLLER_MAP)
                        push    ix
                        ld      a, 0(ix)
                        bit     7, a
                        jr      Z, CHK_PLYR_1
                        ld      b, a
                        ld      de, #2
                        add     ix, de
                        and     #7                              ; SEG_0
                        jr      Z, CHK_SEG_01
                        ld      a, (S0_C0)
                        ld      hl, #SPIN_SW0_CT
                        call    DECODE_0

CHK_SEG_01:                                                     ; CODE XREF: ROM:0682j
                        ld      a, b
                        and     #0x18                           ; SEG_1
                        jr      Z, CHK_PLYR_1
                        ld      a, (S1_C0)
                        call    DECODE_1

CHK_PLYR_1:                                                     ; CODE XREF: ROM:0678j
                                                                ; ROM:0690j
                        pop     ix
                        ld      a, 1(ix)
                        bit     7, a
                        ret     Z
                        ld      b, a
                        ld      de, #0xA
                        add     iy, de
                        ld      de, #7
                        add     ix, de
                        and     #7                              ; SEG_0
                        jr      Z, CHK_SEG_11
                        ld      a, (S0_C1)
                        ld      hl, #SPIN_SW1_CT
                        call    DECODE_0

CHK_SEG_11:                                                     ; CODE XREF: ROM:06ADj
                        ld      a, b
                        and     #0x18                           ; SEG_1
                        ret     Z
                        ld      a, (S1_C1)
                        call    DECODE_1
                        ret
; ---------------------------------------------------------------------------

DEC_SEG1:                                                       ; CODE XREF: ROM:06DDj
                        out     (0x80), a                       ; STRB_SET_PORT
                        call    CONT_READ
                        ld      d, a
                        out     (0xC0), a                       ; STRB_RST_PORT
                        and     #0xF                            ; KBD_MASK
                        ld      hl, #DEC_KBD_TBL
                        ld      b, #0
                        ld      c, a
                        add     hl, bc
                        ld      l, (hl)
                        ld      a, d
                        and     #0x40 ; '@'                     ; ARM_MASK
                        ld      h, a
                        ret
; ---------------------------------------------------------------------------

DECODER_:                                                       ; DATA XREF: ROM:DECODERo
                        ld      a, l
                        cp      #1                              ; STROBE_SET
                        jr      Z, DEC_SEG1
                        ld      bc, #SPIN_SW0_CT
                        ld      a, h
                        cp      #0
                        jr      Z, DEC_PLYR
                        inc     bc

DEC_PLYR:                                                       ; CODE XREF: ROM:06E5j
                        ld      a, (bc)
                        ld      e, a
                        xor     a
                        ld      (bc), a
                        call    CONT_READ
                        ld      d, a
                        and     #0xF                            ; JOY_MASK
                        ld      l, a
                        ld      a, d
                        and     #0x40 ; '@'                     ; FIRE_MASK
                        ld      h, a
                        ret
; ---------------------------------------------------------------------------

UPDATE_R1:                                                      ; CODE XREF: ROM:0703j
                        inc     (hl)

UPDATE_SPINX:                                                   ; CODE XREF: ROM:0706j
                        ret
; ---------------------------------------------------------------------------

UPDATE_R0:                                                      ; CODE XREF: ROM:0713j
                        inc     (hl)

UPDATE_S1:                                                      ; CODE XREF: ROM:070Fj
                                                                ; ROM:0716j
                        in      a, (0xFF)                       ; CTRL_1_PORT
                        bit     4, a
                        ret     NZ
                        inc     hl
                        bit     5, a
                        jr      NZ, UPDATE_R1
                        dec     (hl)
                        jr      UPDATE_SPINX
; ---------------------------------------------------------------------------

UPDATE_SPINNER_:                                                ; DATA XREF: ROM:UPDATE_SPINNERo
                        in      a, (0xFC)                       ; CTRL_0_PORT
                        ld      hl, #SPIN_SW0_CT
                        bit     4, a
                        jr      NZ, UPDATE_S1
                        bit     5, a
                        jr      NZ, UPDATE_R0
                        dec     (hl)
                        jr      UPDATE_S1

; =============== S U B R O U T I N E =======================================


CONT_SCAN:                                                      ; CODE XREF: ROM:POLLER_p
                                                                ; DATA XREF: ROM:CONTROLLER_SCANo
                        in      a, (0xFC)                       ; CTRL_0_PORT
                        cpl
                        ld      (S0_C0), a
                        in      a, (0xFF)                       ; CTRL_1_PORT
                        cpl
                        ld      (S0_C1), a
                        out     (0x80), a                       ; STRB_SET_PORT
                        call    DELAY
                        in      a, (0xFC)                       ; CTRL_0_PORT
                        cpl
                        ld      (S1_C0), a
                        in      a, (0xFF)                       ; CTRL_1_PORT
                        cpl
                        ld      (S1_C1), a
                        out     (0xC0), a                       ; STRB_RST_PORT
                        ret
; End of function CONT_SCAN

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR CONT_READ

CONT_READ1:                                                     ; CODE XREF: CONT_READ+3j
                        in      a, (0xFF)                       ; CTRL_1_PORT

CONT_READX:                                                     ; CODE XREF: CONT_READ+7j
                        cpl
                        ret
; END OF FUNCTION CHUNK FOR CONT_READ

; =============== S U B R O U T I N E =======================================


CONT_READ:                                                      ; CODE XREF: ROM:06C5p
                                                                ; ROM:06ECp

; FUNCTION CHUNK AT 0738 SIZE 00000004 BYTES

                        ld      a, h
                        cp      #0                              ; CONTROLLER_0
                        jr      NZ, CONT_READ1
                        in      a, (0xFC)                       ; CTRL_0_PORT
                        jr      CONT_READX
; End of function CONT_READ


; =============== S U B R O U T I N E =======================================


DELAY:                                                          ; CODE XREF: CONT_SCAN+Ep
                        nop
                        ret
; End of function DELAY

; ---------------------------------------------------------------------------
; called from POWER_UP in the Colecovision BIOS
; - not called in this BIOS


CONTROLLER_INIT:
                        out     (0xC0), a
                        xor     a
                        ld      ix, (CONTROLLER_MAP)
                        inc     ix
                        inc     ix
                        ld      iy, #DBNCE_BUFF
                        ld      b, #0xA

CINIT1:                                                         ; CODE XREF: ROM:0768j
                        ld      0(ix), a
                        inc     ix
                        ld      0(iy), a
                        inc     iy
                        ld      0(iy), a
                        inc     iy
                        dec     b
                        jr      NZ, CINIT1
                        ld      (SPIN_SW0_CT), a
                        ld      (SPIN_SW1_CT), a
                        ld      (S0_C0), a
                        ld      (S0_C1), a
                        ld      (S1_C0), a
                        ld      (S1_C1), a
                        ret
; ---------------------------------------------------------------------------

SIGNAL_TRUE:                                                    ; CODE XREF: ROM:07B2j
                        bit     6, (hl)                         ; REPEAT
                        jr      NZ, SIGNAL_TRUE1
                        set     5, (hl)                         ; FREE

SIGNAL_TRUE1:                                                   ; CODE XREF: ROM:077Fj
                        res     7, (hl)                         ; DONE
                        ld      a, #1
                        or      a
                        ret
; ---------------------------------------------------------------------------
TEST_SIG_PARAM:         .dw 1                                   ; DATA XREF: ROM:TEST_SIGNALQo
                        .dw 1
; ---------------------------------------------------------------------------

TEST_SIGNALQ:                                                   ; DATA XREF: ROM:TEST_SIGNALPo
                        ld      bc, #TEST_SIG_PARAM
                        ld      de, #TEST_SIG_NUM
                        call    PARAM_
                        ld      a, (TEST_SIG_NUM)

TEST_SIGNAL_:                                                   ; DATA XREF: ROM:TEST_SIGNALo
                        ld      c, a
                        ld      hl, (TIMER_TABLE_BASE)
                        ld      b, a
                        ld      de, #3
                        or      a
                        jr      Z, SIGNAL_MATCH

TEST1:                                                          ; CODE XREF: ROM:07AAj
                        bit     4, (hl)                         ; EOT
                        jr      NZ, SIGNAL_FALSE
                        add     hl, de
                        dec     c
                        jr      NZ, TEST1

SIGNAL_MATCH:                                                   ; CODE XREF: ROM:07A2j
                        bit     5, (hl)                         ; FREE
                        jr      NZ, SIGNAL_FALSE
                        bit     7, (hl)                         ; DONE
                        jr      NZ, SIGNAL_TRUE

SIGNAL_FALSE:                                                   ; CODE XREF: ROM:07A6j
                                                                ; ROM:07AEj
                        xor     a
                        ret
; ---------------------------------------------------------------------------

MAKE_NEW_TIMER:                                                 ; CODE XREF: ROM:07C8j
                        push    de
                        push    hl
                        inc     hl
                        inc     hl
                        inc     hl
                        inc     b
                        ld      (hl), #0x30 ; '0'
                        ex      de, hl
                        pop     hl
                        res     4, (hl)                         ; EOT
                        ex      de, hl
                        pop     de
                        jr      TIMER1
; ---------------------------------------------------------------------------

NEXT_TIMER1:                                                    ; CODE XREF: ROM:0819j
                        bit     4, (hl)                         ; EOT
                        jr      NZ, MAKE_NEW_TIMER
                        inc     hl
                        inc     hl
                        inc     hl
                        inc     b
                        jr      TIMER1
; ---------------------------------------------------------------------------

NOT_A_LONG_REPEAT:                                              ; CODE XREF: ROM:07DEj
                        inc     hl
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d
                        inc     hl

INIT_TIMER_EXIT:                                                ; CODE XREF: ROM:07F9j
                                                                ; ROM:082Fj
                        pop     hl
                        res     5, (hl)
                        ld      a, b
                        ret
; ---------------------------------------------------------------------------

LONG_TIMER:                                                     ; CODE XREF: ROM:0824j
                        set     3, (hl)                         ; LONG
                        ld      a, c
                        or      a
                        jr      Z, NOT_A_LONG_REPEAT
                        push    de
                        ex      de, hl
                        ld      hl, (NEXT_TIMER_DATA_BYTE)
                        ex      de, hl
                        set     6, (hl)                         ; REPEAT
                        inc     hl
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d
                        ex      de, hl
                        pop     de
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d
                        inc     hl
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d
                        inc     hl
                        ld      (NEXT_TIMER_DATA_BYTE), hl
                        jr      INIT_TIMER_EXIT
; ---------------------------------------------------------------------------
REQUEST_SIG_PARAM:      .dw 2                                   ; DATA XREF: ROM:REQUEST_SIGNALQo
                        .dw 1
                        .dw 2
; ---------------------------------------------------------------------------

REQUEST_SIGNALQ:                                                ; DATA XREF: ROM:REQUEST_SIGNALPo
                        ld      bc, #REQUEST_SIG_PARAM
                        ld      de, # PARAM_AREA+5
                        call    PARAM_
                        ld      hl, (TIMER_LENGTH)
                        ld      a, (PARAM_AREA+5)

REQUEST_SIGNAL_:                                                ; DATA XREF: ROM:REQUEST_SIGNALo
                        ld      c, a
                        ex      de, hl
                        ld      hl, (TIMER_TABLE_BASE)
                        xor     a
                        ld      b, a

TIMER1:                                                         ; CODE XREF: ROM:07C4j
                                                                ; ROM:07CEj
                        bit     5, (hl)                         ; FREE
                        jr      Z, NEXT_TIMER1
                        push    hl
                        ld      a, (hl)
                        and     #0x10
                        or      #0x20 ; ' '
                        ld      (hl), a
                        xor     a
                        or      d
                        jr      NZ, LONG_TIMER
                        or      c
                        jr      Z, NOT_A_REPEAT_TIMER
                        set     6, (hl)                         ; REPEAT

NOT_A_REPEAT_TIMER:                                             ; CODE XREF: ROM:0827j
                        inc     hl
                        ld      (hl), e
                        inc     hl
                        ld      (hl), e
                        jr      INIT_TIMER_EXIT
; ---------------------------------------------------------------------------

MOVE_IT:                                                        ; CODE XREF: ROM:088Aj
                        ld      b, #0
                        or      a
                        pop     hl
                        pop     de
                        push    hl
                        ld      hl, (NEXT_TIMER_DATA_BYTE)
                        sbc     hl, de
                        ld      c, l
                        ld      l, e
                        ld      h, d
                        inc     hl
                        inc     hl
                        inc     hl
                        inc     hl
                        ldir
                        ld      bc, #8
                        sbc     hl, bc
                        ld      (NEXT_TIMER_DATA_BYTE), hl
                        pop     hl

FREE_EXIT:                                                      ; CODE XREF: ROM:086Cj
                                                                ; ROM:0879j ...
                        ret
; ---------------------------------------------------------------------------
FREE_SIG_PARAM:         .dw 1                                   ; DATA XREF: ROM:FREE_SIGNALQo
                        .dw 1
; ---------------------------------------------------------------------------

FREE_SIGNALQ:                                                   ; DATA XREF: ROM:FREE_SIGNALPo
                        ld      bc, #FREE_SIG_PARAM
                        ld      de, # PARAM_AREA+4
                        call    PARAM_
                        ld      a, (PARAM_AREA+4)

FREE_SIGNAL_:                                                   ; DATA XREF: ROM:FREE_SIGNALo
                        ld      c, a
                        ld      hl, (TIMER_TABLE_BASE)
                        ld      b, a
                        ld      de, #3
                        or      a
                        jr      Z, FREE_MATCH

FREE1:                                                          ; CODE XREF: ROM:0870j
                        bit     4, (hl)                         ; EOT
                        jr      NZ, FREE_EXIT
                        add     hl, de
                        dec     c
                        jr      NZ, FREE1

FREE_MATCH:                                                     ; CODE XREF: ROM:0868j
                        bit     5, (hl)                         ; FREE
                        ret     NZ
                        set     5, (hl)                         ; FREE
                        bit     6, (hl)                         ; REPEAT
                        jr      Z, FREE_EXIT
                        bit     3, (hl)                         ; LONG
                        jr      Z, FREE_EXIT

FREE_COUNTER_:
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        push    de
                        ld      hl, (TIMER_TABLE_BASE)
                        push    hl

NEXT:                                                           ; CODE XREF: ROM:08B5j
                        bit     4, (hl)                         ; EOT
                        jr      NZ, MOVE_IT
                        bit     5, (hl)                         ; FREE
                        jr      NZ, GET_NEXT
                        ld      a, (hl)
                        and     #0x48 ; 'H'
                        cp      #0x48 ; 'H'
                        jr      NZ, GET_NEXT
                        inc     hl
                        inc     hl
                        ld      a, (hl)
                        cp      d
                        jr      C, GET_NEXT
                        jr      NZ, SUBTRACT_4
                        dec     hl
                        ld      a, (hl)
                        cp      e
                        jr      C, GET_NEXT
                        ret     Z
                        inc     hl

SUBTRACT_4:                                                     ; CODE XREF: ROM:089Dj
                        ld      d, (hl)
                        dec     hl
                        ld      e, (hl)
                        dec     de
                        dec     de
                        dec     de
                        dec     de
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d

GET_NEXT:                                                       ; CODE XREF: ROM:088Ej
                                                                ; ROM:0895j ...
                        pop     hl
                        inc     hl
                        inc     hl
                        inc     hl
                        push    hl
                        jr      NEXT
; ---------------------------------------------------------------------------
INIT_TIMER_PARAM:       .dw 2                                   ; DATA XREF: ROM:INIT_TIMERQo
                        .dw 2
                        .dw 2
; ---------------------------------------------------------------------------

INIT_TIMERQ:                                                    ; DATA XREF: ROM:INIT_TIMERPo
                        ld      bc, #INIT_TIMER_PARAM
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      hl, (PARAM_AREA)
                        ld      de, (PARAM_AREA+2)

INIT_TIMER_:                                                    ; DATA XREF: ROM:INIT_TIMERo
                        ld      (TIMER_TABLE_BASE), hl
                        ld      (hl), #0x30 ; '0'
                        ex      de, hl
                        ld      (NEXT_TIMER_DATA_BYTE), hl
                        ret
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR DCR_TIMER

SAVE_2_BYTES:                                                   ; CODE XREF: DCR_TIMER-Fj
                                                                ; DCR_TIMER+10j
                        ld      (hl), d
                        dec     hl
                        ld      (hl), e
                        jr      TIMER_EXIT
; ---------------------------------------------------------------------------

DCR_S_MODE_TBL:                                                 ; CODE XREF: DCR_TIMER+3j
                        inc     hl
                        dec     (hl)
                        jr      NZ, TIMER_EXIT
                        pop     hl
                        push    hl
                        bit     6, (hl)
                        jr      Z, SET_DONE_BIT
                        inc     hl
                        inc     hl
                        ld      a, (hl)
                        dec     hl
                        ld      (hl), a
                        dec     hl
                        pop     hl
                        push    hl

SET_DONE_BIT:                                                   ; CODE XREF: DCR_TIMER-28j
                                                                ; DCR_TIMER-2j ...
                        set     7, (hl)                         ; DONE

TIMER_EXIT:                                                     ; CODE XREF: DCR_TIMER-32j
                                                                ; DCR_TIMER-2Ej
                        pop     hl
                        ret
; ---------------------------------------------------------------------------

DCR_L_RPT_TBL:                                                  ; CODE XREF: DCR_TIMER+7j
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        ex      de, hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        dec     de
                        ld      a, e
                        or      d
                        jr      NZ, SAVE_2_BYTES
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        dec     hl
                        dec     hl
                        ld      (hl), d
                        dec     hl
                        ld      (hl), e
                        pop     hl
                        push    hl
                        jr      SET_DONE_BIT
; END OF FUNCTION CHUNK FOR DCR_TIMER

; =============== S U B R O U T I N E =======================================


DCR_TIMER:                                                      ; CODE XREF: ROM:0937p

; FUNCTION CHUNK AT 08D7 SIZE 00000035 BYTES

                        push    hl
                        bit     3, (hl)                         ; LONG
                        jr      Z, DCR_S_MODE_TBL
                        bit     6, (hl)                         ; REPEAT
                        jr      NZ, DCR_L_RPT_TBL

DCR_L_MODE_TBL:
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        dec     de
                        ld      a, e
                        or      d
                        jr      NZ, SAVE_2_BYTES
                        pop     hl
                        push    hl
                        jr      SET_DONE_BIT
; End of function DCR_TIMER

; ---------------------------------------------------------------------------

RAND_GEN_:                                                      ; DATA XREF: ROM:RAND_GENo
                        ld      hl, (RAND_NUM)
                        ld      a, h
                        rrca
                        xor     h
                        rla
                        rr      l
                        rr      h
                        ld      (RAND_NUM), hl
                        ld      a, l
                        ret
; ---------------------------------------------------------------------------

TIME_MGR_:                                                      ; DATA XREF: ROM:TIME_MGRo
                        ld      hl, (TIMER_TABLE_BASE)

NEXT_TIMER0:                                                    ; CODE XREF: ROM:0940j
                        bit     5, (hl)                         ; FREE
                        call    Z, DCR_TIMER
                        bit     4, (hl)                         ; EOT
                        ret     NZ
                        inc     hl
                        inc     hl
                        inc     hl
                        jr      NEXT_TIMER0
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PUTOBJ_

PUTCOMPLEX:                                                     ; CODE XREF: DO_PUTOBJ+19j
                        push    bc
                        exx
                        ld      h, 3(ix)
                        ld      l, 2(ix)
                        ld      a, (hl)
                        inc     hl
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        exx
                        add     a, a
                        add     a, a
                        ld      e, a
                        ld      d, #0
                        inc     hl
                        add     hl, de
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        ld      h, b
                        ld      l, c
                        pop     bc
                        ld      a, c
                        ld      c, b
                        srl     a
                        srl     a
                        srl     a
                        srl     a
                        ld      b, a
                        push    bc
                        push    ix

LP1:                                                            ; CODE XREF: PUTOBJ_-B8Ej
                        push    hl
                        push    de
                        ld      l, 4(ix)
                        ld      h, 5(ix)
                        inc     ix
                        inc     ix
                        inc     hl
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        push    de
                        pop     iy
                        pop     de
                        pop     hl
                        ld      a, (hl)
                        bit     7, 0(iy)
                        jr      Z, TBL0
                        set     7, a

TBL0:                                                           ; CODE XREF: PUTOBJ_-BB2j
                        ld      0(iy), a
                        inc     hl
                        ld      a, (de)
                        exx
                        ld      l, a
                        ld      h, #0
                        add     hl, bc
                        ld      1(iy), l
                        ld      2(iy), h
                        exx
                        inc     de
                        ld      a, (de)
                        exx
                        ld      l, a
                        ld      h, #0
                        add     hl, de
                        ld      3(iy), l
                        ld      4(iy), h
                        exx
                        inc     de
                        djnz    LP1
                        pop     iy
                        ld      bc, #4
                        add     iy, bc
                        pop     de

LP2:                                                            ; CODE XREF: PUTOBJ_-B6Cj
                        ld      l, 0(iy)
                        ld      h, 1(iy)
                        inc     iy
                        inc     iy
                        push    hl
                        pop     ix
                        push    iy
                        push    de
                        ld      b, e
                        call    PUTOBJ_
                        pop     de
                        pop     iy
                        dec     d
                        jr      NZ, LP2
                        ret
; END OF FUNCTION CHUNK FOR PUTOBJ_
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR COM_PAT_COL

ELSE23:                                                         ; CODE XREF: COM_PAT_COL-6j
                        ld      c, #0

END23:                                                          ; CODE XREF: COM_PAT_COL-2j
                        ld      a, e
                        or      a
                        jr      Z, END24
                        ld      a, 0(ix)
                        and     c
                        or      b
                        ld      0(ix), a

END24:                                                          ; CODE XREF: COM_PAT_COL-52j
                        ld      a, h
                        or      a
                        jr      Z, END25
                        ld      a, 8(ix)
                        and     c
                        or      b
                        ld      8(ix), a

END25:                                                          ; CODE XREF: COM_PAT_COL-46j
                        ld      a, l
                        or      a
                        jr      Z, END26
                        ld      a, 0x10(ix)
                        and     c
                        or      b
                        ld      0x10(ix), a

END26:                                                          ; CODE XREF: COM_PAT_COL-3Aj
                        pop     ix
                        ret
; ---------------------------------------------------------------------------

ELSE18:                                                         ; CODE XREF: COM_PAT_COL+4j
                        or      a
                        jr      Z, END19
                        ld      0(ix), a

END19:                                                          ; CODE XREF: COM_PAT_COL-2Cj
                        ld      a, h
                        or      a
                        jr      Z, END20
                        ld      8(ix), a

END20:                                                          ; CODE XREF: COM_PAT_COL-25j
                        ld      a, l
                        or      a
                        jr      Z, END18
                        ld      0x10(ix), a

END18:                                                          ; CODE XREF: COM_PAT_COL-1Ej
                                                                ; COM_PAT_COL+1Aj
                        bit     7, 3(iy)
                        ret     Z
                        push    ix
                        ld      bc, #0x68 ; 'h'
                        add     ix, bc
                        ld      b, 2(iy)
                        bit     1, 3(iy)
                        jr      NZ, ELSE23
                        ld      c, #0xF
                        jr      END23
; END OF FUNCTION CHUNK FOR COM_PAT_COL

; =============== S U B R O U T I N E =======================================


COM_PAT_COL:                                                    ; CODE XREF: PUTOBJ_-64Ap

; FUNCTION CHUNK AT 09D7 SIZE 00000056 BYTES

                        bit     0, 3(iy)
                        jr      NZ, ELSE18
                        or      0(ix)
                        ld      0(ix), a
                        ld      a, h
                        or      8(ix)
                        ld      8(ix), a
                        ld      a, l
                        or      0x10(ix)
                        ld      0x10(ix), a
                        jr      END18
; End of function COM_PAT_COL

; ---------------------------------------------------------------------------
aTurnPowerOff:          .ascii 'TURN POWER OFF'                 ; DATA XREF: BOOT_UP+1B90o
aBeforeInsertingCartridge:.ascii 'BEFORE INSERTING CARTRIDGE'   ; DATA XREF: BOOT_UP+1B9Co
aOrExpansionModule_:    .ascii 'OR EXPANSION MODULE.'           ; DATA XREF: BOOT_UP+1BA8o
; <SPACE>!"#$%&'()*+,-./
SPACE:                  .db 0, 0, 0, 0, 0, 0, 0, 0              ; DATA XREF: LOAD_ASCII_+7o
                        .db 0x20, 0x20, 0x20, 0x20, 0x20, 0, 0x20, 0
                        .db 0x50, 0x50, 0x50, 0, 0, 0, 0, 0
                        .db 0x50, 0x50, 0xF8, 0x50, 0xF8, 0x50, 0x50, 0
                        .db 0x20, 0x78, 0xA0, 0x70, 0x28, 0xF0, 0x20, 0
                        .db 0xC0, 0xC8, 0x10, 0x20, 0x40, 0x98, 0x18, 0
                        .db 0x40, 0xA0, 0xA0, 0x40, 0xA8, 0x90, 0x68, 0
                        .db 0x20, 0x20, 0x20, 0, 0, 0, 0, 0
                        .db 0x20, 0x40, 0x80, 0x80, 0x80, 0x40, 0x20, 0
                        .db 0x20, 0x10, 8, 8, 8, 0x10, 0x20, 0
                        .db 0x20, 0xA8, 0x70, 0x20, 0x70, 0xA8, 0x20, 0
                        .db 0, 0x20, 0x20, 0xF8, 0x20, 0x20, 0, 0
                        .db 0, 0, 0, 0, 0x20, 0x20, 0x40, 0
                        .db 0, 0, 0, 0xF8, 0, 0, 0, 0
                        .db 0, 0, 0, 0, 0, 0, 0x20, 0
                        .db 0, 8, 0x10, 0x20, 0x40, 0x80, 0, 0
NUMBER_TBL:             .db 0x70, 0x88, 0x98, 0xA8, 0xC8, 0x88, 0x70, 0
                                                                ; DATA XREF: ROM:NUMBER_TABLEo
                        .db 0x20, 0x60, 0x20, 0x20, 0x20, 0x20, 0x70, 0
                        .db 0x70, 0x88, 8, 0x30, 0x40, 0x80, 0xF8, 0
                        .db 0xF8, 8, 0x10, 0x30, 8, 0x88, 0x70, 0
                        .db 0x10, 0x30, 0x50, 0x90, 0xF8, 0x10, 0x10, 0
                        .db 0xF8, 0x80, 0xF0, 8, 8, 0x88, 0x70, 0
                        .db 0x38, 0x40, 0x80, 0xF0, 0x88, 0x88, 0x70, 0
                        .db 0xF8, 8, 0x10, 0x20, 0x40, 0x40, 0x40, 0
                        .db 0x70, 0x88, 0x88, 0x70, 0x88, 0x88, 0x70, 0
                        .db 0x70, 0x88, 0x88, 0x78, 8, 0x10, 0xE0, 0
                        .db 0, 0, 0x20, 0, 0x20, 0, 0, 0
                        .db 0, 0, 0x20, 0, 0x20, 0x20, 0x40, 0
                        .db 0x10, 0x20, 0x40, 0x80, 0x40, 0x20, 0x10, 0
                        .db 0, 0, 0xF8, 0, 0xF8, 0, 0, 0
                        .db 0x40, 0x20, 0x10, 8, 0x10, 0x20, 0x40, 0
                        .db 0x70, 0x88, 0x10, 0x20, 0x20, 0, 0x20, 0
                        .db 0x70, 0x88, 0xA8, 0xB8, 0xB0, 0x80, 0x78, 0
ASCII_TBL:              .db 0x20, 0x50, 0x88, 0x88, 0xF8, 0x88, 0x88, 0
                                                                ; DATA XREF: ROM:ASCII_TABLEo
                        .db 0xF0, 0x88, 0x88, 0xF0, 0x88, 0x88, 0xF0, 0
                        .db 0x70, 0x88, 0x80, 0x80, 0x80, 0x88, 0x70, 0
                        .db 0xF0, 0x88, 0x88, 0x88, 0x88, 0x88, 0xF0, 0
                        .db 0xF8, 0x80, 0x80, 0xF0, 0x80, 0x80, 0xF8, 0
                        .db 0xF8, 0x80, 0x80, 0xF0, 0x80, 0x80, 0x80, 0
                        .db 0x78, 0x80, 0x80, 0x80, 0x98, 0x88, 0x78, 0
                        .db 0x88, 0x88, 0x88, 0xF8, 0x88, 0x88, 0x88, 0
                        .db 0x70, 0x20, 0x20, 0x20, 0x20, 0x20, 0x70, 0
                        .db 8, 8, 8, 8, 8, 0x88, 0x70, 0
                        .db 0x88, 0x90, 0xA0, 0xC0, 0xA0, 0x90, 0x88, 0
                        .db 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0xF8, 0
                        .db 0x88, 0xD8, 0xA8, 0xA8, 0x88, 0x88, 0x88, 0
                        .db 0x88, 0x88, 0xC8, 0xA8, 0x98, 0x88, 0x88, 0
                        .db 0x70, 0x88, 0x88, 0x88, 0x88, 0x88, 0x70, 0
                        .db 0xF0, 0x88, 0x88, 0xF0, 0x80, 0x80, 0x80, 0
                        .db 0x70, 0x88, 0x88, 0x88, 0xA8, 0x90, 0x68, 0
                        .db 0xF0, 0x88, 0x88, 0xF0, 0xA0, 0x90, 0x88, 0
                        .db 0x70, 0x88, 0x80, 0x70, 8, 0x88, 0x70, 0
                        .db 0xF8, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0
                        .db 0x88, 0x88, 0x88, 0x88, 0x88, 0x88, 0x70, 0
                        .db 0x88, 0x88, 0x88, 0x88, 0x88, 0x50, 0x20, 0
                        .db 0x88, 0x88, 0x88, 0xA8, 0xA8, 0xD8, 0x88, 0
                        .db 0x88, 0x88, 0x50, 0x20, 0x50, 0x88, 0x88, 0
                        .db 0x88, 0x88, 0x50, 0x20, 0x20, 0x20, 0x20, 0
                        .db 0xF8, 8, 0x10, 0x20, 0x40, 0x80, 0xF8, 0
                        .db 0xF8, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xF8, 0
                        .db 0, 0x80, 0x40, 0x20, 0x10, 8, 0, 0
                        .db 0xF8, 0x18, 0x18, 0x18, 0x18, 0x18, 0xF8, 0
                        .db 0, 0, 0x20, 0x50, 0x88, 0, 0, 0
                        .db 0, 0, 0, 0, 0, 0, 0, 0xF8
                        .db 0x40, 0x20, 0x10, 0, 0, 0, 0, 0
                        .db 0, 0, 0x70, 0x88, 0xF8, 0x88, 0x88, 0
                        .db 0, 0, 0xF0, 0x48, 0x70, 0x48, 0xF0, 0
                        .db 0, 0, 0x78, 0x80, 0x80, 0x80, 0x78, 0
                        .db 0, 0, 0xF0, 0x48, 0x48, 0x48, 0xF0, 0
                        .db 0, 0, 0xF0, 0x80, 0xE0, 0x80, 0xF0, 0
                        .db 0, 0, 0xF0, 0x80, 0xE0, 0x80, 0x80, 0
                        .db 0, 0, 0x78, 0x80, 0xB8, 0x88, 0x70, 0
                        .db 0, 0, 0x88, 0x88, 0xF8, 0x88, 0x88, 0
                        .db 0, 0, 0xF8, 0x20, 0x20, 0x20, 0xF8, 0
                        .db 0, 0, 0x70, 0x20, 0x20, 0xA0, 0xE0, 0
                        .db 0, 0, 0x90, 0xA0, 0xC0, 0xA0, 0x90, 0
                        .db 0, 0, 0x80, 0x80, 0x80, 0x80, 0xF8, 0
                        .db 0, 0, 0x88, 0xD8, 0xA8, 0x88, 0x88, 0
                        .db 0, 0, 0x88, 0xC8, 0xA8, 0x98, 0x88, 0
                        .db 0, 0, 0xF8, 0x88, 0x88, 0x88, 0xF8, 0
                        .db 0, 0, 0xF0, 0x88, 0xF0, 0x80, 0x80, 0
                        .db 0, 0, 0xF8, 0x88, 0xA8, 0x90, 0xE0, 0
                        .db 0, 0, 0xF8, 0x88, 0xF8, 0xA0, 0x90, 0
                        .db 0, 0, 0x78, 0x80, 0x70, 8, 0xF0, 0
                        .db 0, 0, 0xF8, 0x20, 0x20, 0x20, 0x20, 0
                        .db 0, 0, 0x88, 0x88, 0x88, 0x88, 0x70, 0
                        .db 0, 0, 0x88, 0x88, 0x90, 0xA0, 0x40, 0
                        .db 0, 0, 0x88, 0x88, 0xA8, 0xD8, 0x88, 0
                        .db 0, 0, 0x88, 0x60, 0x20, 0x60, 0x88, 0
                        .db 0, 0, 0x88, 0x50, 0x20, 0x20, 0x20, 0
                        .db 0, 0, 0xF8, 0x10, 0x20, 0x40, 0xF8, 0
                        .db 0x38, 0x40, 0x20, 0xC0, 0x20, 0x40, 0x38, 0
                        .db 0x40, 0x20, 0x10, 8, 0x10, 0x20, 0x40, 0
                        .db 0xE0, 0x10, 0x20, 0x18, 0x20, 0x10, 0xE0, 0
                        .db 0x40, 0xA8, 0x10, 0, 0, 0, 0, 0
                        .db 0xA8, 0x50, 0xA8, 0x50, 0xA8, 0x50, 0xA8, 0
; ---------------------------------------------------------------------------

vector_to_BIOS_routine:                                         ; CODE XREF: ROM:0043j
                        ld      bc, #52                         ; number of routines

find_address_loop:                                              ; CODE XREF: ROM:0D8Fj
                        cp      l
                        jr      Z, execute_routine
                        dec     l
                        dec     l
                        dec     l                               ; next jump table address
                        dec     c                               ; next (previous routine)
                        jp      P, find_address_loop
                        jp      RST_38H_exit                    ; invalid routine - exit
; ---------------------------------------------------------------------------

execute_routine:                                                ; CODE XREF: ROM:0D89j
                        pop     hl
                        ld      hl, #RAND_GEN                   ; start of ROM address table
                        add     hl, bc
                        add     hl, bc                          ; find routine address
                        ld      a, (hl)
                        inc     hl
                        ld      h, (hl)
                        ld      l, a                            ; transfer to HL
                        pop     af
                        pop     bc
                        ex      (sp), hl                        ; swap return address for routine address
                        ret                                     ; execute routine
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PUTOBJ_

AD_EXIT:                                                        ; CODE XREF: PUTOBJ_-70Aj
                        ld      iy, (WORK_BUFFER)
                        ld      a, 0x12(iy)
                        add     a, b
                        cp      #0x18
                        jr      NC, END15
                        srl     a
                        srl     a
                        srl     a
                        ld      d, a
                        ld      e, c
                        push    de
                        ld      bc, #0x1C
                        add     hl, bc
                        ld      bc, (WORK_BUFFER)
                        add     hl, bc
                        push    hl
                        ld      iy, #3
                        ld      a, #3
                        call    PUT_VRAM_
                        pop     hl
                        ld      de, #0x68 ; 'h'
                        add     hl, de
                        pop     de
                        ld      iy, #3
                        ld      a, #4
                        call    PUT_VRAM_

END15:                                                          ; CODE XREF: PUTOBJ_-793j
                        pop     bc
                        inc     b
                        ld      a, b
                        cp      #3
                        jr      NZ, RPT2

END04:                                                          ; CODE XREF: PUTOBJ_-6DDj
                        ld      iy, (WORK_BUFFER)
                        ld      b, 6(iy)
                        ld      a, b
                        cp      #0x80 ; '€'
                        jr      Z, END16
                        ld      c, 7(iy)
                        ld      h, 0x11(iy)
                        ld      l, 0x12(iy)
                        or      a
                        sbc     hl, bc
                        jr      Z, END16
                        ld      hl, (WORK_BUFFER)
                        ld      de, #8
                        add     hl, de
                        ld      e, 6(iy)
                        ld      d, 7(iy)
                        ld      bc, #0x303
                        call    PUT_FRAME

END16:                                                          ; CODE XREF: PUTOBJ_-755j
                                                                ; PUTOBJ_-747j
                        ld      iy, (WORK_BUFFER)
                        ld      hl, (WORK_BUFFER)
                        ld      de, #0x13
                        add     hl, de
                        ld      e, 0x11(iy)
                        ld      d, 0x12(iy)
                        ld      bc, #0x303
                        call    PUT_FRAME
                        ret
; ---------------------------------------------------------------------------

ELSE04:                                                         ; CODE XREF: PUTOBJ_-6B1j
                        ld      b, #0

RPT2:                                                           ; CODE XREF: PUTOBJ_-761j
                        push    bc
                        ld      a, c
                        add     a, b
                        add     a, b
                        add     a, b
                        ld      c, a
                        ld      hl, #0
                        ld      de, #0x18
                        ld      a, b

AD_LP:                                                          ; CODE XREF: PUTOBJ_-706j
                        dec     a
                        jp      M, AD_EXIT
                        add     hl, de
                        jr      AD_LP
; ---------------------------------------------------------------------------

DVEX:                                                           ; CODE XREF: PUTOBJ_-670j
                        add     a, 0x11(iy)
                        cp      #0x20 ; ' '
                        jr      NC, NOTOS
                        ld      a, b
                        add     a, 0x12(iy)
                        cp      #0x18
                        jr      NC, NOTOS
                        push    ix
                        push    hl
                        ld      a, #4
                        ld      iy, #1
                        call    PUT_VRAM_
                        pop     hl
                        pop     ix

NOTOS:                                                          ; CODE XREF: PUTOBJ_-6FFj
                                                                ; PUTOBJ_-6F7j
                        pop     bc
                        inc     hl
                        inc     de
                        dec     b
                        ld      a, b
                        cp      #0
                        jr      NZ, RPT1
                        jp      END04
; ---------------------------------------------------------------------------

ELSE13:                                                         ; CODE XREF: PUTOBJ_-653j
                        ld      c, #0

END13:                                                          ; CODE XREF: PUTOBJ_-64Ej
                        ld      b, #9

DLP5:                                                           ; CODE XREF: PUTOBJ_-6D1j
                        ld      a, (hl)
                        and     c
                        or      d
                        ld      (hl), a
                        inc     hl
                        djnz    DLP5

END12:                                                          ; CODE XREF: PUTOBJ_-663j
                        ld      a, 5(iy)
                        bit     7, 4(iy)
                        jr      Z, END14
                        add     a, #9

END14:                                                          ; CODE XREF: PUTOBJ_-6C8j
                        ld      c, a
                        ld      hl, (WORK_BUFFER)
                        ld      de, #0x13
                        add     hl, de
                        ld      b, #9

DLP6:                                                           ; CODE XREF: PUTOBJ_-6B7j
                        ld      (hl), a
                        inc     a
                        inc     hl
                        djnz    DLP6

PM12:
                        bit     7, 3(iy)
                        jr      NZ, ELSE04
                        ld      e, c
                        ld      d, #0
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #0x1C
                        add     hl, bc
                        ld      iy, #9
                        ld      a, #3
                        call    PUT_VRAM_
                        ld      iy, (WORK_BUFFER)
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #0x84 ; '„'
                        add     hl, bc
                        ld      ix, (WORK_BUFFER)
                        ld      bc, #0x13
                        add     ix, bc
                        ld      b, #9

RPT1:                                                           ; CODE XREF: PUTOBJ_-6DFj
                        ld      a, 0(ix)
                        inc     ix
                        srl     a
                        srl     a
                        srl     a
                        ld      e, a
                        ld      d, #0
                        push    bc
                        ld      a, #9
                        sub     b
                        ld      b, #0

DVLP:                                                           ; CODE XREF: PUTOBJ_-66Aj
                        cp      #3
                        jp      C, DVEX
                        sub     #3
                        inc     b
                        jr      DVLP
; ---------------------------------------------------------------------------

C_LP_EXIT:                                                      ; CODE XREF: PUTOBJ_-62Fj
                        pop     hl
                        bit     7, 3(iy)
                        jr      NZ, END12
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #0x84 ; '„'
                        add     hl, bc
                        ld      d, 2(iy)
                        bit     1, 3(iy)
                        jp      NZ, ELSE13
                        ld      c, #0xF
                        jp      END13
; ---------------------------------------------------------------------------

SHFEX:                                                          ; CODE XREF: PUTOBJ_-5F1j
                        ld      e, a
                        call    COM_PAT_COL
                        ld      a, 0(iy)
                        inc     a
                        ld      0(iy), a
                        cp      #8
                        jr      Z, IF11
                        cp      #0x10
                        jr      NZ, END11

IF11:                                                           ; CODE XREF: PUTOBJ_-63Ej
                        ld      bc, #0x10
                        add     ix, bc

END11:                                                          ; CODE XREF: PUTOBJ_-63Aj
                        inc     ix
                        ex      af, af'
                        dec     a
                        jr      Z, C_LP_EXIT
                        ex      af, af'
                        jr      COMBINE_LOOP
; ---------------------------------------------------------------------------

ELSE10:                                                         ; CODE XREF: PUTOBJ_-5D9j
                        ex      de, hl
                        push    bc
                        ld      bc, #8
                        ldir
                        pop     bc
                        ex      de, hl

END9:                                                           ; CODE XREF: PUTOBJ_-5C5j
                                                                ; PUTOBJ_-58Aj
                        pop     de
                        inc     de
                        djnz    DLP4

PM11:
                        ld      iy, (WORK_BUFFER)
                        ld      de, (WORK_BUFFER)
                        ld      hl, #0x1C
                        add     hl, de
                        ld      c, 0(iy)
                        ld      b, #0
                        add     hl, bc
                        push    hl
                        pop     ix
                        ld      hl, #0x64 ; 'd'
                        add     hl, de
                        push    hl
                        ld      a, #0x10
                        ex      af, af'

COMBINE_LOOP:                                                   ; CODE XREF: PUTOBJ_-62Cj
                        pop     hl
                        ld      d, (hl)
                        inc     hl
                        push    hl
                        ld      bc, #0xF
                        add     hl, bc
                        ld      e, (hl)
                        ex      de, hl
                        ld      b, 1(iy)
                        xor     a

SHFLP:                                                          ; CODE XREF: PUTOBJ_-5ECj
                        dec     b
                        jp      M, SHFEX
                        add     hl, hl
                        rla
                        jr      SHFLP
; ---------------------------------------------------------------------------

ELSE9:                                                          ; CODE XREF: PUTOBJ_-5A0j
                        sub     1(ix)
                        exx
                        add     a, a
                        add     a, a
                        add     a, a
                        ld      l, a
                        ld      h, #0
                        add     hl, de
                        push    hl
                        exx
                        pop     de
                        ld      a, d
                        cp      #0x70 ; 'p'
                        jr      NC, ELSE10
                        push    bc
                        push    hl
                        push    de
                        ld      bc, #8
                        call    VRAM_READ
                        ld      bc, #8
                        pop     hl
                        add     hl, bc
                        ex      de, hl
                        pop     hl
                        add     hl, bc
                        pop     bc
                        jr      END9
; ---------------------------------------------------------------------------

ELSE8:                                                          ; CODE XREF: PUTOBJ_-52Aj
                        ex      de, hl
                        ldir

END8:                                                           ; CODE XREF: PUTOBJ_-524j
                        ld      iy, (WORK_BUFFER)
                        pop     bc
                        add     iy, bc
                        ld      a, 4(iy)
                        ld      iy, (WORK_BUFFER)
                        ld      2(iy), a
                        pop     de
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #0x64 ; 'd'
                        add     hl, bc
                        ld      b, #4

DLP4:                                                           ; CODE XREF: PUTOBJ_-61Fj
                        ld      a, (de)
                        cp      1(ix)
                        push    de
                        jr      NC, ELSE9
                        exx
                        add     a, a
                        add     a, a
                        add     a, a
                        ld      l, a
                        ld      h, #0
                        add     hl, bc
                        push    hl
                        exx
                        pop     de
                        ex      de, hl
                        push    bc
                        ld      bc, #8
                        ldir
                        pop     bc
                        ex      de, hl
                        jp      END9
; ---------------------------------------------------------------------------

ELSE6:                                                          ; CODE XREF: PUTOBJ_:PM6j
                        sra     a
                        sra     a
                        sra     a

PM7:
                        cp      #3
                        jr      NC, END6
                        ld      d, a
                        push    de
                        push    hl
                        ld      a, #3
                        call    GET_VRAM_
                        pop     hl
                        ld      de, #0x68 ; 'h'
                        add     hl, de
                        pop     de
                        ld      iy, #1
                        ld      a, #4
                        call    GET_VRAM_

END6:                                                           ; CODE XREF: PUTOBJ_-57Fj
                                                                ; PUTOBJ_-4E8j
                        pop     bc
                        pop     hl
                        pop     de
                        dec     b
                        jp      NZ, DLP2
                        pop     ix
                        exx
                        ld      d, 3(ix)
                        ld      e, 2(ix)
                        ld      b, 5(ix)
                        ld      c, 4(ix)
                        exx
                        push    ix
                        pop     hl
                        ld      iy, (WORK_BUFFER)
                        ld      a, 4(iy)
                        add     a, a
                        ld      c, a
                        ld      b, #0
                        ld      de, #6
                        add     hl, de
                        add     hl, bc
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #0x7C ; '|'
                        add     hl, bc
                        push    hl
                        push    bc
                        ld      bc, #5
                        ld      a, d
                        cp      #0x70 ; 'p'
                        jp      NC, ELSE8
                        call    VRAM_READ
                        jp      END8
; ---------------------------------------------------------------------------

PM51:                                                           ; CODE XREF: PUTOBJ_-4BFj
                        ld      a, b
                        ld      iy, (WORK_BUFFER)
                        add     a, 0x12(iy)
                        bit     7, 3(iy)
                        ld      iy, #1

PM6:
                        jr      NZ, ELSE6
                        ld      a, #3
                        call    GET_VRAM_
                        pop     bc
                        ld      hl, (WORK_BUFFER)
                        push    bc
                        ld      de, #0x84 ; '„'
                        add     hl, de
                        ld      e, c
                        srl     e
                        srl     e
                        srl     e
                        ld      d, #0
                        ld      a, #9
                        sub     b
                        ld      c, a
                        ld      b, #0
                        add     hl, bc
                        ld      iy, #1
                        ld      a, #4
                        call    GET_VRAM_
                        jr      END6
; ---------------------------------------------------------------------------

ELSE5:                                                          ; CODE XREF: PUTOBJ_-476j
                        ldir

END5:                                                           ; CODE XREF: PUTOBJ_-471j
                        push    ix
                        ld      de, (WORK_BUFFER)
                        ld      hl, #0x13
                        add     hl, de
                        ex      de, hl
                        ld      bc, #0x14
                        add     hl, bc
                        ld      b, #9

DLP2:                                                           ; CODE XREF: PUTOBJ_-562j
                        ld      a, (de)
                        inc     de
                        push    de
                        ld      de, #8
                        add     hl, de
                        push    hl
                        ld      e, a
                        ld      d, #0
                        ld      c, a
                        push    bc
                        ld      a, #9
                        sub     b
                        ld      b, #0

PM52:                                                           ; CODE XREF: PUTOBJ_-4BBj
                        sub     #3
                        jp      C, PM51
                        inc     b
                        jr      PM52
; ---------------------------------------------------------------------------

ELSE2:                                                          ; CODE XREF: PUTOBJ_-405j
                        ex      de, hl
                        ldir

END2:                                                           ; CODE XREF: PUTOBJ_-3FFj
                        ld      hl, (WORK_BUFFER)
                        ld      de, #0x13
                        add     hl, de
                        exx
                        ld      de, (WORK_BUFFER)
                        ld      hl, #8
                        add     hl, de
                        ex      de, hl
                        exx
                        ld      iy, (WORK_BUFFER)
                        ld      c, 5(iy)
                        ld      b, #9

DLP1:                                                           ; CODE XREF: PUTOBJ_-486j
                        ld      a, (hl)
                        sub     c
                        cp      #0x12
                        jr      NC, END3
                        cp      #9
                        jr      C, END4
                        sub     #9

END4:                                                           ; CODE XREF: PUTOBJ_-493j
                        exx
                        ld      l, a
                        ld      h, #0
                        add     hl, de
                        ld      a, (hl)
                        exx
                        ld      (hl), a

END3:                                                           ; CODE XREF: PUTOBJ_-497j
                        inc     hl
                        djnz    DLP1
                        pop     de
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #0x11
                        add     hl, bc
                        ld      bc, #0xB
                        ld      a, d
                        cp      #0x70 ; 'p'
                        jr      NC, ELSE5
                        call    VRAM_WRITE
                        jr      END5
; ---------------------------------------------------------------------------

ELSE1:                                                          ; CODE XREF: PUTOBJ_-3F3j
                        set     7, b

END1:                                                           ; CODE XREF: PUTOBJ_-3EFj
                        ld      3(iy), b
                        push    hl
                        ld      h, 3(ix)
                        ld      l, 2(ix)
                        ld      a, (hl)
                        ld      4(iy), a
                        xor     #0x80 ; '€'
                        ld      (hl), a
                        inc     hl
                        ld      e, (hl)
                        ld      a, e
                        and     #7
                        neg
                        add     a, #8
                        ld      1(iy), a
                        inc     hl
                        ld      d, (hl)
                        call    PX_TO_PTRN_POS
                        ld      0x11(iy), e
                        inc     hl
                        ld      e, (hl)
                        ld      a, e
                        and     #7
                        ld      0(iy), a
                        inc     hl
                        ld      d, (hl)
                        call    PX_TO_PTRN_POS
                        ld      0x12(iy), e
                        ld      hl, (WORK_BUFFER)
                        ld      de, #0x13
                        add     hl, de
                        ld      d, 0x12(iy)
                        ld      e, 0x11(iy)
                        ld      bc, #0x303
                        call    GET_BKGRND
                        ld      d, 5(ix)
                        ld      e, 4(ix)
                        ld      a, 6(ix)
                        pop     ix
                        ld      iy, (WORK_BUFFER)
                        ld      5(iy), a
                        push    de
                        ld      hl, (WORK_BUFFER)
                        ld      bc, #6
                        add     hl, bc
                        ld      bc, #0xB
                        ld      a, d
                        cp      #0x70 ; 'p'
                        jp      NC, ELSE2
                        call    VRAM_READ
                        jp      END2
; ---------------------------------------------------------------------------

PUT_MOBILE:                                                     ; CODE XREF: DO_PUTOBJ+Ej
                        ld      iy, (WORK_BUFFER)
                        ld      a, (VDP_MODE_WORD)
                        bit     1, a
                        jr      NZ, ELSE1
                        res     7, b
                        jr      END1
; ---------------------------------------------------------------------------

DONT_PUT:                                                       ; CODE XREF: PUTOBJ_-31Fj
                                                                ; PUTOBJ_-319j ...
                        push    iy
                        push    ix
                        push    iy
                        push    iy
                        xor     a
                        ld      d, #0
                        ld      e, 4(ix)
                        pop     hl
                        ld      iy, #1
                        call    GET_VRAM_
                        xor     a
                        pop     iy
                        ld      1(iy), a
                        set     7, a
                        ld      3(iy), a
                        xor     a
                        ld      d, a
                        pop     ix
                        ld      e, 4(ix)
                        pop     hl
                        ld      iy, #1
                        call    PUT_VRAM_
                        ret
; ---------------------------------------------------------------------------

CONTINUE:                                                       ; CODE XREF: PUTOBJ_-2FFj
                                                                ; PUTOBJ_-2C0j
                        ld      l, 2(ix)
                        ld      h, 3(ix)
                        ld      de, #1
                        add     hl, de
                        ld      a, (hl)
                        ld      1(iy), a
                        ld      l, 0(ix)
                        ld      h, 1(ix)
                        ld      de, #5
                        add     hl, de
                        ex      de, hl
                        ld      a, (de)
                        ld      l, a
                        inc     de
                        ld      a, (de)
                        ld      h, a
                        push    hl
                        ld      l, 2(ix)
                        ld      h, 3(ix)
                        ld      de, #0
                        add     hl, de
                        ld      a, (hl)
                        sla     a
                        ld      b, #0
                        ld      c, a
                        pop     hl
                        add     hl, bc
                        ld      a, (hl)
                        ld      3(iy), a

PUT_Y_AND_NAME:                                                 ; CODE XREF: PUTOBJ_-28Dj
                        ld      l, 2(ix)
                        ld      h, 3(ix)
                        ld      de, #3
                        add     hl, de
                        ld      a, (hl)
                        ld      0(iy), a
                        ld      l, 0(ix)
                        ld      h, 1(ix)
                        ld      de, #5
                        add     hl, de
                        ex      de, hl
                        ld      a, (de)
                        ld      l, a
                        inc     de
                        ld      a, (de)
                        ld      h, a
                        push    hl
                        ld      l, 2(ix)
                        ld      h, 3(ix)
                        ld      de, #0
                        add     hl, de
                        ld      a, (hl)
                        sla     a
                        ld      b, #0
                        ld      c, a
                        pop     hl
                        add     hl, bc
                        inc     hl
                        ld      a, (hl)
                        ld      l, 0(ix)
                        ld      h, 1(ix)
                        ld      de, #1
                        add     hl, de
                        add     a, (hl)
                        ld      2(iy), a
                        xor     a
                        ld      d, a
                        ld      e, 4(ix)
                        push    iy
                        pop     hl
                        ld      iy, #1
                        call    PUT_VRAM_
                        ret
; ---------------------------------------------------------------------------

PUT1SPRITE:                                                     ; CODE XREF: DO_PUTOBJ+16j
                        ld      iy, (WORK_BUFFER)
                        ld      l, 2(ix)
                        ld      h, 3(ix)
                        ld      de, #1
                        add     hl, de
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        ld      a, b
                        or      a
                        jr      Z, OK__3
                        cp      #0xFF
                        jp      NZ, DONT_PUT
                        ld      a, c
                        cp      #0xE1 ; 'á'
                        jp      M, DONT_PUT

OK__3:                                                          ; CODE XREF: PUTOBJ_-323j
                        inc     hl
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        ld      a, b
                        or      a
                        jr      Z, OK__4
                        cp      #0xFF
                        jp      NZ, DONT_PUT
                        ld      a, c
                        cp      #0xE1 ; 'á'
                        jp      M, DONT_PUT

OK__4:                                                          ; CODE XREF: PUTOBJ_-310j
                        dec     hl
                        dec     hl
                        ld      a, (hl)
                        or      a
                        jp      Z, CONTINUE
                        ld      b, (hl)
                        dec     hl
                        ld      c, (hl)
                        ld      hl, #32
                        jr      OK__4_cont
; ---------------------------------------------------------------------------

PUT0SPRITE:                                                     ; CODE XREF: DO_PUTOBJ+12j
                        ld      iy, (WORK_BUFFER)
                        ld      l, 2(ix)                        ; STATUS
                        ld      h, 3(ix)                        ; STATUS+1
                        inc     hl
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        ld      a, b
                        or      a
                        jr      Z, OK__1
                        cp      #0xFF
                        jp      NZ, DONT_PUT
                        ld      a, c
                        cp      #0xF9 ; 'ù'
                        jp      M, DONT_PUT

OK__1:                                                          ; CODE XREF: PUTOBJ_-2E4j
                        inc     hl
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        ld      a, b
                        or      a
                        jr      Z, OK__2
                        cp      #0xFF
                        jp      NZ, DONT_PUT
                        ld      a, c
                        cp      #0xF9 ; 'ù'
                        jp      M, DONT_PUT

OK__2:                                                          ; CODE XREF: PUTOBJ_-2D1j
                        dec     hl
                        dec     hl
                        ld      a, (hl)
                        or      a
                        jp      Z, CONTINUE
                        ld      b, (hl)
                        dec     hl
                        ld      c, (hl)
                        ld      hl, #8

OK__4_cont:                                                     ; CODE XREF: PUTOBJ_-2F6j
                        add     hl, bc
                        ld      a, l
                        ld      1(iy), a
                        ld      l, 0(ix)
                        ld      h, 1(ix)
                        ld      de, #5
                        add     hl, de
                        ex      de, hl
                        ld      a, (de)
                        ld      l, a
                        inc     de
                        ld      a, (de)
                        ld      h, a
                        push    hl
                        ld      l, 2(ix)                        ; STATUS
                        ld      h, 3(ix)                        ; STATUS+1
                        ld      a, (hl)
                        sla     a
                        ld      b, #0
                        ld      c, a
                        pop     hl
                        add     hl, bc
                        ld      a, (hl)
                        or      #0x80 ; '€'
                        ld      3(iy), a                        ; COLOR_AND_TAG
                        jp      PUT_Y_AND_NAME
; END OF FUNCTION CHUNK FOR PUTOBJ_
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR CALC_OFFSET

ELSE_12:                                                        ; CODE XREF: CALC_OFFSET-6j
                        ld      d, #0

END_IF_12:                                                      ; CODE XREF: CALC_OFFSET-2j
                        add     hl, de
                        ex      de, hl
                        pop     hl
                        ret
; ---------------------------------------------------------------------------

ELSE11:                                                         ; CODE XREF: CALC_OFFSET+3j
                        ld      h, #0

END_IF_11:                                                      ; CODE XREF: CALC_OFFSET+7j
                        ld      l, d
                        add     hl, hl
                        add     hl, hl
                        add     hl, hl
                        add     hl, hl
                        add     hl, hl
                        bit     7, e
                        jr      Z, ELSE_12
                        ld      d, #0xFF
                        jr      END_IF_12
; END OF FUNCTION CHUNK FOR CALC_OFFSET

; =============== S U B R O U T I N E =======================================


CALC_OFFSET:                                                    ; CODE XREF: GET_BKGRNDp
                                                                ; PUT_FRAME+7p

; FUNCTION CHUNK AT 12B6 SIZE 00000016 BYTES

                        push    hl
                        bit     7, d
                        jr      Z, ELSE11
                        ld      h, #0xFF
                        jr      END_IF_11
; End of function CALC_OFFSET


; =============== S U B R O U T I N E =======================================


GET_BKGRND:                                                     ; CODE XREF: PUTOBJ_-428p
                                                                ; PUTOBJ_-D8p
                        call    CALC_OFFSET
                        push    bc
                        ld      b, #0
                        push    bc
                        pop     iy
                        pop     bc

RPT_2:                                                          ; CODE XREF: GET_BKGRND+24j
                        push    bc
                        push    de
                        push    hl
                        push    iy
                        ld      a, #2
                        call    GET_VRAM_
                        pop     iy
                        pop     hl
                        pop     de
                        pop     bc
                        push    bc
                        ld      b, #0
                        add     hl, bc
                        ld      bc, #0x20 ; ' '
                        ex      de, hl
                        add     hl, bc
                        ex      de, hl
                        pop     bc
                        djnz    RPT_2
                        ret
; End of function GET_BKGRND

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PUT_FRAME

ELSE_9:                                                         ; CODE XREF: PUT_FRAME-11j
                                                                ; PUT_FRAME-Fj
                        push    bc
                        ld      b, #0
                        push    bc
                        pop     iy
                        pop     bc

END_IF_9:                                                       ; CODE XREF: PUT_FRAME-2j
                                                                ; PUT_FRAME+3Bj
                        ld      e, #0

RPT_1:                                                          ; CODE XREF: PUT_FRAME-18j
                        ld      a, d
                        add     a, e
                        bit     7, a
                        jr      NZ, END_IF_10
                        cp      #0x18
                        jr      NC, END_IF_10
                        push    bc
                        push    de
                        exx
                        push    bc
                        push    de
                        push    hl
                        push    iy
                        ld      a, #2
                        call    PUT_VRAM_
                        pop     iy
                        pop     hl
                        pop     de
                        pop     bc
                        exx
                        pop     de
                        pop     bc

END_IF_10:                                                      ; CODE XREF: PUT_FRAME-43j
                                                                ; PUT_FRAME-3Fj
                        exx
                        push    bc
                        ld      b, #0
                        add     hl, bc
                        ex      de, hl
                        ld      bc, #0x20 ; ' '
                        add     hl, bc
                        ex      de, hl
                        pop     bc
                        exx
                        inc     e
                        ld      a, e
                        cp      b
                        jr      NZ, RPT_1
                        ret
; ---------------------------------------------------------------------------

ELSE_8:                                                         ; CODE XREF: PUT_FRAME+1Bj
                        ld      a, e
                        add     a, c
                        cp      #0x1F
                        jr      Z, ELSE_9
                        jr      C, ELSE_9
                        ld      a, #0x20 ; ' '
                        sub     e
                        push    de
                        ld      e, a
                        ld      d, #0
                        push    de
                        pop     iy
                        pop     de
                        jr      END_IF_9
; END OF FUNCTION CHUNK FOR PUT_FRAME

; =============== S U B R O U T I N E =======================================


PUT_FRAME:                                                      ; CODE XREF: PUTOBJ_-735p
                                                                ; PUTOBJ_-71Ep ...

; FUNCTION CHUNK AT 12FC SIZE 00000050 BYTES

                        push    bc
                        push    de
                        push    hl
                        exx
                        pop     hl
                        pop     de
                        pop     bc
                        call    CALC_OFFSET
                        exx
                        ld      a, e
                        bit     7, a
                        jr      NZ, XP_NEG
                        cp      #0x20 ; ' '
                        ret     NC

XP_NEG:                                                         ; CODE XREF: PUT_FRAME+Ej
                        add     a, c
                        bit     7, a
                        ret     NZ
                        or      a
                        ret     Z
                        bit     7, e
                        jr      Z, ELSE_8
                        ld      a, c
                        add     a, e
                        push    de
                        cp      #33
                        jr      C, LT33
                        ld      a, #32

LT33:                                                           ; CODE XREF: PUT_FRAME+22j
                        ld      e, a
                        ld      d, #0
                        push    de
                        pop     iy
                        pop     de
                        ld      a, e
                        exx
                        push    bc
                        neg
                        ld      c, a
                        ld      b, #0
                        add     hl, bc
                        ex      de, hl
                        add     hl, bc
                        ex      de, hl
                        pop     bc
                        exx
                        jp      END_IF_9
; End of function PUT_FRAME

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PX_TO_PTRN_POS

NEGTV:                                                          ; CODE XREF: PX_TO_PTRN_POS+Fj
                        ld      hl, #0x80 ; '€'
                        add     hl, de
                        pop     hl
                        ret     C
                        ld      e, #0x80 ; '€'
                        ret
; END OF FUNCTION CHUNK FOR PX_TO_PTRN_POS

; =============== S U B R O U T I N E =======================================


PX_TO_PTRN_POS:                                                 ; CODE XREF: PUTOBJ_-44Ep
                                                                ; PUTOBJ_-43Ep ...

; FUNCTION CHUNK AT 138A SIZE 00000009 BYTES

                        push    hl
                        sra     d
                        rr      e
                        sra     d
                        rr      e
                        sra     d
                        rr      e
                        bit     7, d
                        jr      NZ, NEGTV
                        ld      hl, #-128
                        add     hl, de
                        pop     hl
                        ret     NC
                        ld      e, #127
                        ret
; End of function PX_TO_PTRN_POS

; ---------------------------------------------------------------------------
aToSelectGameOp:        .ascii 'TO SELECT GAME OPTION,'         ; DATA XREF: ROM:0071o
aPressButtonOnK:        .ascii 'PRESS BUTTON ON KEYPAD.'        ; DATA XREF: ROM:007Do
a1Skill1OnePlay:        .ascii '1 = SKILL 1/ONE PLAYERS'        ; DATA XREF: ROM:0089o
aTwo:                   .ascii 'TWO'                            ; DATA XREF: ROM:00A7o
                        .db    3
                        .db    4
                        .db  0xE
                        .db  0xF
                        .db    5
                        .db 0x14
                        .db    0
                        .db    0
                        .db    5
                        .db    0
                        .db 0x10
                        .db 0x11
                        .db  0xA
                        .db  0xB
                        .db 0x15
                        .db 0x16
                        .db    6
                        .db    7
                        .db 0x10
                        .db 0x11
                        .db    5
                        .db 0x14
                        .db    0
                        .db    0
                        .db    1
                        .db    2
                        .db  0xE
                        .db  0xF
                        .db    3
                        .db    4
                        .db  0xE
                        .db  0xF
                        .db    3
                        .db    4
                        .db  0xE
                        .db  0xF
                        .db  0xC
                        .db  0xD
                        .db 0x17
                        .db 0x18
                        .db 0xFF
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PUTOBJ_

M_XY2:                                                          ; CODE XREF: PUTOBJ_:M_XY2_PLUS_1j
                        add     hl, hl

M_XY2_PLUS_1:                                                   ; CODE XREF: PUTOBJ_-B1j
                        djnz    M_XY2
                        push    hl
                        exx
                        pop     bc
                        pop     hl
                        jp      VRAM_WRITE
; ---------------------------------------------------------------------------

M_XY:                                                           ; CODE XREF: PUTOBJ_:M_XY_PLUS_1j
                        add     hl, hl

M_XY_PLUS_1:                                                    ; CODE XREF: PUTOBJ_-A6j
                        djnz    M_XY
                        push    hl
                        pop     bc
                        ex      de, hl
                        pop     de
                        inc     de
                        inc     de
                        inc     de
                        inc     de
                        call    VRAM_READ

SKIP_OLD:                                                       ; CODE XREF: PUTOBJ_-8Bj
                        pop     hl

END_IF_1:                                                       ; CODE XREF: PUTOBJ_-7Aj
                        ld      a, (hl)
                        cp      #0x80 ; '€'
                        jr      Z, END_IF_2
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        inc     hl
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        inc     hl
                        push    ix
                        call    PUT_FRAME
                        pop     ix

END_IF_2:                                                       ; CODE XREF: PUTOBJ_-107j
                        pop     hl
                        pop     de
                        pop     bc
                        push    bc
                        push    de
                        push    hl
                        ld      h, 5(ix)
                        ld      l, 4(ix)
                        ld      a, #0x70 ; 'p'
                        cp      h
                        jr      C, END_IF_3
                        ld      hl, (WORK_BUFFER)

END_IF_3:                                                       ; CODE XREF: PUTOBJ_-E7j
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d
                        inc     hl
                        ld      (hl), c
                        inc     hl
                        ld      (hl), b
                        inc     hl
                        push    ix
                        call    GET_BKGRND
                        pop     ix
                        pop     hl
                        pop     de
                        pop     bc
                        push    ix
                        call    PUT_FRAME
                        pop     ix
                        ld      d, 5(ix)
                        ld      a, #0x70 ; 'p'
                        cp      d
                        ret     Z
                        ret     C
                        ld      e, 4(ix)
                        exx
                        ld      hl, (WORK_BUFFER)
                        push    hl
                        inc     hl
                        inc     hl
                        ld      e, (hl)
                        ld      d, #0
                        inc     hl
                        ld      b, (hl)
                        ex      de, hl
                        jr      M_XY2_PLUS_1
; ---------------------------------------------------------------------------

GET_OLD:                                                        ; CODE XREF: PUTOBJ_-8Ej
                        inc     hl
                        inc     hl
                        ld      b, (hl)
                        inc     hl
                        ld      e, (hl)
                        ld      d, #0
                        inc     hl
                        ex      de, hl
                        jr      M_XY_PLUS_1
; ---------------------------------------------------------------------------

ELSE_1:                                                         ; CODE XREF: PUTOBJ_-81j
                        ld      hl, (WORK_BUFFER)
                        ld      d, 5(ix)
                        ld      e, 4(ix)
                        push    hl
                        push    de
                        push    hl
                        ld      bc, #4
                        call    VRAM_READ
                        pop     hl
                        ld      a, (hl)
                        cp      #0x80 ; '€'
                        jr      NZ, GET_OLD
                        pop     de
                        jp      SKIP_OLD
; ---------------------------------------------------------------------------

S_OLD_SCRN:                                                     ; CODE XREF: PUTOBJ_-41j
                        push    bc
                        push    de
                        push    hl
                        cp      #0x70 ; 'p'
                        jr      Z, EQUAL_TO
                        jr      C, ELSE_1

EQUAL_TO:                                                       ; CODE XREF: PUTOBJ_-83j
                        ld      h, a
                        ld      l, 4(ix)
                        ld      a, (hl)
                        jp      END_IF_1
; ---------------------------------------------------------------------------

PUT_SEMI:                                                       ; CODE XREF: DO_PUTOBJ+Aj
                        ld      d, 3(ix)
                        ld      e, 2(ix)
                        push    de
                        pop     iy
                        ld      d, 2(iy)
                        ld      e, 1(iy)
                        call    PX_TO_PTRN_POS
                        ld      c, e
                        ld      d, 4(iy)
                        ld      e, 3(iy)
                        call    PX_TO_PTRN_POS
                        ld      b, e
                        ld      e, 0(iy)
                        ld      d, #0
                        add     hl, de
                        add     hl, de
                        ld      e, #5
                        add     hl, de
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        ex      de, hl
                        push    bc
                        pop     de
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        inc     hl
                        ld      a, 5(ix)
                        bit     7, a
                        jr      Z, S_OLD_SCRN
                        call    PUT_FRAME
                        ret
; END OF FUNCTION CHUNK FOR PUTOBJ_

; =============== S U B R O U T I N E =======================================


DO_PUTOBJ:                                                      ; CODE XREF: PUTOBJ_+5j
                                                                ; ROM:1596p
                        ld      h, 1(ix)
                        ld      l, 0(ix)
                        ld      a, (hl)
                        ld      c, a
                        and     #0xF
                        jp      Z, PUT_SEMI
                        dec     a
                        jp      Z, PUT_MOBILE
                        dec     a
                        jp      Z, PUT0SPRITE
                        dec     a
                        jp      Z, PUT1SPRITE
                        jp      PUTCOMPLEX
; End of function DO_PUTOBJ

; ---------------------------------------------------------------------------

NOT_TOO_BIG:                                                    ; CODE XREF: PUTOBJ_+1Cj
                        ld      (QUEUE_HEAD), a
                        ld      (HEAD_ADDRESS), de
                        ret
; ---------------------------------------------------------------------------
PUTOBJ_PAR:             .dw 2                                   ; DATA XREF: ROM:PUTOBJQo
                        .dw 2
                        .dw 1
; ---------------------------------------------------------------------------

PUTOBJQ:                                                        ; DATA XREF: ROM:PUTOBJPo
                        ld      bc, #PUTOBJ_PAR
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      ix, (PARAM_AREA)
                        ld      a, (PARAM_AREA+2)
                        ld      b, a

; =============== S U B R O U T I N E =======================================


PUTOBJ_:                                                        ; CODE XREF: PUTOBJ_-B73p
                                                                ; DATA XREF: ROM:PUTOBJo

; FUNCTION CHUNK AT 0942 SIZE 00000095 BYTES
; FUNCTION CHUNK AT 0DA3 SIZE 00000513 BYTES
; FUNCTION CHUNK AT 141D SIZE 000000E8 BYTES

                        ld      a, (DEFER_WRITES)
                        cp      #1
                        jr      NZ, DO_PUTOBJ

SET_UP_WRITE:
                        push    ix
                        ld      hl, (HEAD_ADDRESS)
                        pop     de
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d
                        inc     hl
                        ld      (hl), b
                        inc     hl
                        ex      de, hl
                        ld      a, (QUEUE_HEAD)
                        inc     a
                        ld      hl, #QUEUE_SIZE
                        cp      (hl)
                        jr      NZ, NOT_TOO_BIG
                        ld      a, #0
                        ld      (QUEUE_HEAD), a
                        ld      hl, (BUFFER)
                        ld      (HEAD_ADDRESS), hl
                        ret
; End of function PUTOBJ_

; ---------------------------------------------------------------------------

WRTR_END_WHILE:                                                 ; CODE XREF: ROM:1587j
                        pop     af
                        ld      (DEFER_WRITES), a
                        ret
; ---------------------------------------------------------------------------

WRTR_ELSE:                                                      ; CODE XREF: ROM:15A1j
                        ld      (QUEUE_TAIL), a
                        pop     hl
                        ld      (TAIL_ADDRESS), hl
                        jr      WRTR_END_IF
; ---------------------------------------------------------------------------

WRITER_:                                                        ; DATA XREF: ROM:WRITERo
                        ld      a, (DEFER_WRITES)
                        push    af
                        xor     a
                        ld      (DEFER_WRITES), a

WRTR_END_IF:                                                    ; CODE XREF: ROM:1576j
                                                                ; ROM:15AFj
                        ld      a, (QUEUE_TAIL)
                        ld      hl, #QUEUE_HEAD
                        cp      (hl)
                        jr      Z, WRTR_END_WHILE
                        ld      hl, (TAIL_ADDRESS)
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        inc     hl
                        ld      b, (hl)
                        inc     hl
                        push    de
                        pop     ix
                        push    hl
                        call    DO_PUTOBJ
                        ld      a, (QUEUE_TAIL)
                        inc     a
                        ld      hl, #QUEUE_SIZE
                        cp      (hl)
                        jr      NZ, WRTR_ELSE
                        ld      a, #0
                        ld      (QUEUE_TAIL), a
                        ld      hl, (BUFFER)
                        ld      (TAIL_ADDRESS), hl
                        pop     hl
                        jr      WRTR_END_IF
; ---------------------------------------------------------------------------
INIT_QUEUE_P:           .dw 2                                   ; DATA XREF: ROM:INIT_QUEUEQo
                        .dw 1
                        .dw 0xFFFE
; ---------------------------------------------------------------------------

INIT_QUEUEQ:                                                    ; DATA XREF: ROM:INIT_WRITERPo
                        ld      bc, #INIT_QUEUE_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      a, (PARAM_AREA)
                        ld      hl, (PARAM_AREA+1)

INIT_QUEUE:                                                     ; DATA XREF: ROM:INIT_WRITERo
                        ld      (QUEUE_SIZE), a
                        ld      a, #0
                        ld      (QUEUE_HEAD), a
                        ld      (QUEUE_TAIL), a
                        ld      (BUFFER), hl
                        ld      (HEAD_ADDRESS), hl
                        ld      (TAIL_ADDRESS), hl
                        ret
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR ACTIVATE_

ACT_0SPRT:                                                      ; CODE XREF: ACTIVATE_+17j
                                                                ; ACTIVATE_+1Bj
                        inc     bc
                        inc     bc
                        inc     bc
                        inc     bc
                        inc     bc
                        ex      de, hl
                        inc     hl
                        ld      a, (hl)
                        ld      e, a
                        ld      d, #0
                        push    de
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        inc     hl
                        add     a, (hl)
                        ld      (bc), a
                        ld      c, (hl)
                        ld      b, #0
                        push    bc
                        pop     iy
                        ex      de, hl
                        pop     de
                        pop     af
                        ret     NC
                        ld      a, #1
                        call    PUT_VRAM_
                        ret
; ---------------------------------------------------------------------------

ACT_MOBILE:                                                     ; CODE XREF: ACTIVATE_+13j
                        call    INIT_XP_OS
                        inc     de
                        ld      a, (de)
                        ld      5(iy), a
                        inc     de
                        ld      a, (de)
                        ld      6(iy), a
                        pop     af
                        ret
; END OF FUNCTION CHUNK FOR ACTIVATE_

; =============== S U B R O U T I N E =======================================


SUP_UPDATE:                                                     ; CODE XREF: ACTIVATE_-4Fp
                                                                ; ACTIVATE_-47p
                        push    bc
                        ld      bc, #0x100
                        ex      de, hl
                        add     hl, bc
                        ex      de, hl
                        pop     bc
                        ret
; End of function SUP_UPDATE

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR SUP_GEN_CLR

ONE_BYTE:                                                       ; CODE XREF: SUP_GEN_CLR+19j
                        add     hl, bc
                        ld      c, l
                        ld      b, h
                        push    iy
                        pop     hl

NEXT_COLOR:                                                     ; CODE XREF: SUP_GEN_CLR-4j
                        push    hl
                        ld      a, (bc)
                        push    bc
                        ld      bc, #8
                        ld      hl, (WORK_BUFFER)
                        add     hl, bc
                        ld      b, #8

DUPLI:                                                          ; CODE XREF: SUP_GEN_CLR-18j
                        dec     hl
                        ld      (hl), a
                        djnz    DUPLI
                        push    de
                        ld      iy, #1
                        ld      a, #4
                        call    PUT_VRAM_
                        pop     de
                        pop     bc
                        inc     de
                        inc     bc
                        pop     hl
                        dec     hl
                        ld      a, h
                        or      l
                        jr      NZ, NEXT_COLOR
                        jr      O_B_RET
; END OF FUNCTION CHUNK FOR SUP_GEN_CLR

; =============== S U B R O U T I N E =======================================


SUP_GEN_CLR:                                                    ; CODE XREF: ACTIVATE_-52p
                                                                ; ACTIVATE_-4Ap ...

; FUNCTION CHUNK AT 1616 SIZE 0000002C BYTES

                        push    af
                        push    bc
                        push    iy
                        push    de
                        push    hl
                        ld      a, #3
                        call    PUT_VRAM_
                        pop     hl
                        pop     de
                        pop     iy
                        pop     bc
                        pop     af
                        push    af
                        push    bc
                        push    iy
                        push    de
                        push    hl
                        bit     4, a
                        jr      NZ, ONE_BYTE
                        add     hl, bc
                        ld      a, #4
                        call    PUT_VRAM_

O_B_RET:                                                        ; CODE XREF: SUP_GEN_CLR-2j
                        pop     hl
                        pop     de
                        pop     iy
                        pop     bc
                        pop     af
                        ret
; End of function SUP_GEN_CLR

; ---------------------------------------------------------------------------
INIT_80:                .db 0x80 ; €                            ; DATA XREF: INIT_XP_OS:OS_IN_VRAMo
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR INIT_XP_OS

OS_IN_VRAM:                                                     ; CODE XREF: INIT_XP_OS+Ej
                        ld      hl, #INIT_80
                        ld      bc, #1
                        call    VRAM_WRITE

SM_BY_OLD:                                                      ; CODE XREF: INIT_XP_OS+9j
                                                                ; INIT_XP_OS+13j
                        pop     de
                        inc     de
                        ret
; END OF FUNCTION CHUNK FOR INIT_XP_OS

; =============== S U B R O U T I N E =======================================


INIT_XP_OS:                                                     ; CODE XREF: ACTIVATE_:ACT_MOBILEp
                                                                ; ACTIVATE_:ACT_SEMIp

; FUNCTION CHUNK AT 166B SIZE 0000000C BYTES

                        push    bc
                        pop     iy
                        push    de
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        bit     7, d
                        jr      NZ, SM_BY_OLD
                        ld      a, d
                        cp      #0x70 ; 'p'
                        jr      C, OS_IN_VRAM
                        ld      a, #0x80 ; '€'
                        ld      (de), a
                        jr      SM_BY_OLD
; End of function INIT_XP_OS

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR ACTIVATE_

SEMI_GRI:                                                       ; CODE XREF: ACTIVATE_-6Bj
                        ex      de, hl
                        ld      c, (hl)
                        ld      b, #0
                        push    bc
                        pop     iy
                        inc     hl
                        ld      a, (hl)
                        inc     hl
                        ld      h, (hl)
                        ld      l, a
                        push    hl
                        push    bc
                        push    de
                        push    iy
                        ld      a, #3
                        call    PUT_VRAM_
                        pop     bc
                        pop     hl
                        ld      e, l
                        ld      d, h
                        add     hl, bc
                        dec     hl
                        srl     h
                        rr      l
                        srl     h
                        rr      l
                        srl     h
                        rr      l
                        sra     e
                        sra     e
                        sra     e
                        or      a
                        sbc     hl, de
                        inc     hl
                        push    hl
                        pop     iy
                        pop     hl
                        add     hl, hl
                        add     hl, hl
                        add     hl, hl
                        pop     bc
                        add     hl, bc
                        ld      a, #4
                        call    PUT_VRAM_
                        pop     af
                        ret
; ---------------------------------------------------------------------------

ACT_SEMI:                                                       ; CODE XREF: ACTIVATE_+Fj
                        call    INIT_XP_OS
                        ld      a, (de)
                        ld      l, a
                        inc     de
                        ld      a, (de)
                        add     a, l
                        ld      5(iy), a
                        ld      h, #0
                        pop     af
                        ret     NC
                        push    af
                        ld      a, (VDP_MODE_WORD)
                        bit     1, a
                        jr      Z, SEMI_GRI
                        ex      de, hl
                        ld      b, h
                        ld      c, l
                        ld      l, (hl)
                        ld      h, #0
                        push    hl
                        add     hl, hl
                        add     hl, hl
                        add     hl, hl
                        push    hl
                        inc     bc
                        ld      a, (bc)
                        ld      l, a
                        inc     bc
                        ld      a, (bc)
                        ld      h, a
                        pop     bc
                        pop     iy
                        pop     af
                        bit     7, a
                        call    NZ, SUP_GEN_CLR
                        call    SUP_UPDATE
                        bit     6, a
                        call    NZ, SUP_GEN_CLR
                        call    SUP_UPDATE
                        bit     5, a
                        call    NZ, SUP_GEN_CLR
                        ret
; ---------------------------------------------------------------------------

ACT_CMPLX:                                                      ; CODE XREF: ACTIVATE_+1Fj
                        ld      a, (de)
                        rra
                        rra
                        rra
                        rra
                        and     #0xF
                        ld      b, a
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        inc     hl
                        or      a
                        jr      Z, CMPLX9

CMPLX4:                                                         ; CODE XREF: ACTIVATE_-21j
                        pop     af
                        push    af
                        push    hl
                        push    bc
                        ex      de, hl
                        call    ACTIVATE_
                        pop     bc
                        pop     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        inc     hl
                        djnz    CMPLX4

CMPLX9:                                                         ; CODE XREF: ACTIVATE_-31j
                        pop     af
                        ret
; END OF FUNCTION CHUNK FOR ACTIVATE_
; ---------------------------------------------------------------------------
ACTIVATE_P:             .dw 2                                   ; DATA XREF: ROM:ACTIVATEQo
                        .dw 0xFFFE
                        .dw 1
; ---------------------------------------------------------------------------

ACTIVATEQ:                                                      ; DATA XREF: ROM:ACTIVATEPo
                        ld      bc, #ACTIVATE_P
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      hl, (PARAM_AREA)
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        ex      de, hl
                        ld      a, (PARAM_AREA+2)
                        or      a
                        jr      Z, ACTIVATE_
                        scf

; =============== S U B R O U T I N E =======================================


ACTIVATE_:                                                      ; CODE XREF: ACTIVATE_-2Ap
                                                                ; ROM:174Bj
                                                                ; DATA XREF: ...

; FUNCTION CHUNK AT 15DB SIZE 00000032 BYTES
; FUNCTION CHUNK AT 168C SIZE 000000A5 BYTES

                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        inc     hl
                        ld      c, (hl)
                        inc     hl
                        ld      b, (hl)
                        inc     hl
                        ld      a, #0
                        ld      (bc), a
                        ld      a, (de)
                        push    af
                        and     #0xF
                        jp      Z, ACT_SEMI
                        dec     a
                        jp      Z, ACT_MOBILE
                        dec     a
                        jp      Z, ACT_0SPRT
                        dec     a
                        jp      Z, ACT_0SPRT
                        dec     a
                        jr      Z, ACT_CMPLX
                        pop     af
                        ret
; End of function ACTIVATE_


; =============== S U B R O U T I N E =======================================


DE_TO_DEST:                                                     ; CODE XREF: LOAD_NEXT_NOTE-97p
                                                                ; LOAD_NEXT_NOTE-74p ...
                        push    ix
                        pop     iy
                        add     iy, de
                        push    iy
                        pop     de
                        ret
; End of function DE_TO_DEST

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR LOAD_NEXT_NOTE

TYPE3:                                                          ; CODE XREF: LOAD_NEXT_NOTE-AEj
                        ld      e, #8
                        ld      d, #0
                        add     hl, de
                        ld      1(ix), l
                        ld      2(ix), h
                        dec     hl
                        push    ix
                        pop     iy
                        ld      e, #9
                        add     iy, de
                        push    iy
                        pop     de
                        ld      bc, #7
                        lddr

MODB0:                                                          ; CODE XREF: LOAD_NEXT_NOTE-86j
                                                                ; LOAD_NEXT_NOTE-68j ...
                        push    ix
                        pop     hl
                        pop     af
                        pop     bc
                        cp      #0xFF
                        ret     Z
                        ld      d, a
                        and     #0x3F ; '?'
                        cp      #4
                        jr      NZ, L20_LOAD_NEX
                        ld      b, #0x3E ; '>'

L20_LOAD_NEX:                                                   ; CODE XREF: LOAD_NEXT_NOTE-BAj
                        ld      a, d
                        and     #0xC0 ; 'À'
                        or      b
                        ld      (hl), a
                        ret
; ---------------------------------------------------------------------------

L17:                                                            ; CODE XREF: LOAD_NEXT_NOTE-82j
                        cp      #2
                        jr      NZ, TYPE3

TYPE2:
                        ld      e, #6
                        ld      d, #0
                        add     hl, de
                        pop     af
                        push    af
                        and     #0xC0 ; 'À'
                        jr      NZ, L18
                        dec     hl

L18:                                                            ; CODE XREF: LOAD_NEXT_NOTE-A3j
                        ld      1(ix), l
                        ld      2(ix), h
                        dec     hl
                        ld      e, #9
                        call    DE_TO_DEST
                        ld      bc, #2
                        lddr
                        ld      a, #0
                        ld      (de), a
                        dec     de
                        dec     de
                        ld      c, #3
                        lddr
                        jr      MODB0
; ---------------------------------------------------------------------------

L16:                                                            ; CODE XREF: LOAD_NEXT_NOTE-62j
                        cp      #1
                        jr      NZ, L17
                        ld      de, #6
                        add     hl, de
                        ld      1(ix), l
                        ld      2(ix), h
                        dec     hl
                        inc     e
                        call    DE_TO_DEST
                        ld      bc, #5
                        lddr
                        ld      8(ix), #0
                        jr      MODB0
; ---------------------------------------------------------------------------

L15:                                                            ; CODE XREF: LOAD_NEXT_NOTE-30j
                        push    bc
                        ld      a, b
                        and     #3
                        jr      NZ, L16
                        inc     hl
                        inc     hl
                        inc     hl
                        inc     hl
                        ld      2(ix), h
                        ld      1(ix), l
                        ld      de, #5
                        dec     hl
                        call    DE_TO_DEST
                        ld      bc, #3
                        lddr
                        ld      7(ix), #0
                        ld      8(ix), #0
                        jp      MODB0
; END OF FUNCTION CHUNK FOR LOAD_NEXT_NOTE
; ---------------------------------------------------------------------------

PASS1:                                                          ; DATA XREF: LOAD_NEXT_NOTE-18o
                        ld      de, #7
                        add     iy, de
                        ld      de, #MODB0
                        push    de
                        jp      (iy)
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR LOAD_NEXT_NOTE

L14:                                                            ; CODE XREF: LOAD_NEXT_NOTE-Aj
                        and     #0x3C ; '<'
                        cp      #4
                        jr      NZ, L15

EFFECT:
                        pop     iy
                        push    iy
                        push    bc
                        inc     hl
                        ld      e, (hl)
                        ld      1(ix), e
                        inc     hl
                        ld      d, (hl)
                        ld      2(ix), d
                        inc     hl
                        push    iy
                        pop     af
                        push    de
                        pop     iy
                        ld      de, #PASS1
                        push    de
                        jp      (iy)
; ---------------------------------------------------------------------------

ENDNOREP:                                                       ; CODE XREF: LOAD_NEXT_NOTE-6j
                        ld      a, #0xFF
                        push    af
                        jp      MODB0
; ---------------------------------------------------------------------------

L13:                                                            ; CODE XREF: LOAD_NEXT_NOTE+14j
                        bit     4, a
                        jr      Z, L14
                        bit     3, a
                        jr      Z, ENDNOREP
                        pop     bc
                        jp      JUKE_BOX
; END OF FUNCTION CHUNK FOR LOAD_NEXT_NOTE

; =============== S U B R O U T I N E =======================================


LOAD_NEXT_NOTE:                                                 ; CODE XREF: PROCESS_DATA_AREA-Cp
                                                                ; LOAD_NEXT_NOTE+133p

; FUNCTION CHUNK AT 177B SIZE 000000A4 BYTES
; FUNCTION CHUNK AT 182A SIZE 00000034 BYTES
; FUNCTION CHUNK AT 1910 SIZE 00000003 BYTES
; FUNCTION CHUNK AT 1977 SIZE 00000020 BYTES

                        ld      a, 0(ix)
                        and     #0x3F ; '?'
                        push    af
                        ld      0(ix), #0xFF
                        ld      l, 1(ix)
                        ld      h, 2(ix)
                        ld      a, (hl)
                        ld      b, a
                        bit     5, a
                        jr      Z, L13
                        push    bc
                        and     #0x1F
                        inc     hl
                        ld      1(ix), l
                        ld      2(ix), h
                        ld      4(ix), #0xF0 ; 'ð'              ; ATN
                        ld      5(ix), a                        ; NLEN
                        ld      7(ix), #0                       ; FSTEP
                        ld      8(ix), #0                       ; ASTEP
                        jp      MODB0
; End of function LOAD_NEXT_NOTE

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR TONE_OUT

L7:                                                             ; CODE XREF: TONE_OUT+4j
                        call    UPATNCTRL
                        jp      UPFREQ
; END OF FUNCTION CHUNK FOR TONE_OUT

; =============== S U B R O U T I N E =======================================


TONE_OUT:                                                       ; CODE XREF: ROM:18BCp
                                                                ; ROM:18C9p ...

; FUNCTION CHUNK AT 1890 SIZE 00000006 BYTES
; FUNCTION CHUNK AT 1A49 SIZE 0000001B BYTES

                        ld      e, 0(ix)
                        inc     e
                        jr      NZ, L7
                        out     (0xFF), a                       ; SOUND_PORT
                        ret
; End of function TONE_OUT

; ---------------------------------------------------------------------------

L5:                                                             ; CODE XREF: ROM:18E5j
                        call    UPATNCTRL
                        ld      a, 4(ix)
                        and     #0xF
                        ld      hl, #SAVE_CTRL
                        cp      (hl)
                        ret     Z
                        ld      (hl), a
                        ld      c, #0xE0 ; 'à'
                        jp      UPATNCTRL
; ---------------------------------------------------------------------------

PLAY_SONGS_:                                                    ; DATA XREF: ROM:PLAYSONGSo
                        ld      a, #0x9F ; 'Ÿ'
                        ld      c, #0x90 ; ''
                        ld      d, #0x80 ; '€'
                        ld      ix, (PTR_TO_S_ON_1)
                        call    TONE_OUT
                        ld      a, #0xBF ; '¿'
                        ld      c, #0xB0 ; '°'
                        ld      d, #0xA0 ; ' '
                        ld      ix, (PTR_TO_S_ON_2)
                        call    TONE_OUT
                        ld      a, #0xDF ; 'ß'
                        ld      c, #0xD0 ; 'Ð'
                        ld      d, #0xC0 ; 'À'
                        ld      ix, (PTR_TO_S_ON_3)
                        call    TONE_OUT
                        ld      a, #0xFF
                        ld      c, #0xF0 ; 'ð'
                        ld      ix, (PTR_TO_S_ON_0)
                        ld      e, 0(ix)
                        inc     e
                        jr      NZ, L5
                        out     (0xFF), a
                        ret
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PROCESS_DATA_AREA

L10:                                                            ; CODE XREF: PROCESS_DATA_AREA+8j
                        call    ATN_SWEEP
                        call    FREQ_SWEEP
                        ret     NZ
                        ld      a, 0(ix)
                        push    af
                        call    LOAD_NEXT_NOTE
                        pop     bc
                        ld      a, 0(ix)
                        cp      b
                        call    NZ, UP_CH_DATA_PTRS
                        ret
; END OF FUNCTION CHUNK FOR PROCESS_DATA_AREA

; =============== S U B R O U T I N E =======================================


PROCESS_DATA_AREA:                                              ; CODE XREF: ROM:195Ap

; FUNCTION CHUNK AT 18EA SIZE 00000017 BYTES

                        call    AREA_SONG_IS
                        cp      #0xFF
                        ret     Z
                        cp      #0x3E ; '>'
                        jr      NZ, L10
                        ld      de, #7
                        add     hl, de
                        jp      (hl)
; End of function PROCESS_DATA_AREA

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR LOAD_NEXT_NOTE

DONE_SNDMAN:                                                    ; CODE XREF: UP_CH_DATA_PTRS+1Aj
                        pop     ix
                        ret
; END OF FUNCTION CHUNK FOR LOAD_NEXT_NOTE

; =============== S U B R O U T I N E =======================================


UP_CH_DATA_PTRS:                                                ; CODE XREF: PROCESS_DATA_AREA-4p
                                                                ; LOAD_NEXT_NOTE+136j
                        push    ix
                        ld      hl, #DUMAREA
                        ld      (PTR_TO_S_ON_0), hl
                        ld      (PTR_TO_S_ON_1), hl
                        ld      (PTR_TO_S_ON_2), hl
                        ld      (PTR_TO_S_ON_3), hl
                        ld      b, #1
                        call    PT_IX_TO_SxDATA

L2:                                                             ; CODE XREF: UP_CH_DATA_PTRS+3Bj
                        ld      a, 0(ix)
                        or      a
                        jr      Z, DONE_SNDMAN
                        cp      #0xFF
                        jr      Z, L9
                        ld      a, 0(ix)
                        and     #0xC0 ; 'À'
                        rlca
                        rlca
                        rlca
                        ld      e, a
                        ld      d, #0
                        ld      hl, #PTR_TO_S_ON_0
                        add     hl, de
                        push    ix
                        pop     de
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d

L9:                                                             ; CODE XREF: UP_CH_DATA_PTRS+1Ej
                        ld      e, #0xA
                        ld      d, #0
                        add     ix, de
                        jr      L2
; End of function UP_CH_DATA_PTRS

; ---------------------------------------------------------------------------

SND_MANAGER:                                                    ; DATA XREF: ROM:SOUND_MANo
                        ld      b, #1
                        call    PT_IX_TO_SxDATA

L1:                                                             ; CODE XREF: ROM:1963j
                        xor     a
                        cp      0(ix)
                        ret     Z
                        call    PROCESS_DATA_AREA
                        ld      e, #0xA
                        ld      d, #0
                        add     ix, de
                        jr      L1
; ---------------------------------------------------------------------------
DUMAREA:                .db 0xFF                                ; DATA XREF: UP_CH_DATA_PTRS+2o
                                                                ; ROM:19C1o
JUKE_BOX_PAR:           .dw 1                                   ; DATA XREF: ROM:JUKE_BOXQo
                        .dw 1
; ---------------------------------------------------------------------------

JUKE_BOXQ:                                                      ; DATA XREF: ROM:PLAY_ITPo
                        ld      bc, #JUKE_BOX_PAR
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      a, (PARAM_AREA)
                        ld      b, a
; START OF FUNCTION CHUNK FOR LOAD_NEXT_NOTE

JUKE_BOX:                                                       ; CODE XREF: LOAD_NEXT_NOTE-3j
                                                                ; DATA XREF: ROM:PLAY_ITo
                        push    bc
                        call    PT_IX_TO_SxDATA
                        ld      a, 0(ix)
                        and     #0x3F ; '?'
                        pop     bc
                        cp      b
                        ret     Z
                        ld      0(ix), b
                        dec     hl
                        dec     hl
                        ld      d, (hl)
                        dec     hl
                        ld      e, (hl)
                        ld      1(ix), e
                        ld      2(ix), d
                        call    LOAD_NEXT_NOTE
                        jp      UP_CH_DATA_PTRS
; END OF FUNCTION CHUNK FOR LOAD_NEXT_NOTE
; ---------------------------------------------------------------------------
INIT_SOUND_PAR:         .dw 2                                   ; DATA XREF: ROM:INIT_SOUNDQo
                        .dw 1
                        .dw 2
; ---------------------------------------------------------------------------

INIT_SOUNDQ:                                                    ; DATA XREF: ROM:SOUND_INITPo
                        ld      bc, #INIT_SOUND_PAR
                        ld      de, #PARAM_AREA
                        call    PARAM_
                        ld      a, (PARAM_AREA)
                        ld      b, a
                        ld      hl, (PARAM_AREA+1)

INIT_SOUND:                                                     ; DATA XREF: ROM:SOUND_INITo
                        ld      (PTR_LST_OF_SND_ADDRS), hl
                        inc     hl
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        ex      de, hl
                        ld      e, #0xA
                        ld      d, #0

B1:                                                             ; CODE XREF: ROM:19BDj
                        ld      (hl), #0xFF
                        add     hl, de
                        djnz    B1
                        ld      (hl), #0
                        ld      hl, #DUMAREA
                        ld      (PTR_TO_S_ON_0), hl
                        ld      (PTR_TO_S_ON_1), hl
                        ld      (PTR_TO_S_ON_2), hl
                        ld      (PTR_TO_S_ON_3), hl
                        ld      a, #0xFF
                        ld      (SAVE_CTRL), a

; =============== S U B R O U T I N E =======================================


ALL_OFF:                                                        ; CODE XREF: BOOT_UP+1B75p
                                                                ; BOOT_UP+1BB4p
                                                                ; DATA XREF: ...
                        ld      b, #4                           ; num generators
                        ld      a, #0x9F ; 'Ÿ'                  ; 1st off code

gen_off:                                                        ; CODE XREF: ALL_OFF+8j
                        out     (0xFF), a                       ; turn off
                        add     a, #0x20 ; ' '                  ; calc next off code
                        djnz    gen_off
                        ret
; End of function ALL_OFF


; =============== S U B R O U T I N E =======================================


AREA_SONG_IS:                                                   ; CODE XREF: PROCESS_DATA_AREAp
                        ld      a, 0(ix)
                        cp      #0xFF
                        ret     Z
                        and     #0x3F ; '?'
                        cp      #0x3E ; '>'
                        ret     NZ
                        push    ix
                        pop     hl
                        inc     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        ex      de, hl
                        ret
; End of function AREA_SONG_IS

; ---------------------------------------------------------------------------
                        ld      1(ix), l
                        ld      2(ix), h
                        ld      a, (de)
                        and     #0x3F ; '?'
                        ld      b, a
                        ld      a, 0(ix)
                        and     #0xC0 ; 'À'
                        or      b
                        ld      0(ix), a
                        ret

; =============== S U B R O U T I N E =======================================


PT_IX_TO_SxDATA:                                                ; CODE XREF: UP_CH_DATA_PTRS+13p
                                                                ; ROM:1952p ...
                        ld      hl, (PTR_LST_OF_SND_ADDRS)
                        dec     hl
                        dec     hl
                        ld      c, b
                        ld      b, #0
                        rlc     c
                        rlc     c
                        add     hl, bc
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        push    de
                        pop     ix
                        ret
; End of function PT_IX_TO_SxDATA


; =============== S U B R O U T I N E =======================================


ADD816:                                                         ; CODE XREF: FREQ_SWEEP-9p
                        ld      b, #0
                        bit     7, a
                        jr      Z, POS
                        ld      b, #0xFF

POS:                                                            ; CODE XREF: ADD816+4j
                        add     a, (hl)
                        ld      (hl), a
                        inc     hl
                        ld      a, (hl)
                        adc     a, b
                        ld      (hl), a
                        dec     hl
                        ret
; End of function ADD816


; =============== S U B R O U T I N E =======================================


MSNTOLSN:                                                       ; CODE XREF: ATN_SWEEP+13p
                                                                ; FREQ_SWEEP-16p
                        ld      a, (hl)
                        and     #0xF0 ; 'ð'
                        ld      b, a
                        rrca
                        rrca
                        rrca
                        rrca
                        or      b
                        ld      (hl), a
                        ret
; End of function MSNTOLSN

; ---------------------------------------------------------------------------
                        xor     a
                        rld
                        dec     a
                        push    af
                        rrd
                        pop     af
                        ret

; =============== S U B R O U T I N E =======================================


DECLSN:                                                         ; CODE XREF: ATN_SWEEP+Ep
                                                                ; ATN_SWEEP+17p ...
                        xor     a
                        rrd
                        dec     a
                        push    af
                        rld
                        pop     af
                        ret
; End of function DECLSN

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR TONE_OUT

UPFREQ:                                                         ; CODE XREF: TONE_OUT-3j
                        ld      a, 3(ix)
                        and     #0xF
                        or      d
                        out     (0xFF), a
                        ld      a, 3(ix)
                        and     #0xF0 ; 'ð'
                        ld      d, a
                        ld      a, 4(ix)
                        and     #0xF
                        or      d
                        rrca
                        rrca
                        rrca
                        rrca
                        out     (0xFF), a
                        ret
; END OF FUNCTION CHUNK FOR TONE_OUT

; =============== S U B R O U T I N E =======================================


ATN_SWEEP:                                                      ; CODE XREF: PROCESS_DATA_AREA:L10p
                        ld      a, 8(ix)
                        cp      #0
                        ret     Z
                        push    ix
                        pop     hl
                        ld      d, #0
                        ld      e, #9
                        add     hl, de
                        call    DECLSN
                        jr      NZ, L22
                        call    MSNTOLSN
                        dec     hl
                        call    DECLSN
                        jr      Z, L23
                        ld      a, (hl)
                        and     #0xF0 ; 'ð'
                        ld      e, a
                        dec     hl
                        dec     hl
                        dec     hl
                        dec     hl
                        ld      a, (hl)
                        and     #0xF0 ; 'ð'
                        add     a, e
                        ld      e, a
                        ld      a, (hl)
                        and     #0xF
                        or      e
                        ld      (hl), a
                        or      #0xFF
                        jr      L22
; ---------------------------------------------------------------------------

L23:                                                            ; CODE XREF: ATN_SWEEP+1Aj
                        ld      (hl), #0

L22:                                                            ; CODE XREF: ATN_SWEEP+11j
                                                                ; ATN_SWEEP+30j
                        ret
; End of function ATN_SWEEP

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR FREQ_SWEEP

L20:                                                            ; CODE XREF: FREQ_SWEEP+5j
                        push    ix
                        pop     hl
                        ld      e, #6
                        ld      d, #0
                        add     hl, de
                        call    DECLSN
                        jr      NZ, L21
                        call    MSNTOLSN
                        dec     hl
                        ld      a, (hl)
                        dec     a
                        ret     Z
                        ld      (hl), a
                        dec     hl
                        dec     hl
                        ld      a, 7(ix)
                        call    ADD816
                        inc     hl
                        res     2, (hl)
                        or      #0xFF

L21:                                                            ; CODE XREF: FREQ_SWEEP-18j
                        ret
; END OF FUNCTION CHUNK FOR FREQ_SWEEP

; =============== S U B R O U T I N E =======================================


FREQ_SWEEP:                                                     ; CODE XREF: PROCESS_DATA_AREA-14p

; FUNCTION CHUNK AT 1A99 SIZE 00000023 BYTES

                        ld      a, 7(ix)
                        cp      #0
                        jr      NZ, L20
                        ld      a, 5(ix)
                        dec     a
                        ret     Z
                        ld      5(ix), a
                        ret
; End of function FREQ_SWEEP

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR PARAM_

L00F8:                                                          ; CODE XREF: PARAM_-Bj
                        pop     hl
                        jp      L00C4
; ---------------------------------------------------------------------------

L00DA:                                                          ; CODE XREF: PARAM_+22j
                        pop     hl
                        ex      (sp), hl
                        push    hl
                        rrca
                        ld      h, a
                        dec     bc
                        ld      a, (bc)
                        ld      l, a
                        ex      (sp), hl
                        inc     bc
                        inc     bc

L00E5:                                                          ; CODE XREF: PARAM_-7j
                        ld      a, (de)
                        ld      (hl), a
                        inc     hl
                        inc     de
                        ex      (sp), hl
                        dec     hl
                        xor     a
                        cp      l
                        jp      NZ, L00F4
                        cp      h
                        jp      Z, L00F8

L00F4:                                                          ; CODE XREF: PARAM_-Fj
                        ex      (sp), hl
                        jp      L00E5
; ---------------------------------------------------------------------------

L00D6:                                                          ; CODE XREF: PARAM_+35j
                        pop     hl
                        ex      de, hl
                        ex      (sp), hl
                        jp      (hl)
; END OF FUNCTION CHUNK FOR PARAM_

; =============== S U B R O U T I N E =======================================


PARAM_:                                                         ; CODE XREF: ROM:0151p
                                                                ; ROM:016Bp ...

; FUNCTION CHUNK AT 1ACC SIZE 00000026 BYTES

                        pop     hl
                        ex      (sp), hl
                        push    hl
                        ld      a, (bc)
                        ld      l, a
                        inc     bc
                        ld      a, (bc)
                        inc     bc
                        ld      h, a
                        ex      (sp), hl
                        push    de

L00A3:                                                          ; CODE XREF: PARAM_+3Bj
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        inc     hl
                        push    hl
                        ld      a, e
                        or      d
                        jp      NZ, L00B7
                        pop     hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)
                        inc     hl
                        push    hl
                        ex      de, hl
                        ld      e, (hl)
                        inc     hl
                        ld      d, (hl)

L00B7:                                                          ; CODE XREF: PARAM_+12j
                        inc     bc
                        ld      a, (bc)
                        rlca
                        jp      NC, L00DA
                        inc     bc
                        pop     hl
                        ex      (sp), hl
                        ld      (hl), e
                        inc     hl
                        ld      (hl), d
                        inc     hl

L00C4:                                                          ; CODE XREF: PARAM_-25j
                        pop     de
                        ex      (sp), hl
                        dec     hl
                        xor     a
                        cp      h
                        jp      NZ, L00D0
                        cp      l
                        jp      Z, L00D6

L00D0:                                                          ; CODE XREF: PARAM_+31j
                        ex      (sp), hl
                        push    hl
                        ex      de, hl
                        jp      L00A3
; End of function PARAM_


; =============== S U B R O U T I N E =======================================


UPATNCTRL:                                                      ; CODE XREF: TONE_OUT:L7p
                                                                ; ROM:L5p ...
                        ld      a, 4(ix)
                        bit     4, c                            ; ATN
                        jr      Z, L24
                        rrca
                        rrca
                        rrca
                        rrca

L24:                                                            ; CODE XREF: UPATNCTRL+5j
                        and     #0xF
                        or      c
                        out     (0xFF), a
                        ret
; End of function UPATNCTRL


; =============== S U B R O U T I N E =======================================


LOAD_ASCII_:                                                    ; CODE XREF: DISPLAY_LOGO+Dp
                                                                ; DATA XREF: ROM:LOAD_ASCIIo
                        ld      hl, (PATTERNGENTBL)
                        ld      de, #0x100
                        add     hl, de                          ; calc VDP RAM address
                        ld      de, #SPACE                      ; 'message'
                        ex      de, hl
                        ld      bc, #0x300
; End of function LOAD_ASCII_

; HL = message
; DE = VPD RAM address
; BC = length

; =============== S U B R O U T I N E =======================================


VRAM_WRITE:                                                     ; CODE XREF: ROM:007Ap
                                                                ; ROM:0086p ...
                        ld      a, b
                        or      c                               ; zero length?
                        ret     Z                               ; yes, return
                        ex      de, hl
                        call    REG_READ
                        ld      a, l
                        out     (0xBF), a                       ; VDP_RAM_ADDR
                        ld      a, #0x40 ; '@'
                        or      h                               ; add base address
                        out     (0xBF), a                       ; VDP_RAM_ADDR

output_loop:                                                    ; CODE XREF: VRAM_WRITE+16j
                        ld      a, (de)                         ; message char
                        out     (0xBE), a                       ; VDP_DATA
                        inc     de                              ; next character
                        dec     bc
                        ld      a, b
                        or      c                               ; done?
                        jr      NZ, output_loop                 ; no, loop
                        ex      de, hl
                        jp      REG_READ
; End of function VRAM_WRITE

; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR BOOT_UP

POWER_UP:                                                       ; CODE XREF: BOOT_UP+3j
                        ld      de, #1                          ; delay=1
                        ld      hl, (START_GAME)
                        push    hl                              ; address to stack (for RET)
                        call    delay_DE
                        call    ALL_OFF                         ; turn off sound chip
                        ld      hl, (CARTRIDGE)
                        ld      bc, #0xAA55                     ; execute game, no delay?
                        and     a
                        sbc     hl, bc                          ; match?
                        ret     Z                               ; yes, execute
                        ld      hl, (CARTRIDGE)
                        ld      de, #0x55AA                     ; display CV logo title screen
                        and     a
                        sbc     hl, de                          ; match?
                        jr      Z, display_CV_logo              ; yes, execute
; no cartridge
                        call    DISPLAY_LOGO
                        ld      hl, #aTurnPowerOff              ; "TURN POWER OFF"
                        ld      de, #0x1909                     ; VDP RAM address offset
                        ld      bc, #14                         ; length
                        call    VRAM_WRITE
                        ld      hl, #aBeforeInsertingCartridge  ; "BEFORE INSERTING CARTRIDGE"
                        ld      de, #0x1943                     ; VDP RAM address offset
                        ld      bc, #26                         ; length
                        call    VRAM_WRITE
                        ld      hl, #aOrExpansionModule_        ; "OR EXPANSION MODULE."
                        ld      de, #0x1986                     ; VDP RAM address offset
                        ld      bc, #26                         ; length
                        call    VRAM_WRITE
                        call    ALL_OFF

spin_forever:                                                   ; CODE XREF: BOOT_UP:spin_foreverj
                        jr      spin_forever
; ---------------------------------------------------------------------------

display_CV_logo:                                                ; CODE XREF: BOOT_UP+1B8Bj
                        ld      de, #0x33 ; '3'
                        ld      (RAND_NUM), de
                        xor     a
                        out     (0xCF), a                       ; JOY1
                        ld      (S1_C1), a
                        ld      hl, #S1_C1
                        ld      de, #S1_C0
                        ld      bc, #26
                        lddr
                        ld      de, (CONTROLLER_MAP)            ; ptr controller state table
                        inc     de
                        inc     de                              ; skip flags
                        ld      c, #10                          ; length
                        ldir                                    ; copy
                        ld      hl, #0
                        ld      (DEFER_WRITES), hl
                        call    DISPLAY_LOGO
                        ld      hl, #GAME_NAME
                        ld      de, #0x1950                     ; VDP RAM offset (line centre)
                        call    centre_print_msg                ; game name
                        ld      de, #0x1910                     ; VDP RAM offset (line centre)
                        call    centre_print_msg                ; licensor
                        ld      de, #0x20 ; ' '
                        jp      delay_DE                        ; return
; END OF FUNCTION CHUNK FOR BOOT_UP

; =============== S U B R O U T I N E =======================================


centre_print_msg:                                               ; CODE XREF: BOOT_UP+1BEAp
                                                                ; BOOT_UP+1BF0p
                        push    hl                              ; save ptr string
                        push    de                              ; save VDP RAM offset
                        ld      bc, #0                          ; init char counter
                        ld      a, #0x2F ; '/'                  ; separator

find_end_of_string:                                             ; CODE XREF: centre_print_msg+Cj
                        cp      (hl)                            ; end of string?
                        jr      Z, end_of_string                ; skip, exit
                        inc     hl                              ; next char
                        inc     bc                              ; inc count
                        jr      find_end_of_string              ; loop
; ---------------------------------------------------------------------------

end_of_string:                                                  ; CODE XREF: centre_print_msg+8j
                        pop     hl                              ; restore VDP offset
                        pop     de                              ; restore ptr string
                        push    bc                              ; save length of string
                        srl     b
                        rr      c                               ; len/2
                        or      a                               ; clear C
                        sbc     hl, bc                          ; calc starting position
                        pop     bc                              ; restore name length
                        ex      de, hl
                        call    VRAM_WRITE                      ; print string
                        inc     hl                              ; skip separator
                        ret
; End of function centre_print_msg

; ---------------------------------------------------------------------------
aLaser2001:             .ascii 'LASER 2001'                     ; DATA XREF: DISPLAY_LOGO+10o
aExpansionModul:        .ascii 'EXPANSION MODULE #1'            ; DATA XREF: DISPLAY_LOGO+1Co
a1984Vtl:               .ascii '1984 VTL'                       ; DATA XREF: DISPLAY_LOGO+28o

; =============== S U B R O U T I N E =======================================


DISPLAY_LOGO:                                                   ; CODE XREF: ROM:GAME_OPT_p
                                                                ; BOOT_UP+1B8Dp ...
                        ld      hl, #0                          ; VDP RAM offset
                        ld      de, #0x4000                     ; 16kB
                        xor     a                               ; fill=$00
                        call    FILL_VRAM_
                        call    MODE_1_
                        call    LOAD_ASCII_
                        ld      hl, #aLaser2001                 ; "LASER 2001"
                        ld      de, #0x182B
                        ld      bc, #10                         ; length
                        call    VRAM_WRITE
                        ld      hl, #aExpansionModul            ; "EXPANSION MODULE #1"
                        ld      de, #0x1867                     ; VDP RAM offset
                        ld      bc, #19                         ; length
                        call    VRAM_WRITE
                        ld      hl, #a1984Vtl                   ; "1984 VTL"
                        ld      de, #0x19EC                     ; VDP RAM offset
                        ld      bc, #8                          ; length
                        call    VRAM_WRITE
                        ld      hl, #0x2000                     ; VDP RAM offset
                        ld      de, #32                         ; length
                        ld      a, #0xF0 ; 'ð'                  ; fill char
                        jp      FILL_VRAM_
; End of function DISPLAY_LOGO

; ---------------------------------------------------------------------------
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
                        .db 0xBF ; ¿
                        .db 0xFF
                        .db 0xFF
                        .db 0xFF
                        .db 0xBE ; ¾
RAND_GEN:               .dw RAND_GEN_                           ; DATA XREF: ROM:0D96o
PUTOBJ:                 .dw PUTOBJ_
ACTIVATE:               .dw ACTIVATE_
SOUND_MAN:              .dw SND_MANAGER
PLAY_IT:                .dw JUKE_BOX
SOUND_INIT:             .dw INIT_SOUND
POLLER:                 .dw POLLER_
WRITER:                 .dw WRITER_
INIT_WRITER:            .dw INIT_QUEUE
READ_VRAM:              .dw VRAM_READ
WRITE_VRAM:             .dw VRAM_WRITE
READ_REGISTER:          .dw REG_READ
WRITE_REGISTER:         .dw REG_WRITE
TURN_OFF_SOUND:         .dw ALL_OFF
TIME_MGR:               .dw TIME_MGR_
TEST_SIGNAL:            .dw TEST_SIGNAL_
REQUEST_SIGNAL:         .dw REQUEST_SIGNAL_
FREE_SIGNAL:            .dw FREE_SIGNAL_
INIT_TIMER:             .dw INIT_TIMER_
WR_SPR_NM_TBL:          .dw WR_SPR_NM_TBL_
INIT_SPR_ORDER:         .dw INIT_SPR_ORDER_
PUT_VRAM:               .dw PUT_VRAM_
GET_VRAM:               .dw GET_VRAM_
INIT_TABLE:             .dw INIT_TABLE_
PLAY_ITP:               .dw JUKE_BOXQ
SOUND_INITP:            .dw INIT_SOUNDQ
INIT_WRITERP:           .dw INIT_QUEUEQ
READ_VRAMP:             .dw READ_VRAMQ
WRITE_VRAMP:            .dw WRITE_VRAMQ                         ; * BROKEN!
WRITE_REGISTERP:        .dw REG_WRITEQ
TEST_SIGNALP:           .dw TEST_SIGNALQ
REQUEST_SIGNALP:        .dw REQUEST_SIGNALQ
FREE_SIGNALP:           .dw FREE_SIGNALQ
INIT_TIMERP:            .dw INIT_TIMERQ
WR_SPR_NM_TBLP:         .dw WR_SPR_NM_TBLQ
INIT_SPR_ORDERP:        .dw INIT_SPR_ORDERQ
PUT_VRAMP:              .dw PUT_VRAMQ
GET_VRAMP:              .dw GET_VRAMQ
INIT_TABLEP:            .dw INIT_TABLEQ
UPDATE_SPINNER:         .dw UPDATE_SPINNER_
MODE_1:                 .dw MODE_1_
FILL_VRAM:              .dw FILL_VRAM_
LOAD_ASCII:             .dw LOAD_ASCII_
GAME_OPT:               .dw GAME_OPT_
DECODER:                .dw DECODER_
CONTROLLER_SCAN:        .dw CONT_SCAN
ENLARGE:                .dw ENLRG
ROTATE_90:              .dw ROT_90
REFLECT_HORIZONTAL:     .dw RFLCT_HOR
REFLECT_VERTICAL:       .dw RFLCT_VERT
PUTOBJP:                .dw PUTOBJQ
ACTIVATEP:              .dw ACTIVATEQ
PLAYSONGS:              .dw PLAY_SONGS_
;
; this is where the jump table in the orignal BIOS is based
;
                        .org 0x1F61
.ifdef BUILDOPT_LASER_FIXES
JUMP_TABLE:
                        jp PLAY_SONGS_ ; ($1F61) See page 86
                        jp ACTIVATEQ ; ($1F64) See page 93
                        jp PUTOBJQ ; ($1F67) See page 102
                        jp RFLCT_VERT ; ($1F6A) See page 168
                        jp RFLCT_HOR ; ($1F6D) See page 168
                        jp ROT_90 ; ($1F70) See page 169
                        jp ENLRG ; ($1F73) See page 169
                        jp CONT_SCAN ; ($1F76) See page 140
                        jp DECODER_ ; ($1F79) See page 141
                        jp GAME_OPT_ ; ($1F7C) See page 155
                        jp LOAD_ASCII_ ; ($1F7F) See page 153
                        jp FILL_VRAM_ ; ($1F82) See page 152
                        jp MODE_1_ ; ($1F85) See page 153
                        jp UPDATE_SPINNER_ ; ($1F88) See page 141
                        jp INIT_TABLEQ ; ($1F8B) See page 158
                        jp GET_VRAMQ ; ($1F8E) See page 159
                        jp PUT_VRAMQ ; ($1F91) See page 161
                        jp INIT_SPR_ORDERQ ; ($1F94) See page 162
                        jp WR_SPR_NM_TBLQ ; ($1F97) See page 163
                        jp INIT_TIMERQ ; ($1F9A) See page 133
                        jp FREE_SIGNALQ ; ($1F9D) See page 133
                        jp REQUEST_SIGNALQ ; ($1FA0) See page 135
                        jp TEST_SIGNALQ ; ($1FA3) See page 137
                        jp REG_WRITEQ ; ($1FA6) See page 165
                        jp WRITE_VRAMQ ; ($1FA9) See page 166
                        jp READ_VRAMQ ; ($1FAC) See page 167
                        jp INIT_QUEUEQ ; ($1FAF) See page 100
                        jp INIT_SOUNDQ ; ($1FB2) See page 80
                        jp JUKE_BOXQ ; ($1FB5) See page 82
                        jp INIT_TABLE_ ; ($1FB8) See page 158
                        jp GET_VRAM_ ; ($1FBB) See page 160
                        jp PUT_VRAM_ ; ($1FBE) See page 162
                        jp INIT_SPR_ORDER_ ; ($1FC1) See page 162
                        jp WR_SPR_NM_TBL_ ; ($1FC4) See page 163
                        jp INIT_TIMER_ ; ($1FC7) See page 133
                        jp FREE_SIGNAL_ ; ($1FCA) See page 133
                        jp REQUEST_SIGNAL_ ; ($1FCD) See page 135
                        jp TEST_SIGNAL_ ; ($1FD0) See page 137
                        jp TIME_MGR_ ; ($1FD3) See page 131
                        jp ALL_OFF ; ($1FD6) See page 81
                        jp REG_WRITE ; ($1FD9) See page 165
                        jp REG_READ ; ($1FDC) See page 167
                        jp VRAM_WRITE ; ($1FDF) See page 166
                        jp VRAM_READ ; ($1FE2) See page 167
                        jp INIT_QUEUE ; ($1FE5) See page 100
                        jp WRITER_ ; ($1FE8) See page 100
                        jp POLLER_ ; ($1FEB) See page 142
                        jp INIT_SOUND ; ($1FEE) See page 80
                        jp JUKE_BOX ; ($1FF1) See page 82
                        jp SND_MANAGER ; ($1FF4) See page 83
                        jp ACTIVATE_ ; ($1FF7) See page 93
                        jp PUTOBJ_ ; ($1FFA) See page 102
                        jp RAND_GEN_ ; ($1FFD) See page 68
.else
                        .rept 53
                        .db 0xff, 0xff, 0xff
                        .endm
.endif
; end of 'ROM'

; ===========================================================================

; Segment type: Regular
                        .org 0x7000
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
PTR_LST_OF_SND_ADDRS:   .ds 2                                   ; DATA XREF: ROM:INIT_SOUNDw
                                                                ; PT_IX_TO_SxDATAr
PTR_TO_S_ON_0:          .ds 2                                   ; DATA XREF: ROM:18DDr
                                                                ; UP_CH_DATA_PTRS+5w ...
PTR_TO_S_ON_1:          .ds 2                                   ; DATA XREF: ROM:18B8r
                                                                ; UP_CH_DATA_PTRS+8w ...
PTR_TO_S_ON_2:          .ds 2                                   ; DATA XREF: ROM:18C5r
                                                                ; UP_CH_DATA_PTRS+Bw ...
PTR_TO_S_ON_3:          .ds 2                                   ; DATA XREF: ROM:18D2r
                                                                ; UP_CH_DATA_PTRS+Ew ...
SAVE_CTRL:              .ds 1                                   ; DATA XREF: ROM:18A7o
                                                                ; ROM:19D2w
                        .ds 0x38E
STACK:                  .ds 1                                   ; DATA XREF: BOOT_UPo
PARAM_AREA:             .ds 6                                   ; DATA XREF: ROM:014Eo
                                                                ; ROM:0154r ...
TIMER_LENGTH:           .ds 2                                   ; DATA XREF: ROM:080Ar
TEST_SIG_NUM:           .ds 1                                   ; DATA XREF: ROM:0790o
                                                                ; ROM:0796r
VDP_MODE_WORD:          .ds 2                                   ; DATA XREF: MODE_1_+3w
                                                                ; REG_WRITE+Ew ...
VDP_STATUS_BYTE:        .ds 1
DEFER_WRITES:           .ds 1                                   ; DATA XREF: PUTOBJ_r
                                                                ; ROM:156Bw ...
MUX_SPRITES:            .ds 1                                   ; DATA XREF: PUT_VRAM_+5r
RAND_NUM:               .ds 2                                   ; DATA XREF: ROM:RAND_GEN_r
                                                                ; ROM:092Dw ...
QUEUE_SIZE:             .ds 1                                   ; DATA XREF: PUTOBJ_+18o
                                                                ; ROM:159Do ...
QUEUE_HEAD:             .ds 1                                   ; DATA XREF: ROM:NOT_TOO_BIGw
                                                                ; PUTOBJ_+14r ...
QUEUE_TAIL:             .ds 1                                   ; DATA XREF: ROM:WRTR_ELSEw
                                                                ; ROM:WRTR_END_IFr ...
HEAD_ADDRESS:           .ds 2                                   ; DATA XREF: ROM:1524w
                                                                ; PUTOBJ_+9r ...
TAIL_ADDRESS:           .ds 2                                   ; DATA XREF: ROM:1573w
                                                                ; ROM:1589r ...
BUFFER:                 .ds 2                                   ; DATA XREF: PUTOBJ_+23r
                                                                ; ROM:15A8r ...
TIMER_TABLE_BASE:       .ds 2                                   ; DATA XREF: ROM:079Ar
                                                                ; ROM:0812r ...
NEXT_TIMER_DATA_BYTE:   .ds 2                                   ; DATA XREF: ROM:07E2r
                                                                ; ROM:07F6w ...
DBNCE_BUFF:             .ds 0x14                                ; DATA XREF: ROM:0669o
                                                                ; ROM:0752o
SPIN_SW0_CT:            .ds 1                                   ; DATA XREF: ROM:0687o
                                                                ; ROM:06DFo ...
SPIN_SW1_CT:            .ds 1                                   ; DATA XREF: ROM:06B2o
                                                                ; ROM:076Dw
                        .ds 1
S0_C0:                  .ds 1                                   ; DATA XREF: ROM:0684r
                                                                ; CONT_SCAN+3w ...
S0_C1:                  .ds 1                                   ; DATA XREF: ROM:06AFr
                                                                ; CONT_SCAN+9w ...
S1_C0:                  .ds 1                                   ; DATA XREF: ROM:0692r
                                                                ; CONT_SCAN+14w ...
S1_C1:                  .ds 1                                   ; DATA XREF: ROM:06BCr
                                                                ; CONT_SCAN+1Aw ...
VRAM_ADDR_TABLE:        .ds 2                                   ; DATA XREF: MODE_1_+9o
                                                                ; ROM:01A3o ...
                                                                ; ; aka SPRINTNAMETBL
SPRITEGENTBL:           .ds 2
PATTERNNAMETBL:         .ds 2
PATTERNGENTBL:          .ds 2
COLORTBL:               .ds 2
SAVE_TEMP:              .ds 2
SAVED_COUNT:            .ds 2                                   ; DATA XREF: SET_COUNTw
                                                                ; SET_COUNT+2Br ...
; end of 'RAM'

; ===========================================================================

; Segment type: Regular
                        .org 0x7400
msg_buf:                .ds 0x10                                ; DATA XREF: ROM:008Co
                                                                ; ROM:0094o ...
                        .ds 0x3F0
; end of 'RAM_2'

; ===========================================================================

; Segment type: Regular
                        .org 0x8000
CARTRIDGE:              .ds 2                                   ; DATA XREF: BOOT_UP+1B78r
                                                                ; BOOT_UP+1B82r
LOCAL_SPR_TBL:          .ds 2                                   ; DATA XREF: ROM:OUTPUT_LOOP_TABLE_MAr
                                                                ; PUT_VRAM_+Er
SPRITE_ORDER:           .ds 2                                   ; DATA XREF: ROM:WR_SPR_NM_TBL_r
                                                                ; ROM:01E4r
WORK_BUFFER:            .ds 2                                   ; DATA XREF: PUT_COLOR+6r
                                                                ; GET_COLOR+6r ...
CONTROLLER_MAP:         .ds 2                                   ; DATA XREF: ROM:066Dr
                                                                ; ROM:074Ar ...
START_GAME:             .ds 2                                   ; DATA XREF: BOOT_UP+1B6Er
RST_8H_RAM:             .ds 3
RST_10H_RAM:            .ds 3
RST_18H_RAM:            .ds 3
RST_20H_RAM:            .ds 3
RST_28H_RAM:            .ds 3
RST_30H_RAM:            .ds 3
IRQ_INT_VECT:           .ds 3
NMI_INT_VECT:           .ds 3
GAME_NAME:              .ds 1                                   ; DATA XREF: BOOT_UP+1BE4o
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
                        .ds 1
; end of 'CART_ROM'

; end of file
