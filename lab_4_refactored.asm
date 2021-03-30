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
DESIRED_RESULT equ 80H ; memory adress for animation for 111 case
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
	mov r7, a
	mov r0, a
	mov r1, a
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
; this is the subroutine that causes a delay in the program
short_wait:
    mov 0BH, #10  ; 90 is 5AH
L4: mov 0AH, #220 ; 250 is FAH 
L5: mov 9H, #250	
L6: djnz 9H, L6  ; 3 machine cycles-> 3*30ns*250=22.5us
    djnz 0AH, L5  ; 22.5us*250=5.625ms
    djnz 0BH, L4  ; 5.625ms*90=0.506s (approximately)
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
	lcall clear_screen
j:	jnb key.3, latch_intermidiate ; checks the key  when key 3 is pressed we will jump to latch in the switches
	mov a, LATCH_mem ; loading latch memory to ACC
	cjne a, #7, loop_000_intermediate
	; START OF CREATIVE ANIMATION
	ljmp set_hex5
	sjmp j

;************************
; SJMP BOOSTERS
;************************
latch_intermidiate:
	ljmp latch_input

loop_000_intermediate:
	ljmp loop_000



;***************************	
;CREATIVE FEATURE DO NOT USE r0, r1, r7,
; R4 will store the current result and numbers will be subtracted to this register.
; A will be used to comppair the hex display with the finished result
; DESIRED_RESULT is the part we wish to display for any number.
;**************************

set_hex5:
 	
 	;FINAL RESULT wWE ARE BUILING Is 8 WITCH IS (0000 0000)B
	mov r4, #11111111B ;current result on hex5
set_5:
 	mov a, #11011111B ; load up scroll with the segment we wish to build
	mov hex0, a
	lcall short_wait

build_5:	
	lcall scroll_left_to_4 
	lcall short_wait
	mov a, hex4 ;moving to accumulator for compairing
	cjne a, #11011111B, build_5
	mov hex4, #BLANK
	anl a, hex5
	mov hex5, a
	cjne a, #L_7, set_4
	ljmp do_nothing
	
set_4:
 	mov a, #11101111B ; load up scroll with the segment we wish to build
	mov hex0, a
	lcall short_wait

build_4:	
	lcall scroll_left_to_4 
	lcall short_wait
	mov a, hex4 ;moving to accumulator for compairing
	cjne a, #11101111B, build_4
	mov hex4, #BLANK
	anl a, hex5
	mov hex5, a
	cjne a, #L_7, set_3
	ljmp do_nothing
	
set_3:
 	mov a, #11110111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_3:	
	lcall scroll_left_to_4 
	lcall short_wait
	mov a, hex4 ;moving to accumulator for compairing
	cjne a, #11110111B, build_3
	mov hex4, #BLANK
	anl a, hex5
	mov hex5, a
	cjne a, #L_7, set_0
	ljmp do_nothing

set_0:
 	mov a, #11111110B ; load up scroll with the segment we wish to build
	mov hex0, a

build_0:	
	lcall scroll_left_to_4 
	lcall short_wait
	mov a, hex4 ;moving to accumulator for compairing
	cjne a, #11111110B, build_0
	mov hex4, #BLANK
	anl a, hex5
	mov hex5, a
	cjne a, #L_7, set_6
	ljmp do_nothing
	
set_6:
 	mov a, #10111111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_6:	
	lcall scroll_left_to_4 
	lcall short_wait
	mov a, hex4 ;moving to accumulator for compairing
	cjne a, #10111111B, build_6
	mov hex4, #BLANK
	anl a, hex5
	mov hex5, a
	cjne a, #L_7, set_1
	ljmp do_nothing
	
set_1:
 	mov a, #11111101B ; load up scroll with the segment we wish to build
	mov hex0, a

build_1:	
	lcall scroll_left_to_4 
	lcall short_wait
	mov a, hex4 ;moving to accumulator for compairing
	cjne a, #11111101B, build_1
	mov hex4, #BLANK
	anl a, hex5
	mov hex5, a
	cjne a, #L_7, set_2
	ljmp do_nothing
set_2:
 	mov a, #11111011B ; load up scroll with the segment we wish to build
	mov hex0, a

build_2:	
	lcall scroll_left_to_4 
	lcall short_wait
	mov a, hex4 ;moving to accumulator for compairing
	cjne a, #11111011B, build_2
	mov hex4, #BLANK
	anl a, hex5
	mov hex5, a
	cjne a, #L_7, set_hex4 ; should be equal
	ljmp set_hex4
	
	
do_nothing:
	ljmp do_nothing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HEX4
set_hex4:
 	;FINAL RESULT wWE ARE BUILING Is 8 WITCH IS (0100100)B
	
set_4_b:
 	mov a, #11101111B ; load up scroll with the segment we wish to build
	mov hex0, a
	lcall short_wait

build_4_b:	
	lcall scroll_left_to_3 
	lcall short_wait
	mov a, hex3 ;moving to accumulator for compairing
	cjne a, #11101111B, build_4_b
	mov hex3, #BLANK
	anl a, hex4
	mov hex4, a
	cjne a, #L_6, set_3_b
	ljmp do_nothing
	
set_3_b:
 	mov a, #11110111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_3_b:	
	lcall scroll_left_to_3 
	lcall short_wait
	mov a, hex3 ;moving to accumulator for compairing
	cjne a, #11110111B, build_3_b
	mov hex3, #BLANK
	anl a, hex4
	mov hex4, a
	cjne a, #L_6, set_0_b
	ljmp do_nothing

set_0_b:
 	mov a, #11111110B ; load up scroll with the segment we wish to build
	mov hex0, a

build_0_b:	
	lcall scroll_left_to_3
	lcall short_wait
	mov a, hex3 ;moving to accumulator for compairing
	cjne a, #11111110B, build_0_b
	mov hex3, #BLANK
	anl a, hex4
	mov hex4, a
	cjne a, #L_6, set_6_b
	ljmp do_nothing
	
set_6_b:
 	mov a, #10111111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_6_b:	
	lcall scroll_left_to_3
	lcall short_wait
	mov a, hex3 ;moving to accumulator for compairing
	cjne a, #10111111B, build_6_b
	mov hex3, #BLANK
	anl a, hex4
	mov hex4, a
	cjne a, #L_6, set_1_b
	ljmp do_nothing
	
set_1_b:
 	mov a, #11111101B ; load up scroll with the segment we wish to build
	mov hex0, a

build_1_b:	
	lcall scroll_left_to_3 
	lcall short_wait
	mov a, hex3;moving to accumulator for compairing
	cjne a, #11111101B, build_1_b
	mov hex3, #BLANK
	anl a, hex4
	mov hex4,a
	cjne a, #L_6, set_hex3 ;
	ljmp set_hex3

do_nothing_b:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;HEX 3

set_hex3:
 	;FINAL RESULT wWE ARE BUILING Is 8 WITCH IS (0000 0000)B
set_5_c:
 	mov a, #11011111B ; load up scroll with the segment we wish to build
	mov hex0, a
	lcall short_wait

build_5_c:	
	lcall scroll_left_to_2 
	lcall short_wait
	mov a, hex2 ;moving to accumulator for compairing
	cjne a, #11011111B, build_5_c
	mov hex2, #BLANK
	anl a, hex3
	mov hex3, a
	cjne a, #L_6, set_3_c ;; should not equal
	ljmp do_nothing
		
set_3_c:
 	mov a, #11110111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_3_c:	
	lcall scroll_left_to_2 
	lcall short_wait
	mov a, hex2 ;moving to accumulator for compairing
	cjne a, #11110111B, build_3_c
	mov hex2, #BLANK
	anl a, hex3
	mov hex3, a
	cjne a, #L_6, set_0_c
	ljmp do_nothing

set_0_c:
 	mov a, #11111110B ; load up scroll with the segment we wish to build
	mov hex0, a

build_0_c:	
	lcall scroll_left_to_2
	lcall short_wait
	mov a, hex2 ;moving to accumulator for compairing
	cjne a, #11111110B, build_0_c
	mov hex2, #BLANK
	anl a, hex3
	mov hex3, a
	cjne a, #L_6, set_6_c
	ljmp do_nothing
	
set_6_c:
 	mov a, #10111111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_6_c:	
	lcall scroll_left_to_2
	lcall short_wait
	mov a, hex2 ;moving to accumulator for compairing
	cjne a, #10111111B, build_6_c
	mov hex2, #BLANK
	anl a, hex3
	mov hex3, a
	cjne a, #L_6, set_1_c
	ljmp do_nothing
	
set_1_c:
 	mov a, #11111101B ; load up scroll with the segment we wish to build
	mov hex0, a

build_1_c:	
	lcall scroll_left_to_2
	lcall short_wait
	mov a, hex2 ;moving to accumulator for compairing
	cjne a, #11111101B, build_1_c
	mov hex2, #BLANK
	anl a, hex3
	mov hex3, a
	cjne a, #L_6, set_2_c
	ljmp do_nothing
set_2_c:
 	mov a, #11111011B ; load up scroll with the segment we wish to build
	mov hex0, a

build_2_c:	
	lcall scroll_left_to_2 
	lcall short_wait
	mov a, hex2 ;moving to accumulator for compairing
	cjne a, #11111011B, build_2_c
	mov hex2, #BLANK
	anl a, hex3
	mov hex3, a
	cjne a, #L_6, set_hex2; should be equal
	ljmp set_hex2
	
	
do_nothing_c:
	ljmp do_nothing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HEX2

set_hex2:
 	
 	;FINAL RESULT wWE ARE BUILING Is 8 WITCH IS (0000 0000)B
	mov r4, #11111111B ;current result on hex5
set_5_d:
 	mov a, #11011111B ; load up scroll with the segment we wish to build
	mov hex0, a
	lcall short_wait

build_5_d:	
	lcall scroll_left_to_1 
	lcall short_wait
	mov a, hex1 ;moving to accumulator for compairing
	cjne a, #11011111B, build_5_d
	mov hex1, #BLANK
	anl a, hex2
	mov hex2, a
	cjne a, #L_7, set_6_d
	ljmp do_nothing
	
set_6_d:
 	mov a, #10111111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_6_d:	
	lcall scroll_left_to_1 
	lcall short_wait
	mov a, hex1 ;moving to accumulator for compairing
	cjne a, #10111111B, build_6_d
	mov hex1, #BLANK
	anl a, hex2
	mov hex2, a
	cjne a, #L_7, set_1_d
	ljmp do_nothing
	
set_1_d:
 	mov a, #11111101B ; load up scroll with the segment we wish to build
	mov hex0, a

build_1_d:	
	lcall scroll_left_to_1
	lcall short_wait
	mov a, hex1 ;moving to accumulator for compairing
	cjne a, #11111101B, build_1_d
	mov hex1, #BLANK
	anl a, hex2
	mov hex2, a
	cjne a, #L_7, set_2_d
	ljmp do_nothing
set_2_d:
 	mov a, #11111011B ; load up scroll with the segment we wish to build
	mov hex0, a

build_2_d:	
	lcall scroll_left_to_1 
	lcall short_wait
	mov a, hex1 ;moving to accumulator for compairing
	cjne a, #11111011B, build_2_d
	mov hex1, #BLANK
	anl a, hex2
	mov hex2, a
	ljmp set_hex1

do_nothing_d:
	ljmp do_nothing
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HEX1
; Displaying 6	
set_hex1:
 	
 	;FINAL RESULT wWE ARE BUILING Is 8 WITCH IS (0000 0000)B
	mov r4, #11111111B ;current result on hex5
set_5_e:
 	mov a, #11011111B ; load up scroll with the segment we wish to build
	mov hex0, a
	lcall short_wait

build_5_e:	
	lcall short_wait
	mov a, hex0 ;moving to accumulator for compairing
	cjne a, #11011111B, build_5_e
	mov hex0, #BLANK
	anl a, hex1
	mov hex1, a
	cjne a, #L_7, set_4_e
	ljmp do_nothing
	
set_4_e:
 	mov a, #11101111B ; load up scroll with the segment we wish to build
	mov hex0, a
	lcall short_wait

build_4_e:	
	lcall short_wait
	mov a, hex0 ;moving to accumulator for compairing
	cjne a, #11101111B, build_4_e
	mov hex0, #BLANK
	anl a, hex1
	mov hex1, a
	cjne a, #L_7, set_3_e
	ljmp do_nothing
	
set_3_e:
 	mov a, #11110111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_3_e:	
	lcall short_wait
	mov a, hex0 ;moving to accumulator for compairing
	cjne a, #11110111B, build_3_e
	mov hex0, #BLANK
	anl a, hex1
	mov hex1, a
	cjne a, #L_7, set_0_e
	ljmp do_nothing

set_0_e:
 	mov a, #11111110B ; load up scroll with the segment we wish to build
	mov hex0, a

build_0_e:	 
	lcall short_wait
	mov a, hex0 ;moving to accumulator for compairing
	cjne a, #11111110B, build_0_e
	mov hex0, #BLANK
	anl a, hex1
	mov hex1, a
	cjne a, #L_7, set_6_e
	ljmp do_nothing
	
set_6_e:
 	mov a, #10111111B ; load up scroll with the segment we wish to build
	mov hex0, a

build_6_e:	
	lcall short_wait
	mov a, hex0 ;moving to accumulator for compairing
	cjne a, #10111111B, build_6_e
	mov hex0, #BLANK
	anl a, hex1
	mov hex1, a
	ljmp set_2_e
	
set_2_e:
 	mov a, #11111011B ; load up scroll with the segment we wish to build
	mov hex0, a

build_2_e:	 
	lcall short_wait
	mov a, hex0 ;moving to accumulator for compairing
	cjne a, #11111011B, build_2_e
	mov hex0, #BLANK
	anl a, hex1
	mov hex1, a
	cjne a, #L_7, set_hex0
	ljmp set_hex0

	
do_nothing_e:
	ljmp do_nothing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HEX0
; ANIMATING number 7 - wow I finally did it
set_hex0:
	
 	mov hex0, #BLANK
 	lcall short_wait
	mov hex0, #01111011B
	lcall short_wait
	mov hex0, #01111001B
	lcall short_wait
	mov hex0, #01111000B
 	lcall short_wait
 	lcall wait
 	lcall clear_screen
 	lcall wait
	ljmp loop_111 ;; go back to start
;*********
; ANIMATION SUBSROUTINE
;==============

scroll_left_to_4:	
	mov HEX4, HEX3
	mov HEX3, HEX2
	mov HEX2, HEX1
	mov HEX1, HEX0
	mov hex0, #BLANK
	ret
scroll_left_to_3:	
	mov HEX3, HEX2
	mov HEX2, HEX1
	mov HEX1, HEX0
	mov hex0, #BLANK
	ret
scroll_left_to_2:	
	mov HEX2, HEX1
	mov HEX1, HEX0
	mov hex0, #BLANK
	ret
scroll_left_to_1:	
	mov HEX1, HEX0
	mov hex0, #BLANK
	ret
end