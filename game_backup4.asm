
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DRAW THE GAME SCREEN
makeScreen22 PROC USES eax ebx
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
	INVOKE BasicBlitDino, obj1ptr, obj1x, obj1y		;; drawing the object
	mov isOver, eax	
	cmp eax, 1;; see if game is over
	jne the_end
	;; redraw everything with dead dino
	INVOKE makeWhiteScreen
	INVOKE BasicBlit, obj2ptr, obj2x, obj2y
	INVOKE BasicBlit, obj3ptr, obj3x, obj3y
	INVOKE BasicBlit, obj4ptr, obj4x, obj4y
	mov ebx, obj1y_duck	;; if the dino was ducking we want adjust the y
	cmp obj1y, ebx
	jne draw_dead_dino
	mov ebx, obj1y_run
	mov obj1y, ebx
	draw_dead_dino:
	;; DRAWING THE BACKGROUND
	INVOKE BasicBlitDino, OFFSET dino5, obj1x, obj1y
	INVOKE drawClouds	
the_end:
;; distance test stuff;; DELETE LATER
	INVOKE PrintDWORD, obj3x, 10, 20, 117
	INVOKE PrintDWORD, obj4x, 110, 20, 100
	mov ebx, obj3x
	sub ebx, obj4x
	INVOKE PrintDWORD, ebx, 210, 20, 100

;; DETERMINE IF pterodactyls have been enabled or not
jmp the_end_end 
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

	ret
makeScreen22 ENDP
