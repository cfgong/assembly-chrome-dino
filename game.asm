; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 5
;	Crystal Gong
;
;	Advanced Features
; 	1) music
;   2) scrolling background 
;	3) multiple inflight projectiles
;   
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc

;; Has keycodes
include keys.inc
;; sounds/ music
include \masm32\include\windows.inc 
include \masm32\include\winmm.inc 
includelib \masm32\lib\winmm.lib 
;; number printing
include \masm32\include\user32.inc 
includelib \masm32\lib\user32.lib 
;; random
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
	
.DATA
;; If you need to, you can place global variables here
instruct0 BYTE "AN ASSEMBLY CHROME DINO GAME REPLICA", 0
instruct1 BYTE "Press SPACE/ UP ARROW to jump.", 0
instruct2 BYTE "Use DOWN ARROW to duck.", 0
instruct3 BYTE "Use RIGHT to pause game.", 0
instruct4 BYTE "Use LEFT to disable/ enable pterodactyls.", 0
instruct5 BYTE "Press SPACE to start the game.", 0

pausedStr BYTE "G A M E  P A U S E D", 0

endStr BYTE "G A M E  O V E R", 0
restartStr BYTE "Press SPACE to restart the game.", 0

birdStr0 BYTE "PTERODACTYLS ENABLED", 0
birdStr1 BYTE "PTERODACTYLS DISABLED", 0

fmtStr0 BYTE "%d", 0
fmtStr1 BYTE "0%d", 0
fmtStr2 BYTE "00%d", 0
fmtStr3 BYTE "000%d", 0
fmtStr4 BYTE "0000%d", 0
fmtStr0_high BYTE "HI %d", 0
fmtStr1_high BYTE "HI 0%d", 0
fmtStr2_high BYTE "HI 00%d", 0
fmtStr3_high BYTE "HI 000%d", 0
fmtStr4_high BYTE "HI 0000%d", 0
outStr BYTE 256 DUP(0)
blankStr BYTE "%d", 0

;; score keeping
paused DWORD 0	;; 1 if paused, 0 otherwise
score DWORD 0
highScore DWORD 0
;; LOCATION of OBJECT 1: dinosaur
obj1x DWORD 40
obj1y_run DWORD 300
obj1y_duck DWORD 318
obj1y_jump DWORD 300
obj1_going_down DWORD 0

obj1_mode DWORD 0	;; for animating dino: running=0, ducking=1, jumping=2 
obj1_run DWORD 0 	;; for incrementing through the 3 stages of running 
obj1_duck DWORD 0 	;; for incrementing through the 2 stages of ducking 
;; LOCATION of OBJECT 2: bird
obj2_disabled DWORD 0
obj2x DWORD 1870
obj2y_high DWORD 260
obj2y_mid DWORD 275
obj2y_low DWORD 300
obj2_mode DWORD 0	;; keeps track of which mode we are on 
obj2 DWORD 0		;; for the two stages of flying 
;; LOCATION of OBJECT 3: cactus
obj3x DWORD 890
obj3_mode DWORD 0 				;; which cactus are we ddrawing????
;;obj3y DWORD 310				;; const

;; LOCATION of OBJECT 4: cactus
obj4x DWORD 1770
obj4_mode DWORD 0 				;; which cactus are we ddrawing????	

;; moving background
cloud1x DWORD 670
cloud1y DWORD ?
cloud2x DWORD 883
cloud2y DWORD ?
cloud3x DWORD 1096
cloud3y DWORD ?

ground0x DWORD 519
ground1x DWORD 1557

screen2box DWORD 395
;; speed 
obj2_speed DWORD 28
cactus_speed DWORD 21
cloud_speed DWORD 1

;; screen 
screenNum DWORD 0
isPaused DWORD 0
isOver DWORD 0
;; sound effects
SndPath BYTE "Off Limits.wav",0
jump_sound BYTE "jump_sound.wav", 0
dead_sound BYTE "dead_sound.wav", 0
level_up_sound BYTE "level_up_sound.wav", 0
.CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; PRINTING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This prints the score
PrintHighScore PROC USES eax 
	mov eax, highScore
	push eax 
	four_zeros:
	cmp eax, 10
	jge three_zeros
	push offset fmtStr4_high 
	jmp print_score
	three_zeros:
	cmp eax, 100
	jge two_zeros
	push offset fmtStr3_high
	jmp print_score
	two_zeros:
	cmp eax, 1000
	jge one_zero
	push offset fmtStr2_high
	jmp print_score
	one_zero:
	cmp eax, 10000
	jge no_zeros
	push offset fmtStr1_high
	jmp print_score
	no_zeros:
	push offset fmtStr0_high
	print_score:
	push offset outStr 
	call wsprintf 
	add esp, 12 
	invoke DrawStr, offset outStr, 510, 5, 0
	ret 
PrintHighScore ENDP
PrintScore PROC USES eax 
	mov eax, score
	push eax 
	four_zeros:
	cmp eax, 10
	jge three_zeros
	push offset fmtStr4 
	jmp print_score
	three_zeros:
	cmp eax, 100
	jge two_zeros
	push offset fmtStr3
	jmp print_score
	two_zeros:
	cmp eax, 1000
	jge one_zero
	push offset fmtStr2
	jmp print_score
	one_zero:
	cmp eax, 10000
	jge no_zeros
	push offset fmtStr1
	jmp print_score
	no_zeros:
	push offset fmtStr0
	print_score:
	push offset outStr 
	call wsprintf 
	add esp, 12 
	invoke DrawStr, offset outStr, 582, 5, 0
	ret 
PrintScore ENDP
; This prints digits
PrintDWORD PROC USES eax d_word: DWORD, x_coord: DWORD, y_coord: DWORD, color: DWORD
	mov eax, d_word
	push eax 
	push offset blankStr
	push offset outStr
	call wsprintf 
	add esp, 12 
	invoke DrawStr, offset outStr, x_coord, y_coord, color
	ret 
PrintDWORD ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;CHECK COLLISION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; returns 0 if there is no intersect, 1 if there is a collison
CheckIntersect PROC USES ebx ecx edx oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP 
	LOCAL left1:DWORD, right1:DWORD, top1:DWORD, bottom1:DWORD, left2:DWORD, right2:DWORD, top2:DWORD, bottom2:DWORD
	;; left 	DWORD ? ;; x - bitmap.width / 2
	;; right	DWORD ? ;; x + bitmap.width / 2
	;; top 		DWORD ? ;; y - bitmap.height / 2
	;; bottom 	DWORD ? ;; y + bitmap.height / 2
	mov ebx, oneBitmap 	; store first bitmap ptr
	mov edx, twoBitmap  ; store second bitmap ptr
;;SETTING LEFT RIGHT BOUNDS FOR BITMAP 1
	mov eax, (EECS205BITMAP PTR [ebx]).dwWidth
	sar eax, 1 			;eax = width/2
	mov ecx, oneX 		;ecx = oneX
	sub ecx, eax 		;ecx = oneX - (width / 2)
	mov left1, ecx 		;leftBound = oneX - (width / 2)
	mov right1, ecx 	;rightBound = oneX - (width / 2)
	mov eax, (EECS205BITMAP PTR [ebx]).dwWidth
	add right1, eax  	;rightBound = oneX + (width / 2)
;; SETTING LEFT RIGHT BOUNDS FOR BITMAP 2
	mov eax, (EECS205BITMAP PTR [edx]).dwWidth
	sar eax, 1 			;eax = width/2
	mov ecx, twoX 		;ecx = oneX
	sub ecx, eax 		;ecx = oneX - (width / 2)
	mov left2, ecx 		;leftBound = oneX - (width / 2)
	mov right2, ecx 	;rightBound = oneX - (width / 2)
	mov eax, (EECS205BITMAP PTR [edx]).dwWidth
	add right2, eax  	;rightBound = oneX + (width / 2)
;; SETTING TOP BOTTOM BOUNDS FOR BITMAP 1
	mov eax, (EECS205BITMAP PTR [ebx]).dwHeight
	sar eax, 1 			;eax = height/2
	mov ecx, oneY 		;eax = oneY
	sub ecx, eax 		;ecx = oneY - (height / 2)
	mov top1, ecx 		;upperBound = oneY - (height / 2)
	mov bottom1, ecx 	;lowerBound = oneY - (height / 2)
	mov eax, (EECS205BITMAP PTR [ebx]).dwHeight
	add bottom1, eax  	;lowerBound = oneY + (height / 2)
;; SETTING TOP BOTTOM BOUNDS FOR BITMAP 2
	mov eax, (EECS205BITMAP PTR [edx]).dwHeight
	sar eax, 1 			;eax = height/2
	mov ecx, twoY 		;eax = twoY
	sub ecx, eax 		;ecx = twoY - (height / 2)
	mov top2, ecx 		;upperBound = twoY - (height / 2)
	mov bottom2, ecx 	;lowerBound = twoY - (height / 2)
	mov eax, (EECS205BITMAP PTR [edx]).dwHeight
	add bottom2, eax  	;lowerBound = oneY + (height / 2)

;; Check if:
; A rect's bottom edge is higher than the other rect's top edge
; or 
; A rect's right edge is further left than the other rect's left edge

	mov eax, bottom1
	mov ecx, top2 			; higher values = lower y
	cmp eax, ecx    		; If (one.bottom) < (two.top)
	jl dont_intersect 		; Then (one.bottom) is above (two.top) = no intersection

	mov eax, bottom2
	mov ecx, top1 
	cmp eax, ecx  			; If (two.bottom) < (one.top)
	jl dont_intersect 		; Then (two.bottom) is above (one.top) = no intersection
	
	mov eax, right1
	mov ecx, left2			
	cmp eax, ecx    		; If (one.right) < (two.left)
	jl dont_intersect 		; Then (one.right) is more left (two.left) = no intersection

	mov eax, right2
	mov ecx, left1 			
	cmp eax, ecx    		; If (two.right) < (one.left)
	jl dont_intersect 		; Then (two.right) is more left (one.left) = no intersection
					
intersect:
	mov eax, 1
	jmp the_end

dont_intersect:
	mov eax, 0

the_end:
	ret
CheckIntersect ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; GAME INITIALIZATION BUSINESS ;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; generating random integers in a range [lowerBound, higherBound]
randInt PROC lowerBound: DWORD, higherBound: DWORD
	;; range of [0, higherBound- lowerBound), you use ​nrandom​:
	mov eax, higherBound
	inc eax 
	sub eax, lowerBound
	INVOKE nrandom, eax
	add eax, lowerBound ;; add lowerbound
	ret
randInt ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; MAKING SCREEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
makeWhiteScreen PROC USES ebx edx
	mov ebx, 0;; zero out ebx
	mov edx, 0 ;; zero out ecx
	;; screen size is 640 by 480
	jmp x_loop_cond
inner_loop_body:    
	INVOKE DrawPixel, ebx, edx, 255 ;0dbh
	;;INVOKE DrawStar, ebx, edx
	inc edx
y_loop_cond:
	cmp edx, 480
	jl inner_loop_body
	mov edx, 0		; set y back to 0
	inc ebx			; next row
x_loop_cond:
	cmp ebx, 640
	jl y_loop_cond
the_end:
	ret
makeWhiteScreen ENDP

drawMovingGround PROC USES ebx ecx
	INVOKE BasicBlit, OFFSET ground, ground0x, 327
	INVOKE BasicBlit, OFFSET ground, ground1x, 327
	;; the ground starts at 519
	;; only move ground if game is not over
	cmp isOver, 1
	je the_end
	;; hold onto cactus speed
	mov ebx, cactus_speed
;check_ground_0:
	cmp ground0x, -519
	jge move_ground0
;reset_ground_0:
	mov ecx, ground1x
	add ecx, 1038
	sub ecx, cactus_speed
	mov ground0x, ecx 
	jmp check_ground_1
move_ground0:
	sub ground0x, ebx
check_ground_1:
	cmp ground1x, -519
	jge move_ground1
;reset_ground_0:
	mov ecx, ground0x
	add ecx, 1038
	sub ecx, cactus_speed
	mov ground1x, ecx 
	jmp the_end
move_ground1:
	sub ground1x, ebx
the_end:
	ret
drawMovingGround ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DRAW THE INSTRUCTIONS SCREEN
makeScreen0 PROC
	INVOKE DrawStr, OFFSET instruct0, 5, 5, 0
	INVOKE DrawStr, OFFSET instruct1, 5, 15, 0
	INVOKE DrawStr, OFFSET instruct2, 5, 25, 0
	INVOKE DrawStr, OFFSET instruct3, 5, 35, 0
	INVOKE DrawStr, OFFSET instruct4, 5, 45, 0
	INVOKE DrawStr, OFFSET instruct5, 5, 55, 0
	INVOKE BasicBlitDino, OFFSET dino0, obj1x, obj1y_run
	INVOKE BasicBlit, OFFSET ground, 519, 327
	INVOKE BasicBlit, OFFSET whitebox, screen2box, 327
	ret
makeScreen0 ENDP

generateBirdStartPos PROC
	INVOKE randInt, 2700, 4000
	ret
generateBirdStartPos ENDP

;; generate a start position based on a reference point
generateCactusStartPos PROC USES ebx ecx refx: DWORD
	cmp refx, 670	;; see if the reference point is off screen
	jge use_ref		;; we want the reference point to be off the screen
	mov ebx, 820
	mov ecx, 1000
	jmp generate_random
	use_ref:
	mov ebx, refx
	mov ecx, refx
	add ebx, 150
	add ecx, 300
	generate_random:
	INVOKE randInt, ebx, ecx
	ret
generateCactusStartPos ENDP

;; generate a start position based on a reference point
generateCactusStartPos2 PROC USES ebx ecx refx: DWORD
	mov ebx, refx
	mov ecx, refx
	sub ebx, 170		;; lower bound
	add ecx, 170		;; upper bound
	generate_random:
	INVOKE randInt, 670, 1710
	cmp eax, ebx ;; check lower bound
	jle the_end
	cmp eax, ecx	;; check upper bound
	jge the_end
	jmp generate_random
	the_end:
	ret
generateCactusStartPos2 ENDP

generateCloudStartPosY PROC
	INVOKE randInt, 35, 255
	ret
generateCloudStartPosY ENDP

drawClouds PROC USES ebx eax
	mov ebx, cloud_speed
	;; can also generate new height
move_cloud1:
	cmp cloud1x, -30						
	jle cloud1_moved_offscreen						;; bird is offscreen so we don't want to draw anymore
	
	sub cloud1x, ebx		
	cmp cloud1x, 670
	jge move_cloud2			;; don't draw if still moving onto screen			
	draw_cloud1:
	INVOKE BasicBlit, OFFSET cloud, cloud1x, cloud1y
	jmp move_cloud2
	cloud1_moved_offscreen:
	INVOKE generateCloudStartPosY			;; randomly generate start position
	mov cloud1y, eax
	mov cloud1x, 670 ;;reset cloud x pos	
move_cloud2:
	cmp cloud2x, -30						
	jle cloud2_moved_offscreen						;; bird is offscreen so we don't want to draw anymore
	
	sub cloud2x, ebx		
	cmp cloud2x, 670
	jge move_cloud3			;; don't draw if still moving onto screen			
	draw_cloud2:
	INVOKE BasicBlit, OFFSET cloud, cloud2x, cloud2y
	jmp move_cloud3
	cloud2_moved_offscreen:
	INVOKE generateCloudStartPosY			;; randomly generate start position
	mov cloud2y, eax
	mov cloud2x, 670 ;;reset cloud x pos	
move_cloud3:
	cmp cloud3x, -30						
	jle cloud3_moved_offscreen						;; bird is offscreen so we don't want to draw anymore
	
	sub cloud3x, ebx		
	cmp cloud3x, 670
	jge the_end		;; don't draw if still moving onto screen			
	draw_cloud3:
	INVOKE BasicBlit, OFFSET cloud, cloud3x, cloud3y
	jmp the_end
	cloud3_moved_offscreen:
	INVOKE generateCloudStartPosY			;; randomly generate start position
	mov cloud3y, eax
	mov cloud3x, 670 ;;reset cloud x pos	
the_end:
	ret
drawClouds ENDP


makeScreen2 PROC USES eax ebx
	LOCAL obj1ptr: PTR EECS205BITMAP, obj1y: DWORD
	LOCAL obj2ptr: PTR EECS205BITMAP, obj2y: DWORD
	LOCAL obj3ptr: PTR EECS205BITMAP, obj3y: DWORD
	LOCAL obj4ptr: PTR EECS205BITMAP, obj4y: DWORD

;; DRAWING THE BIRD

	cmp obj2_disabled, 1
	je obj3_0 ;;dont_make_bird
	cmp obj2, 0
	jne obj2_1
	inc obj2
	mov obj2ptr, OFFSET bird0		;; using bird0
	jmp get_obj2_height
obj2_1:
	mov obj2ptr, OFFSET bird1		;; using bird1
	dec obj2
get_obj2_height:							;; use randomly generated height
	cmp obj2_mode, 0
	jne obj2_med_mode

	mov ebx, obj2y_high
	jmp set_obj2_height
	obj2_med_mode:
	cmp obj2_mode, 1
	jne obj2_low_mode

	mov ebx, obj2y_mid
	jmp set_obj2_height
	obj2_low_mode:
	mov ebx, obj2y_low
set_obj2_height:
	mov obj2y, ebx
move_bird:
	cmp obj2x, -30						
	jle bird_moved_offscreen				;; bird has moved offscreen so we don't want to draw anymore
	
	mov ebx, obj2_speed
	sub obj2x, ebx					;; move bird across the screen
	cmp obj2x, 670
	jge obj3_0			;; don't draw if still moving onto screen
draw_bird:
	INVOKE BasicBlit, obj2ptr, obj2x, obj2y	;; drawing the object
	jmp obj3_0
bird_moved_offscreen:	
	INVOKE randInt, 0, 2
	mov obj2_mode, eax
	INVOKE generateBirdStartPos			;; randomly generate start position
	mov obj2x, eax
obj3_0:	
;; DRAWING THE CACTUS1
	cmp obj3_mode, 0
	jne obj3_cactus_1
	obj3_cactus_0:
	mov obj3ptr, OFFSET cactus0		;; using cactus0	
	mov ebx, 300
	jmp set_obj3
	obj3_cactus_1:
	cmp obj3_mode, 1
	jne obj3_cactus_2
	mov obj3ptr, OFFSET cactus1		;; using cactus1	
	mov ebx, 310
	jmp set_obj3
	obj3_cactus_2:
	mov obj3ptr, OFFSET cactus2		;; using cactus2	
	mov ebx, 310					;; add random height later
set_obj3:
	mov obj3y, ebx
obj4_0:	
;; DRAWING THE CACTUS1
	cmp obj4_mode, 0
	jne obj4_cactus_1
	obj4_cactus_0:
	mov obj4ptr, OFFSET cactus0		;; using cactus0	
	mov ebx, 300
	jmp set_obj4
	obj4_cactus_1:
	cmp obj4_mode, 1
	jne obj4_cactus_2
	mov obj4ptr, OFFSET cactus1		;; using cactus1	
	mov ebx, 310
	jmp set_obj4
	obj4_cactus_2:
	mov obj4ptr, OFFSET cactus2		;; using cactus2	
	mov ebx, 310					;; add random height later
set_obj4:
	mov obj4y, ebx
;; DRAWING THE DINO
key0:
	mov ebx, obj1y_jump
	cmp obj1y_run, ebx				;; check if running height is the same
	jne jump 						;; if not the same we are in the middle of jumping	
	cmp KeyPress, VK_SPACE					;; checking SPACE for jump
	je play_jump_sound
	cmp KeyPress, VK_UP						;; checking UP arrow
	jne key1 								;; check the next button
	play_jump_sound:
	;;invoke PlaySound, offset jump_sound, 0, SND_FILENAME OR SND_ASYNC
	;;INVOKE DrawStr, OFFSET endStr, 10, 10, 0
	jump:
	mov obj1ptr, OFFSET dino0				;; using dino 0
	cmp obj1y_jump, 180			;; max height is 175
	jne direction_check							;; go from going up to going down 
	;; otherwise we need to set the direction flag
	inc obj1_going_down
	direction_check:
	cmp obj1_going_down, 1
	jne go_up
	go_down:
	add obj1y_jump, 30			;; going down
	cmp obj1y_jump, 300
	jne set_jump_height
	dec obj1_going_down					;; set direction flag back to up
	jmp set_jump_height
	go_up:	;; y gets smaller
	sub obj1y_jump, 30			;; going up
	set_jump_height:
	mov ebx, obj1y_jump;; doing something here						;; setting jump height
	mov obj1y, ebx
	jmp move_cactus1
key1:	;; DOWN KEY
	cmp KeyPress, VK_DOWN					;; checking DOWN ARROW for duck
	jne noKey 								;; check the next button
	mov ebx, obj1y_duck					;; setting jump height
	mov obj1y, ebx

	cmp obj1_duck, 0
	jne obj1_duck_1
	inc obj1_duck
	mov obj1ptr, OFFSET dino3		;; using dino 3
	jmp move_cactus1
	obj1_duck_1:
	mov obj1ptr, OFFSET dino4		;; using dino 4
	dec obj1_duck
	jmp move_cactus1
noKey:				;; default move, no keys are being pressed
	mov ebx, obj1y_run					;; setting jump height
	mov obj1y, ebx

	cmp obj1_run, 0
	jne obj1_run_1
	mov obj1ptr, OFFSET dino0		;; using dino 0
	inc obj1_run						;; use dino 1 next
	jmp move_cactus1
	obj1_run_1:	
	cmp obj1_run, 1
	jne obj1_run_2
	mov obj1ptr, OFFSET dino1		;; using dino 1
	inc obj1_run						;; use dino 2 next
	jmp move_cactus1
	obj1_run_2:	
	mov obj1ptr, OFFSET dino2		;; using dino 2
	mov obj1_run, 0						;; use dino 0 next

move_cactus1:
	cmp obj3x, -30						
	jle cactus1_moved_offscreen						;; bird is offscreen so we don't want to draw anymore
	
	mov ebx, cactus_speed
	sub obj3x, ebx		
	cmp obj3x, 670
	jge move_cactus2			;; don't draw if still moving onto screen			
draw_cactus1:
	INVOKE BasicBlit, obj3ptr, obj3x, obj3y
	jmp move_cactus2
cactus1_moved_offscreen:
	INVOKE randInt, 0, 2
	mov obj3_mode, eax
	INVOKE generateCactusStartPos2, obj4x			;; randomly generate start position
	mov obj3x, eax	
move_cactus2:
	cmp obj4x, -30						
	jle cactus2_moved_offscreen						;; bird is offscreen so we don't want to draw anymore
	
	mov ebx, cactus_speed
	sub obj4x, ebx
	cmp obj4x, 670
	jge draw_dino			;; don't draw if still moving onto screen	
draw_cactus2:
	INVOKE BasicBlit, obj4ptr, obj4x, obj4y
	jmp draw_dino
cactus2_moved_offscreen:
	INVOKE randInt, 0, 2
	mov obj4_mode, eax
	;; randomly generate start position
	INVOKE generateCactusStartPos2, obj3x
	mov obj4x, eax	
draw_dino:
	INVOKE drawClouds	
	INVOKE BasicBlitDino, obj1ptr, obj1x, obj1y		;; drawing the object
	mov isOver, eax	
	cmp eax, 1;; see if game isover
	jne the_end
	;; redraw everything with dead dino
	INVOKE makeWhiteScreen
	cmp obj2_disabled, 1
	je continue_redraw
	INVOKE BasicBlit, obj2ptr, obj2x, obj2y
	continue_redraw:
	INVOKE BasicBlit, obj3ptr, obj3x, obj3y
	INVOKE BasicBlit, obj4ptr, obj4x, obj4y
	mov ebx, obj1y_duck	;; if the dino was ducking we want adjust the y
	cmp obj1y, ebx
	jne draw_dead_dino
	mov ebx, obj1y_run
	mov obj1y, ebx
	draw_dead_dino:
	;; DRAWING THE BACKGROUND
	INVOKE drawClouds	
	INVOKE BasicBlitDino, OFFSET dino5, obj1x, obj1y
the_end:
;; DETERMINE IF pterodactyls have been enabled or not
	cmp obj2_disabled, 1
	jne write_enabled
	mov ebx, OFFSET birdStr1
	jmp print_scoreboard
	write_enabled:
	mov ebx, OFFSET birdStr0
	print_scoreboard:
	INVOKE DrawStr, ebx, 5, 5, 0 ;; print if bird is disabled or not 
	INVOKE PrintScore
	inc score
	cmp highScore, 0
	je the_end_end
	INVOKE PrintHighScore

the_end_end:
;; distance test stuff;; DELETE LATER
	;INVOKE PrintDWORD, obj3x, 10, 20, 117
	;INVOKE PrintDWORD, obj4x, 110, 20, 100
	;mov ebx, obj3x
	;sub ebx, obj4x
	;INVOKE PrintDWORD, ebx, 210, 20, 100


	ret
makeScreen2 ENDP

	
GameInit PROC USES eax
;; background music
	INVOKE PlaySound, offset SndPath, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP
;; for random number generation:
	rdtsc
	INVOKE nseed, eax
	INVOKE makeWhiteScreen	
	INVOKE makeScreen0			;; draw instructions screen 
	;; initiation of cloud heights
	INVOKE generateCloudStartPosY
	mov cloud1y, eax
	INVOKE generateCloudStartPosY
	mov cloud2y, eax
	INVOKE generateCloudStartPosY
	mov cloud3y, eax
	ret         ;; Do not delete this line!!!
GameInit ENDP

GameRestart PROC USES eax ebx
	mov screenNum, 2
	;;INVOKE generateStartPos			;; randomly generate start position
	;;mov obj2x, eax	
	mov obj2x, 1970
	;;INVOKE generateStartPos			;; randomly generate start position
	mov obj3x, 890
	;;mov obj3x, eax		
	mov obj4x, 1300	
	;; reset cloud positions
	mov cloud1x, 670
	mov cloud2x, 883
	mov cloud3x, 1096

	dec isOver	;; set isOver back to 0
	mov ebx, score
	cmp highScore, ebx					;; new high score???
	jge clear_score
	mov highScore, ebx
	clear_score:
	mov score, 0						;; score back to 0
	ret         ;; Do not delete this line!!!
GameRestart ENDP

GamePlay PROC 
	cmp isOver, 1			;; check if game is over
	jne screen0             ;; if not over continue
	cmp KeyPress, VK_SPACE	;; if the game is over check if we are restarting

	jne screen2 			;; if we are not restarting
	INVOKE GameRestart
screen0:
	cmp screenNum, 0
	jne screen1					;; if not screen 0, check if it's the next screen
	
	cmp KeyPress, VK_SPACE		;; check if space was pressed
	jne the_end
	
	inc screenNum 				;; if space was pressed we increment to next screen
	jmp the_end					;; and go to the end
screen1:
	;; make a slidey box that shifts off the screen
	cmp screenNum, 1
	jne screen2	
	INVOKE makeWhiteScreen
	INVOKE BasicBlitDino, OFFSET dino0, obj1x, obj1y_run
	INVOKE BasicBlit, OFFSET ground, 519, 327
	INVOKE BasicBlit, OFFSET whitebox, screen2box, 327

	cmp screen2box, 950
	jge next_screen
	add screen2box, 40
	jmp the_end
	next_screen:
	inc screenNum
screen2:
	cmp isOver, 1   					;; END GAME
	je screen3

	cmp KeyPress, VK_RIGHT					;; checking DOWN ARROW for duck
	je P_check							;; see if we need to toggle pause
	cmp isPaused, 0						;; see if game is currently paused
	jne the_end
	jmp not_paused
	P_check:
	cmp isPaused, 0						;; if not paused we want to pause
	jne unpause							;; game is paused, we want to unpause
	
	inc isPaused
	INVOKE DrawStr, OFFSET pausedStr, 235, 215, 0	
	jmp the_end
	unpause:
	dec isPaused
	not_paused:
	;;; get rid of 
	cmp KeyPress, VK_LEFT
	jne continue_screen_2
	mov obj2x, 1170			; reset obj2x
	cmp obj2_disabled, 1
	jne obj2_was_enabled		; obj2_disabled = 0
	dec obj2_disabled
	jmp continue_screen_2
	obj2_was_enabled:
	inc obj2_disabled
	continue_screen_2:
	INVOKE makeWhiteScreen		;; clears the screen so we can nicely draw everything again

	cmp screenNum, 2
	jne screen3			;; if not screen 1, check if it's the next screen

	INVOKE makeScreen2			;; draw game screen 
	;;INVOKE DrawLine, 0, 325, 640, 325, 0 		;; draw the ground
	INVOKE drawMovingGround
	jmp the_end
screen3:		;; end game string
	INVOKE DrawStr, OFFSET endStr, 245, 205, 0	;;end game
	INVOKE DrawStr, OFFSET restartStr, 190, 225, 0		;; restart string
the_end:

	;INVOKE PrintDWORD, screenNum, 300, 300, 0
	;INVOKE PrintDWORD, isOver, 300, 310, 0
	;INVOKE PrintDWORD, paused, 300, 320, 0
	;INVOKE PrintDWORD, screen2box, 300, 330, 0
	;INVOKE PrintDWORD, obj2_disabled, 300, 340, 77
	ret         ;; Do not delete this line!!!
GamePlay ENDP



END
