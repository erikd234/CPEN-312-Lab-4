$MODDE0CV

org 0
;; Note that the B register will always contain whatever mode we are in.
ljmp start
;This file will contain the structure for reading the switches and key 0

; this checks to see if the key has been pressed and if the program should latch in the numbers.
check_key:
	jnb key.3, latch_input ; when key 3 is pressed we will jump to latch in the switches
	ret

; stores all the accumulator switch values in memory location 0F
latch_input:
 	mov a, swa ; getting switch values
	mov r5, a ; load switch value to memory
	lcall update_leds
	sjmp loop_000
	
; write input to LED lights 
; this verifies everything was latched correctly
update_leds:
	mov a, r5
	mov ledra, a ;0FH is latch memory direct
	mov ledrb, #0H
	ret


start:
; clear all LED lights
	mov ledra, #0H
	mov ledrb, #0H
	mov r5, #0H
	clr C

loop_000:
	lcall check_key ; checks for latch input
	cjne r5, #0, loop_001 ; if not 0 go to 2
	; DO SOMETHING
	sjmp loop_000
	
loop_001:
	lcall check_key
	cjne r5, #1, loop_010 ; same logic as above
	; DO SOMETHING
	sjmp loop_001
	
loop_010:
	lcall check_key
	cjne r5, #2, loop_011
	; DO SOMETHING
	sjmp loop_010
	
loop_011:
	lcall check_key
	cjne r5, #3, loop_100
	; DO SOMETHING
	sjmp loop_011
	
loop_100:
	lcall check_key
	cjne r5, #4, loop_101
	; DO SOMETHING
	sjmp loop_100

loop_101:
	lcall check_key
	cjne r5, #5, loop_111
	; DO SOMETHING
	sjmp loop_101


loop_110:
	lcall check_key
	cjne r5, #6, loop_111
	; DO SOMETHING
	sjmp loop_101
	
loop_111:
	lcall check_key
	cjne r5, #7, loop_000
	; DO SOMETHING
	sjmp loop_111


END