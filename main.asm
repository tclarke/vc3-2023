;===========================================================================
; main.asm
;===========================================================================

    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

NEX:    equ 0   ;  1=Create nex file, 0=create sna file

    IF NEX == 0
        ;DEVICE ZXSPECTRUM128
        DEVICE ZXSPECTRUM48
        ;DEVICE NOSLOT64K
    ELSE
        DEVICE ZXSPECTRUMNEXT
    ENDIF

    ORG 0x4000
    defs 0x6000 - $    ; move after screen area
screen_top: defb    0   ; WPMEMx


 defs 0x8000 - $
 ORG $8000

;===========================================================================
; Include modules
;===========================================================================
    include "output.asm"

;===========================================================================
; main routine - the code execution starts here.
; Sets up the new interrupt routine, the memory
; banks and jumps to the start loop.
;===========================================================================


main:
    ; Disable interrupts
    di
    ld sp,stack_bottom

    ld a, $47
    call Clear_Screen

main_loop:
    pop  hl
    dec  sp
    dec  sp

    call down_left
    pop  hl
    dec  sp
    dec  sp
    call down_right
    pop  hl
    call up_right

    ld  hl, stack_top
    sbc hl, sp
    jp  z, 1F
    jp main_loop

1:
    halt

down_left:
    ; HL is used to 
    ld  ix, hl
    ld  a, '*'
    call Print_Char_At
    ld  hl, ix
    inc h
    ld  a, $13
    cp  h
    ret z
    dec l
    ret  m
    jp  down_left

down_right: 
    inc h
    ld  a, $13
    cp  h
    ret z
    inc l
    cp  l
    ret z
    ld  ix, hl
    ld  a, '*'
    call Print_Char_At
    ld  hl, ix
    jp  down_right

up_right: 
    dec h
    ret  m
    inc l
    ld  a, $13
    cp  l
    ret z
    ld  ix, hl
    ld  a, '*'
    call Print_Char_At
    ld  hl, ix
    jp  up_right


;===========================================================================
; Stack.
;===========================================================================

; ensure there's plenty of room for subroutines
    defw    $0000
    defw    $0000
    defw    $0000
    defw    $0000

; Setup the stack with the start coordinates
; bytes are row, col
stack_bottom:
    defw    $0003
    defw    $0009
    defw    $000f
    defw    $0300
    defw    $0900
    defw    $0f00
    defw    $1203
    defw    $1209
    defw    $120f
stack_top:

    IF NEX == 0
        SAVESNA "vc3-2023.sna", main
    ELSE
        SAVENEX OPEN "vc3-2023.nex", main
        SAVENEX CORE 3, 1, 5
        SAVENEX CFG 7   ; Border color
        SAVENEX AUTO
        SAVENEX CLOSE
    ENDIF