$MODDE0CV
; all the numbers in my student number
L_7 equ 0H ; number 8
L_6 equ 24H ; number 2
L_5 equ 10H ; number 9
L_4 equ 19H ; number 4
L_3 equ 2H ; number 6
L_2 equ 78H ; number 7
L_1 equ 12H ; number 5
L_0 equ 78H ; number 7
BLANK equ 0FFH ; display off
LATCH_mem equ 0FH ; memory adress for the latch

ORG 0
	
	;Turning off all the LEDs
	mov LEDRA, #0
	mov LEDRB, #0
	;initialize the stack! 
	mov sp, #7fH
	
	;Initialize Latch memory
	mov LATCH_mem, #0
	
	; Initializing screen on start up
	lcall display_msd 
	
	;jumping to the start of the program
	ljmp loop_000

	
;********************
;SUBROUTINES SECTION
;********************

; subroutine that sets the screens to blank.
clear_screen:
 	mov a, #BLANK	
	mov hex5, a
	mov hex4, a
	mov hex3, a
	mov hex2, a
	mov hex1, a
	mov hex0, a
	ret
	
display_lsd: 
	mov hex5, #L_5 ; displays '9'
	mov hex4, #L_4 ; displays '4'
	mov hex3, #L_3 ; displays '6'
	mov hex2, #L_2 ; displays '7'
	mov hex1, #L_1 ; displays '5'
	mov hex0, #L_0 ; displays '7'
	ret	
; displays the student numbers
; the overflow student numbers for scroll right and left are stored in register r1 and r0
display_msd: 
	mov hex5, #L_7 ; displays '8'
	mov hex4, #L_6 ; displays '2'
	mov hex3, #L_5 ; displays '9'
	mov hex2, #L_4 ; displays '4'
	mov hex1, #L_3 ; displays '6'
	mov hex0, #L_2 ; displays '7'
	mov r1, #L_1 ; store '5'
	mov r0, #L_0 ; store '7'
	ret	
	
; scroll student number left, r0 and r1 must be initlaized with the student number overflow
; r7 is the store value for the left to right scroll		
scroll_left:	
	mov r7, HEX5
	mov HEX5, HEX4
	mov HEX4, HEX3
	mov HEX3, HEX2
	mov HEX2, HEX1
	mov HEX1, HEX0
	mov HEX0, r1
	mov a, r0
	mov r1, a	
	mov a, r7
	mov r0, a
	ret
	
; scroll student number right, r0 and r1 must be initlaized with the student number overflow
; r7 is the store value for the left to right scroll
scroll_right:
	mov a, r0
    mov r7, a
    mov a, r1
    mov r0, a
	mov r1, hex0
	mov hex0, hex1
	mov hex1, hex2
	mov hex2, hex3
	mov hex3, hex4
	mov hex4, hex5
	mov hex5, r7
	ret
			
	
; write input to LED lights 
; this verifies everything was latched correctly
update_leds:
	mov a, LATCH_mem
	mov ledra, a ;0FH is latch memory direct
	mov ledrb, #0H
	ret	
		
; this is the subroutine that causes a delay in the program
wait:
    mov 0BH, #130  ; 90 is 5AH
L3: mov 0AH, #250 ; 250 is FAH 
L2: mov 9H, #250	
L1: djnz 9H, L1  ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz 0AH, L2  ; 22.5us*250=5.625ms
    djnz 0BH, L3  ; 5.625ms*90=0.506s (approximately)
	ret	

;********************
;Loops Section
;********************

; Displays the 6 MSD of my student number
loop_000:
	jnb key.3, latch_input ; checks the key  when key 3 is pressed we will jump to latch in the switches
	mov a, LATCH_mem; loading latch memory to ACC
	cjne a, #0, loop_001 ; if not 0 go to 2
	lcall display_msd
	sjmp loop_000

; last two student numbers	
loop_001: 
	jnb key.3, latch_input
	mov a, LATCH_mem; loading latch memory to ACC
	cjne a, #1, loop_010 ; same logic as above
	; display_last_two
	mov a, #BLANK 
	mov hex5, a
	mov hex4, a
	mov hex3, a
	mov hex2, a
	mov hex1, #L_1
	mov hex0, #L_0
	sjmp loop_001

;********************
;LATCH mechanism Section
;********************

latch_input:
 	mov a, swa ; getting switch values
	mov LATCH_mem, a ; load switch value to memory
	lcall update_leds
	ljmp loop_000

;********************
;********************	
	
; shift student number right
loop_010:
	lcall display_msd  
Y:	jnb key.3, latch_input ; checks the key  when key 3 is pressed we will jump to latch in the switches
	mov a, LATCH_mem ; loading latch memory to ACC
	cjne a, #2, loop_011
	lcall wait
	lcall scroll_right
	sjmp y

; shift student number left
loop_011:
	lcall display_msd 
Z:	jnb key.3, latch_input ; checks the key  when key 3 is pressed we will jump to latch in the switches
	mov a, LATCH_mem ; loading latch memory to ACC
	cjne a, #3, loop_100
	lcall wait
	lcall scroll_left
	sjmp Z

; blink
loop_100: 
	jnb key.3, latch_input ; checks the key  when key 3 is pressed we will jump to latch in the switches
	mov a, LATCH_mem ; loading latch memory to ACC
	cjne a, #4, loop_101
	lcall display_lsd
	lcall wait
	lcall clear_screen
	lcall wait
	lcall display_lsd
	sjmp loop_100

; display one at a time
loop_101: 
	jnb key.3, latch_input  ; checks the key  when key 3 is pressed
	mov a, LATCH_mem ; loading latch memory to ACC
	cjne a, #5, loop_110
	lcall clear_screen
	lcall wait
	mov hex5, #L_7
	jnb key.3, latch_input  ; adding responsiveness
	lcall wait
	mov hex4, #L_6
	jnb key.3, latch_input  ; adding responsiveness to keypress
	lcall wait
	mov hex3, #L_5
	jnb key.3, latch_input  ; adding responsiveness to keypress
	lcall wait
	mov hex2, #L_4
	jnb key.3, latch_input  ; adding responsiveness to keypress
	lcall wait
	mov hex1, #L_3
	jnb key.3, latch_intermidiate  ; adding responsiveness to keypress
	lcall wait
	mov hex0, #L_2
	jnb key.3, latch_intermidiate  ; adding responsiveness to keypress
	lcall wait
	sjmp loop_101

; this is a loop that displays HELLO for one second,
; then the six most significant digits of my student number
; then CPEN312
; each step should have a duration of one second.
loop_110:
	jnb key.3, latch_intermidiate ; checks the key  when key 3 is pressed we will jump to latch in the switches
	mov a, LATCH_mem ; loading latch memory to ACC
	cjne a, #6, loop_111
	; hello cpen
	lcall wait	
	jnb key.3, latch_intermidiate   ; adding responsiveness to keypress
	mov hex5, #9H ; displays 'H'
	mov hex4, #6H ; displays 'E'
	mov hex3, #47H ; displays 'L'
	mov hex2, #47H ; displays 'L'
	mov hex1, #40H ; displays 'O'
	mov hex0, #BLANK ; displays 'blank'	
	; manual wait
	lcall wait
	jnb key.3, latch_intermidiate   ; adding responsiveness to keypress
	lcall display_msd	
	lcall wait
	; display_cpen
    jnb key.3, latch_intermidiate   ; adding responsiveness to keypress
	mov hex5, #46H	; displays 'C'
	mov hex4, #0CH	; displays 'P'
	mov hex3, #48H	; displays 'N'
	mov hex2, #30H	; displays '3'
	mov hex1, #79H	; displays '1'
	mov hex0, #24H	; displays '2'
	lcall wait
	ljmp loop_110

loop_111:
	jnb key.3, latch_intermidiate ; checks the key  when key 3 is pressed we will jump to latch in the switches
	mov a, LATCH_mem ; loading latch memory to ACC
	cjne a, #7, loop_000_intermediate
	mov hex5, #78H
	sjmp loop_111

;************************
; SJMP BOOSTERS
;************************
latch_intermidiate:
	ljmp latch_input

loop_000_intermediate:
	ljmp loop_000
	
end