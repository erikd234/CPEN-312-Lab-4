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
mov 0FH, #L_7
mov 0EH, #L_6
mov 0DH, #L_5
mov 0CH, #L_4
mov 0BH, #L_3
mov 0AH, #L_2 ; 7
mov 9H, #L_1 ; 5
mov 8H, #L_0 ; 7

;; jumping to the main loop of the program
 ljmp forever_loop;
; subroutine that updates the displays from the registers
update_displays:
	clr a
	mov a,0FH
	mov hex5, a
	mov a,0EH
	mov hex4, a
	mov a,0DH
	mov hex3, a
	mov a,0CH
	mov hex2, a
	mov a,0BH
	mov hex1, a
	mov a,0AH
	mov hex0, a
	ret

forever_loop:
	lcall update_displays
	lcall wait
	lcall shift_registers_right
	sjmp forever_loop






; this subroutine shifts all the data in the registers over to the right
shift_registers_right:
	clr a
	mov a,0FH ; a = 8
	xch a,0EH ; r6 = 8 a = 2
	xch a,0DH ; r5 = 2 a = 9
	xch a,0CH ; r4 = 9 a = 4
	xch a,0BH ; r3 = 4, a = 6
	xch a,0AH ; r3 = 4, a = 6
	xch a,9H
	xch a,8H
	mov 0FH, a
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
    mov r2, #180  ; 90 is 5AH
L3: mov r1, #250 ; 250 is FAH 
L2: mov r0, #250
L1: djnz R0, L1  ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz r1, L2  ; 22.5us*250=5.625ms
    djnz r2, L3  ; 5.625ms*90=0.506s (approximately)
	ret
	

end