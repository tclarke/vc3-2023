;===========================================================================
; main.asm
;===========================================================================

; debugging aids
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


 ; Store all the code starting at $8000
 ; You can check code size by starting the debugger,
 ; looking at the address of stack_top, and subtracting
 ; $8000
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
    ; Disable interrupts and setup the stack
    di
    ld sp,stack_bottom

    ; Clear the screen
    ld a, $47
	LD HL,16384			; Start address of screen bitmap
	LD DE,16385			; Address + 1
	LD BC,6144			; Length of bitmap memory to clear
	LD (HL),0			; Set the first byte to 0
	LDIR				; Copy this byte to the second, and so on
	LD BC,767			; Length of attribute memory, less one to clear
	LD (HL),A			; Set the first byte to A
	LDIR				; Copy this byte to the second, and so on

main_loop:
    ; We really want to just load the val on top of the
    ; stack but you can't do that directly. pop/push is much
    ; slower than pop/dec/dec but it uses 1 less byte
    pop  hl
    push hl
    call down_left

    ; copy again
    pop  hl
    push hl
    call down_right

    ; last routine so we can just pop
    pop  hl
    call up_right

    ; if the sp is at the top of stack, we can jump out and halt
    ; otherwise grab the next coordinate
    ld  hl, stack_top
    sbc hl, sp
    jp  z, 1F
    jp main_loop

1:
    halt

down_left:
    ; hl is used to pass the coordinate to Print_Char_At
    ; which clobbers it so we save a copy
    push hl
    ; a is the character to draw
    ld  a, '*'
    call Print_Char_At

    ; restore hl
    pop hl
    ; increment h which is the row
    ; then see if it's equal to 19.
    ; There are 19 rows and 19 columns
    ; in the expected output.
    inc h
    ld  a, $13
    cp  h
    ret z

    ; decrement l which is the column
    ; then see if we've gone past the edge (0)
    dec l
    ret  m
    
    ; repeat until we hit an edge
    jp  down_left

down_right: 
    ; works just like down_left except we increment
    ; both coordinates. We don't need to draw the
    ; first coordinate again so we increment before
    ; calling Print_Char_At
    inc h
    ld  a, $13
    cp  h
    ret z

    inc l
    cp  l
    ret z
    
    push hl
    ld  a, '*'
    call Print_Char_At

    pop hl
    jp  down_right

up_right: 
    ; works like the other two except we decrement the row
    ; and increment the column. There's no up_left since it's
    ; not necessary to complete the output.
    dec h
    ret  m

    inc l
    ld  a, $13
    cp  l
    ret z

    push hl
    ld  a, '*'
    call Print_Char_At

    pop hl
    jp  up_right


;===========================================================================
; Stack.
;===========================================================================

; ensure there's enough of room for subroutines. We go 4 calls deep
; so we need to save room for 4 return addresses
    defw    $0000
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


; SjASMPlus pseudo ops to save a memory snapshot of the
; compiled program. SNA is for the 48k and NEX is for the NEXT.
; Set NEX at the top of this file.
    IF NEX == 0
        SAVESNA "vc3-2023.sna", main
    ELSE
        SAVENEX OPEN "vc3-2023.nex", main
        SAVENEX CORE 3, 1, 5
        SAVENEX CFG 7   ; Border color
        SAVENEX AUTO
        SAVENEX CLOSE
    ENDIF