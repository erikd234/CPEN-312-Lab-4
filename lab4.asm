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

org 0
ljmp start ; jumping to the start of the program


; initializing the registers to store initial values
initialize_registers:
	mov r7, #L_7
	mov r6, #L_6
	mov r5, #L_5
	mov r4, #L_4
	mov r3, #L_3
	mov r2, #L_2 ; 7
	mov r1, #L_1 ; 5
	mov r0, #L_0 ; 7
	ret
;; jumping to the main loop of the program
 
; subroutine that updates the displays from the registers displaying MSD of the number
update_displays_msd:
	clr a
	mov a, r7
	mov hex5, a
	mov a, r6
	mov hex4, a
	mov a, r5
	mov hex3, a
	mov a, r4
	mov hex2, a
	mov a, r3
	mov hex1, a
	mov a, r2
	mov hex0, a
	ret
; subroutine that updates the displays from the registers displaying LSD of the number	
update_displays_lsd:
	clr a
	mov a, r5
	mov hex5, a
	mov a, r4
	mov hex4, a
	mov a, r3
	mov hex3, a
	mov a, r2
	mov hex2, a
	mov a, r1
	mov hex1, a
	mov a, r0
	mov hex0, a
	ret
	
; this subroutine shifts all the data in the registers over to the right
shift_registers_right:
	clr a
	mov a, r7 ; a = 8
	xch a, r6 ; r6 = 8 a = 2
	xch a, r5 ; r5 = 2 a = 9
	xch a, r4 ; r4 = 9 a = 4
	xch a, r3 ; r3 = 4, a = 6
	xch a, r2 ; r3 = 4, a = 6
	xch a, r1
	xch a, r0
	mov r7, a
	ret
	
shift_registers_left:
	clr a
	mov a, r0 ; r3 = 4, a = 6
	xch a, r1
	xch a, r2
	xch a, r3 ; a = 8
	xch a, r4 ; r6 = 8 a = 2
	xch a, r5 ; r5 = 2 a = 9
	xch a, r6 ; r4 = 9 a = 4
	xch a, r7 ; r3 = 4, a = 6
	mov r0, a
	ret
	
; subroutine that displays the six most sifnigicant digits of my student number
display_student_number: 	
	lcall initialize_registers
	lcall update_displays_msd
	
; subroutine that sets the screens to blank.
clear_screen:	
	mov r7, #BLANK
	mov r6, #BLANK
	mov r5, #BLANK
	mov r4, #BLANK
	mov r3, #BLANK
	mov r2, #BLANK
	mov r1, #BLANK
	mov r0, #BLANK
	lcall update_displays_msd
	ret
	
	
; sub routine that displays the last two student numbers and leaves the rest of the displays blank.
display_last_two: 
	lcall clear_screen
	mov hex1, #L_1
	mov hex0, #L_0
	ret

; this blinks the lest 6 significant digists of my student number

blink_student_number:
	lcall initialize_registers
	lcall update_displays_lsd
	lcall wait
	lcall clear_screen
	lcall wait
	lcall initialize_registers
	lcall update_displays_lsd
	ret


; this is a subroutine that makes each digit of my student number appear one at a time
one_at_a_time:
	lcall clear_screen
	lcall wait
	mov hex5, #L_7
	lcall wait
	mov hex4, #L_6
	lcall wait
	mov hex3, #L_5
	lcall wait
	mov hex2, #L_4
	lcall wait
	mov hex1, #L_3
	lcall wait
	mov hex0, #L_2
	lcall wait
	ret

; this is a subroutine that displays HELLO for one second,
; then the six most significant digits of my student number
; then CPEN312
; each step should have a duration of one second.
hello_cpen:
	lcall display_hello
	lcall wait
	lcall initialize_registers ; making sure the registers have the correct data
	lcall update_displays_msd ; updating the display with the most msd of the student number
	lcall wait
	lcall display_cpen
	lcall wait
	ret
	
	
display_hello:
	mov hex5, #9H ; displays 'H'
	mov hex4, #6H ; displays 'E'
	mov hex3, #47H ; displays 'L'
	mov hex2, #47H ; displays 'L'
	mov hex1, #40H ; displays 'O'
	mov hex0, #BLANK ; displays 'blank'	
	ret
	
display_cpen:
	mov hex5, #46H	; displays 'C'
	mov hex4, #0CH	; displays 'P'
	mov hex3, #48H	; displays 'N'
	mov hex2, #30H	; displays '3'
	mov hex1, #79H	; displays '1'
	mov hex0, #24H	; displays '2'
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

start:
		

forever_loop:
	
	lcall hello_cpen
	ljmp forever_loop 




end