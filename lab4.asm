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


mov ledra, #0H
mov ledrb, #0H
mov r4, #0H
clr C	


loop_000: ; display MSB student numbers
	;initialize_registers
	mov sp, #7fH ; initialize the stack! (trust me for now!)
	mov r7, #L_7
	mov r6, #L_6
	mov r5, #L_5
	mov 0FH, #L_4 ; range register with 0FH
	mov r3, #L_3
	mov r2, #L_2 ; 7
	mov r1, #L_1 ; 5
	mov r0, #L_0 ; 7
	
	jnb key.3, latch_intermidiate ; checks the key  when key 3 is pressed we will jump to latch in the switches
	cjne r4, #0, loop_001 ; if not 0 go to 2
	mov hex5, #L_7 ; displays '8'
	mov hex4, #L_6; displays '2'
	mov hex3, #L_5 ; displays '9'
	mov hex2, #L_4 ; displays '4'
	mov hex1, #L_3 ; displays '6'
	mov hex0, #L_2 ; displays '7'
	sjmp loop_000


;; jumping to the main loop of the program
	
loop_001: ; last two student numbers
	jnb key.3, latch_intermidiate 
	cjne r4, #1, loop_010 ; same logic as above
	; display_last_two 
	mov hex5, #BLANK
	mov hex4, #BLANK
	mov hex3, #BLANK
	mov hex2, #BLANK
	mov hex1, #L_1
	mov hex0, #L_0
	sjmp loop_001
	 

; this subroutine shifts all the data in the registers over to the right
shift_registers_right:
	clr a
	mov a, r7 ; a = 8
	xch a, r6 ; r6 = 8 a = 2
	xch a, r5 ; r5 = 2 a = 9
	xch a, 0FH ; 0FH = 9 a = 4
	xch a, r3 ; r3 = 4, a = 6
	xch a, r2 ; r3 = 4, a = 6
	xch a, r1
	xch a, r0
	mov r7, a
	ret

latch_intermidiate:
	ljmp latch_input
		
shift_registers_left:
	clr a
	mov a, r0 ; r3 = 4, a = 6
	xch a, r1
	xch a, r2
	xch a, r3 ; a = 8
	xch a, 0FH ; r6 = 8 a = 2
	xch a, r5 ; r5 = 2 a = 9
	xch a, r6 ; 0FH = 9 a = 4
	xch a, r7 ; r3 = 4, a = 6
	mov r0, a
	ret
	
loop_010: ; shift student number right
	jnb key.3, latch_input ; checks the key  when key 3 is pressed we will jump to latch in the switches
	cjne r4, #2, loop_011
	lcall update_displays_msd
	lcall wait
	lcall shift_registers_right
	sjmp loop_010

; subroutine that updates the displays from the registers displaying MSD of the number
update_displays_msd:
	clr a
	mov a, r7
	mov hex5, a
	mov a, r6
	mov hex4, a
	mov a, r5
	mov hex3, a
	mov a, 0FH
	mov hex2, a
	mov a, r3
	mov hex1, a
	mov a, r2
	mov hex0, a
	ret

loop_011: ; shift student number left
	jnb key.3, latch_input ; checks the key  when key 3 is pressed we will jump to latch in the switches
	cjne r4, #3, loop_100
	lcall update_displays_msd
	lcall wait
	lcall shift_registers_left
	sjmp loop_011
	

; this is the subroutine that causes a delay in the program
wait:
    mov 0BH, #130  ; 90 is 5AH
L3: mov 0AH, #250 ; 250 is FAH 
L2: mov 9H, #250
L1: djnz 9H, L1  ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz 0AH, L2  ; 22.5us*250=5.625ms
    djnz 0BH, L3  ; 5.625ms*90=0.506s (approximately)
	ret

	
latch_input:
 	mov a, swa ; getting switch values
	mov r4, a ; load switch value to memory
	lcall update_leds
	ljmp loop_000


; write input to LED lights 
; this verifies everything was latched correctly
update_leds:
	mov a, r4
	mov ledra, a ;0FH is latch memory direct
	mov ledrb, #0H
	ret	

; initializing the registers to store initial values
initialize_registers:
	mov r7, #L_7
	mov r6, #L_6
	mov r5, #L_5
	mov 0FH, #L_4
	mov r3, #L_3
	mov r2, #L_2 ; 7
	mov r1, #L_1 ; 5
	mov r0, #L_0 ; 7
	ret
; subroutine that updates the displays from the registers displaying LSD of the number	


	
loop_100: ; blink
	jnb key.3, latch_input ; checks the key  when key 3 is pressed we will jump to latch in the switches
	cjne r4, #4, loop_101
	lcall display_lsd
	lcall wait2
	lcall clear_screen
	lcall wait2
	lcall display_lsd
	sjmp loop_100

display_lsd: 
	mov hex5, #L_5 ; displays '9'
	mov hex4, #L_4 ; displays '4'
	mov hex3, #L_3 ; displays '6'
	mov hex2, #L_2 ; displays '7'
	mov hex1, #L_1 ; displays '5'
	mov hex0, #L_0 ; displays '7'
	ret	
; subroutine that sets the screens to blank.
clear_screen:	
	mov hex5, #BLANK
	mov hex4, #BLANK
	mov hex3, #BLANK
	mov hex2, #BLANK
	mov hex1, #BLANK
	mov hex0, #BLANK
	ret
	
loop_101: ; display one at a time
	jnb key.3, latch_intermidiate_2  ; checks the key  when key 3 is pressed we will jump to latch in the switches
	cjne r4, #5, loop_110
	mov hex5, #BLANK
	mov hex4, #BLANK
	mov hex3, #BLANK
	mov hex2, #BLANK
	mov hex1, #BLANK
	mov hex0, #BLANK
	lcall wait2
	mov hex5, #L_7
	mov hex4, #L_6
	mov hex3, #L_5
	mov hex2, #L_4
	mov hex1, #L_3
	mov hex0, #L_2
	sjmp loop_101

wait2:
    mov 0BH, #130  ; 90 is 5AH
L3_2: mov 0AH, #250 ; 250 is FAH 
L2_2: mov 9H, #250
L1_2: djnz 9H, L1_2  ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz 0AH, L2_2  ; 22.5us*250=5.625ms
    djnz 0BH, L3_2  ; 5.625ms*90=0.506s (approximately)
	ret

latch_intermidiate_2:
	ljmp latch_input

inter_loop_111:
	ljmp loop_111

inter_loop_000:
	ljmp loop_100


; this is a subroutine that displays HELLO for one second,
; then the six most significant digits of my student number
; then CPEN312
; each step should have a duration of one second.
loop_110:
	jnb key.3, latch_intermidiate_2 ; checks the key  when key 3 is pressed we will jump to latch in the switches
	cjne r4, #6, inter_loop_111
	; hello cpen
	lcall wait3	
	mov hex5, #9H ; displays 'H'
	mov hex4, #6H ; displays 'E'
	mov hex3, #47H ; displays 'L'
	mov hex2, #47H ; displays 'L'
	mov hex1, #40H ; displays 'O'
	mov hex0, #BLANK ; displays 'blank'	
	; manual wait
	lcall wait3
	mov hex5, #L_7 ; displays '8'
	mov hex4, #L_6; displays '2'
	mov hex3, #L_5 ; displays '9'
	mov hex2, #L_4 ; displays '4'
	mov hex1, #L_3 ; displays '6'
	mov hex0, #L_2 ; displays '7'	
	lcall wait3
	; display_cpen
	mov hex5, #46H	; displays 'C'
	mov hex4, #0CH	; displays 'P'
	mov hex3, #48H	; displays 'N'
	mov hex2, #30H	; displays '3'
	mov hex1, #79H	; displays '1'
	mov hex0, #24H	; displays '2'
	lcall wait3
	ljmp loop_101

wait3:
    mov 0BH, #130  ; 90 is 5AH
L3_3: mov 0AH, #250 ; 250 is FAH 
L2_3: mov 9H, #250
L1_3: djnz 9H, L1_3  ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz 0AH, L2_3 ; 22.5us*250=5.625ms
    djnz 0BH, L3_3  ; 5.625ms*90=0.506s (approximately)
	ret
	
; this blinks the lest 6 significant digists of my student number



loop_111:
	jnb key.3, latch_intermidiate_2 ; checks the key  when key 3 is pressed we will jump to latch in the switches
	cjne r4, #7, inter_loop_000
	mov hex5, #78H
	sjmp loop_111


end