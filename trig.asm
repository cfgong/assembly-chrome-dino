; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;	Crystal Gong
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedSin PROC USES edx ecx ebx angle:FXPT
; ebx is the placeholder
; getting ready for dividing later
	mov edx, 0	; clear out edx, so we can get the remainder
	mov ebx, TWO_PI
;; storing angel
	mov eax, angle
	cmp eax, 0
	jge pos_angle
;; otherwise we have to make the angle positive 
	neg eax
	div ebx
	; if our angle is negative, we want angle = 2pi - newangle 
	mov ecx, TWO_PI
	sub ecx, edx
	mov edx, ecx; angle is now positive
	jmp check_angle
pos_angle:
	div ebx	; eax = angle/TWO_PI ; edx = angle % TWO_PI = newangle
check_angle:
	mov angle, edx
; there are 4 parts of the sin curve, we need to figure which part we are inc
	mov ebx, PI
	add ebx, PI_HALF ; ebx = (3/2)*PI
	cmp edx, ebx
	jge part_4	; angle: [1.5pi, 2pi)

	cmp edx, PI
	jge part_3	; angle: [pi, 1.5pi)

	cmp edx, PI_HALF
	jge part_2	; angle: [.5pi, pi)

	jmp sin_lookup	; angle: [0, .5pi)
;; sin(x) {0 < x < pi/2}
;; sin(pi-x) {pi/2 < x < pi}
;; -sin(x-pi) {pi < x < 3pi/2}
;; -sin(2pi-x) {3pi/2 <x < 2pi}
part_4: ; sin(2pi -x) 
	mov ebx, TWO_PI
	sub ebx, angle
	mov angle, ebx
	jmp neg_sin	;we need to get -sin
part_3: ;sin(x - pi)
	mov ebx, angle
	sub ebx, PI
	mov angle, ebx
	jmp neg_sin	; we need to get -sin
part_2:  ; sin(pi-x)
	mov ebx, PI
	sub ebx, angle
	mov angle, ebx
	jmp sin_lookup	
sin_lookup: ; sin(x)
	mov eax, angle	;moving for multiplication
	mov ebx, PI_INC_RECIP
	imul ebx	; eax = adj_angle * PI_INC_RECIP
	
	shl edx, 1	; double index, becuase our array is a word array and edx will return a byte array
	mov eax, 0
	mov ax, [SINTAB + edx]	; lookup
	jmp the_end
neg_sin:
	mov eax, angle	;moving for multiplication
	mov ebx, PI_INC_RECIP
	imul ebx	; eax = adj_angle * PI_INC_RECIP
	shl edx, 1

	mov ebx, 0
	mov bx, [SINTAB + edx]	; lookup
	mov eax, 0
	sub eax, ebx 	; negate
the_end:
	ret			; Don't delete this line!!!
FixedSin ENDP 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
FixedCos PROC angle:FXPT
	mov eax, angle
	add eax, PI_HALF	; cos(x) = sin(pi/2 + x) 
	INVOKE FixedSin, eax 
	
	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
