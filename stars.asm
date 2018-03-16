; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
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

DrawStarField proc

	;; Place your stars in a diagonal line 
	;; Canvas is 640(x) 480(y) px
	INVOKE DrawStar, 10, 10
	INVOKE DrawStar, 100, 30
	INVOKE DrawStar, 250, 50
	INVOKE DrawStar, 70, 171
	INVOKE DrawStar, 90, 390
	INVOKE DrawStar, 110, 110
	INVOKE DrawStar, 134, 530
	INVOKE DrawStar, 450, 250
	INVOKE DrawStar, 172, 70
	INVOKE DrawStar, 30, 330
	INVOKE DrawStar, 210, 610
	INVOKE DrawStar, 430, 230
	INVOKE DrawStar, 250, 333
	INVOKE DrawStar, 270, 92
	INVOKE DrawStar, 290, 290
	INVOKE DrawStar, 410, 31
	INVOKE DrawStar, 330, 330
	INVOKE DrawStar, 650, 350
	INVOKE DrawStar, 370, 370
	INVOKE DrawStar, 590, 390
	INVOKE DrawStar, 410, 210
	INVOKE DrawStar, 430, 430
	INVOKE DrawStar, 650, 440
	INVOKE DrawStar, 435, 170
	INVOKE DrawStar, 635, 70

	ret  			; Careful! Don't remove this line
DrawStarField endp

END
