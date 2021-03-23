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
; initializing the registers to store initial values
mov r7, #L_7
mov r6, #L_6
mov r5, #L_5
mov r4, #L_4
mov r3, #L_3
mov r2, #L_2 ; 7
mov r1, #L_1 ; 5
mov r0, #L_0 ; 7

;; jumping to the main loop of the program
 ljmp forever_loop;
; subroutine that updates the displays from the registers
update_displays:
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
	
	
; this is the subroutine that causes a delay in the program
wait:
    mov 0BH, #180  ; 90 is 5AH
L3: mov 0AH, #250 ; 250 is FAH 
L2: mov 9H, #250
L1: djnz 9H, L1  ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz 0AH, L2  ; 22.5us*250=5.625ms
    djnz 0BH, L3  ; 5.625ms*90=0.506s (approximately)
	ret
	

forever_loop:
	lcall update_displays
	lcall wait
	lcall shift_registers_left
	ljmp forever_loop 




end