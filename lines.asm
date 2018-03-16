; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;   Crystal Gong
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC USES eax edx ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD

	LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, curr_x:DWORD, curr_y:DWORD, error:DWORD, prev_error:DWORD, two:DWORD

	;; eax, ebx, ecx, edx, esi, edi, ebp, esp
	;; esp, ebp special 
	;; we are using: eax, edx, ecx (for -delta_x), ebx as placeholder
	;; mov <reg>,<reg>
	;; mov <reg>,<mem>
	;; mov <mem>,<reg>
	;; mov <reg>,<const>
	;; mov <mem>,<const>

	;; cmp <reg>,<reg>
	;; cmp <reg>,<mem>
	;; cmp <mem>,<reg>
	;; cmp <reg>,<con>

	mov ebx, x1	;; MOVE TO VAR VALUE TO REGISTER FIRST
	sub ebx, x0 	;; ebx = x1-x0
	mov delta_x, ebx	;; delta_x = x1-x0
	cmp delta_x, 0
	jge pos_x 	;; if it's already positive, we want to jump away

	neg delta_x	;; if it's negative, we want to make it positive
pos_x:
	mov ebx, y1	;; MOVE TO VAR VALUE TO REGISTER FIRST
	sub ebx, y0 	;; ebx = y1-y0
	mov delta_y, ebx	;; delta_y = y1-y0
	cmp delta_y, 0
	jge pos_y 	;; if it's already positive, we want to jump away

	neg delta_y
pos_y: 			;; first if-statement: if (x0 < x1)  inc_x = 1
	mov ebx, x1	;; MOVE TO VAR VALUE TO REGISTER FIRST
	cmp x0, ebx
	jge else_1 	;; if (x0 < x1) was false, so we go to else

	mov inc_x, 1 	;; inc_x = 1
	jmp away_1	;; we don't want to do the else
else_1:			;; else inc_x = -1
	mov inc_x, -1	;; else inc_x = -1 

away_1:			;; second if-statement: if (y0 < y1)  inc_y = 1
	mov ebx, y1	;; MOVE TO VAR VALUE TO REGISTER FIRST
	cmp y0, ebx
	jge else_2 	;; if (y0 < y1) was false, so we go to else

	mov inc_y, 1 	;; inc_x = 1
	jmp away_2	;; we don't want to do the else
else_2:			;; else inc_y = -1
	mov inc_y, -1	;; else inc_y = -1 
away_2:			;; third if statement: if (delta_x > delta_y) error = delta_x / 2 
	mov two, 2 	;; two = 2, we will use this later for dividing
	mov edx, 0 	;; zero out edx 
	mov ebx, delta_y	;; MOVE TO VAR VALUE TO REGISTER FIRST
	cmp delta_x, ebx
	jle else_3	;; if (delta_x > delta_y) was false, so we go to else

	mov eax, delta_x 	;; eax = delta_x		
	idiv two	;; eax <- {edx, eax}/ src32, so eax has the quotient 
	mov error, eax	;; error = delta_x / 2 
	jmp away_3
else_3:
	mov eax, delta_y 	;; eax = delta_y
	idiv two	;; eax <- {edx, eax}/ src32, so eax has the quotient 
	neg eax 	;; eax = - delta_y /2
	mov error, eax	;; error = - delta_y / 2 
away_3:
	mov ebx, x0	;; MOVE TO VAR VALUE TO REGISTER FIRST
	mov curr_x, ebx
	mov ebx, y0	;; MOVE TO VAR VALUE TO REGISTER FIRST
	mov curr_y, ebx
	invoke DrawPixel, curr_x, curr_y, color
	jmp loop_eval
do_it:
  	invoke DrawPixel, curr_x, curr_y, color
  	mov eax, error		;; MOVE TO VAR VALUE TO REGISTER FIRST
  	mov prev_error, eax
  	mov ebx, delta_x	;; move delta_x into ebx so we can negate it
  	neg ebx
  	cmp prev_error, ebx
  	jle away_4

	mov ebx, delta_y	;; MOVE TO VAR VALUE TO REGISTER FIRST
	sub error, ebx	;; if condition true: error = error + delta_x 
	mov ebx, inc_x	;; MOVE TO VAR VALUE TO REGISTER FIRST
	add curr_x, ebx	;; if condition true: curr_x = curr_x + inc_x 
away_4:
	mov ebx, delta_y	;; MOVE TO VAR VALUE TO REGISTER FIRST
  	cmp prev_error, ebx	;; second if statment
  	jge loop_eval	;; if (prev_error < delta_y) was false, we return to evaluation stage

  	mov ebx, delta_x	;; MOVE TO VAR VALUE TO REGISTER FIRST
	add error, ebx 	;; if condition true: error = error + delta_x 
	mov ebx, inc_y	;; MOVE TO VAR VALUE TO REGISTER FIRST
	add curr_y, ebx	;; if condition true: curr_y = curr_y + inc_y 
loop_eval:		;; evaluate for while loop 
  	mov ebx, x1
  	cmp curr_x, ebx
  	jne do_it
  	mov ebx, y1
  	cmp curr_y, ebx
  	jne do_it

	ret        	;;  Don't delete this line...you need it

DrawLine ENDP

END
