;
; Title:	ZX Spectrum Standard Output Routines
; Author:	Dean Belfield
; Created:	29/07/2011
; Last Updated:	08/02/2020
;
; Requires:
;
; Modinfo:
;
; 02/07/2012:	Added Pixel_Address_Down and Pixel_Address_Up routines
; 04/07/2012:	Moved Clear_Screen to Screen_Buffer
; 08/02/2010:	Added Print_BC
;		Moved Clear_Screen into here (originally in screen_buffer.z80)
;		All output routines refactored to use HL for screen address
;		Added Fill_Attr routine
;

; Simple clear-screen routine
; Uses LDIR to block clear memory
; A:  Colour to clear attribute block of memory with
;
Clear_Screen:		LD HL,16384			; Start address of screen bitmap
			LD DE,16385			; Address + 1
			LD BC,6144			; Length of bitmap memory to clear
			LD (HL),0			; Set the first byte to 0
			LDIR				; Copy this byte to the second, and so on
			LD BC,767			; Length of attribute memory, less one to clear
			LD (HL),A			; Set the first byte to A
			LDIR				; Copy this byte to the second, and so on
			RET

; Get screen address
; H = Y character position
; L = X character position
; Returns address in HL
;
Get_Char_Address:	LD A,H
			AND %00000111
			RRA
			RRA
			RRA
			RRA
			OR L
			LD L,A
			LD A,H
			AND %00011000
			OR %01000000
			LD H,A
			RET				; Returns screen address in HL

; Print a single character out to an X/Y position
;  A: Character to print
;  C: X Coordinate
;  B: Y Coordinate
; DE: Address of character set
;
Print_Char_At:		PUSH AF
			CALL Get_Char_Address
			POP AF				; Fall through to Print_Char
;
; Print a single character out to a screen address
;  A:  Character to print
;  HL: Screen address to print character at
;  DE: Address of character set (if entering at Print_Char_UDG)
; No SM code here - needs to be re-enterent if called on interrupt
;
Print_Char:		LD DE, 0x3C00			; Address of character set in ROM
			PUSH HL
			LD B, 0				; Get index into character set
			LD C, A
			DUP 3
			SLA C
			RL B
			EDUP
			EX DE, HL
			ADD HL, BC 
			EX DE, HL	
			CALL Print_UDG8
			POP HL
			RET 	

; Print a UDG (Single Height)
; DE - Character data
; HL - Screen address
;
Print_UDG8:		LD B,8				; Loop counter
2:			LD A,(DE)			; Get the byte from the ROM into A
			LD (HL),A			; Stick A onto the screen
			INC DE				; Goto next byte of character
			INC H				; Goto next line on screen
			DJNZ 2B				; Loop around whilst it is Not Zero (NZ)
			RET