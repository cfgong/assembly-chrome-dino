; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;
;	Crystal Gong
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawDinoPixel PROC USES ebx ecx x:DWORD, y:DWORD, color:DWORD
;; screen is 640 (x) by 480 (y)
	cmp x, 0 	; 0<= x<=639
	jl the_end
	cmp x, 639
	jg the_end

	cmp y, 0 	; 0<=y<=479
	jl the_end
	cmp y, 479
	jg the_end
;; pixel at  ((y * dwWidth) + x)
	mov eax, 640	; eax = dwWidth
	imul eax, y 	; eax = eax*y
	add eax, x 	; eax = y*dwWidth + x 
;; the first pixel of the first row is at (0,0) at the address held in ScreenBitsPtr, 
;; the next pixel of the first row (1,0) is at the next byte address and subsequent pixels in that row are at increasing addresses.
;; after (639, 0) the next byte contains the pixel color for (0,1)
	add eax, ScreenBitsPtr		;; eax = ScreenBitsPtr + eax
	mov ebx, color 				;; ebx = color
	;;;checking
	mov ecx, 0 
	mov cl, BYTE PTR[eax]		;; ecx now has the old color

	;;checking ;;;
	mov BYTE PTR[eax], bl 		;; color the byte
the_end:
	;; return the old color of the pixel 
	mov eax, ecx 
	ret 			; Don't delete this line!!!
DrawDinoPixel ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; a more advanced collison detector;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; returns if game is over
BasicBlitDino PROC USES ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
; ptrBitmap holds the address of a EECS205BITMAP
; draw it so that the center of the bitmap appears at (xcenter, ycenter)
; use nested loops with DrawPixel
	LOCAL dw_width: DWORD, l_bound: DWORD, r_bound: DWORD, t_bound: DWORD, b_bound: DWORD 
	LOCAL outer_loops: DWORD, inner_loops: DWORD, outer_counter: DWORD, inner_counter: DWORD, t_color: BYTE
	LOCAL isOver: DWORD
	mov isOver, 0;; setting isOver to 0
;; edx is placeholder register
;; ebx holds ptrBitmap
	mov ebx, ptrBitmap	; ebx = ptrBitmap
	mov edx, (EECS205BITMAP PTR [ebx]).dwWidth ; edx = dwWidth
	mov dw_width, edx 	; dw_width = dwWidth
;; setting width bounds 
	mov ecx, edx 	; ecx = dwWidth
	shr ecx, 1 	; ecx = dwWidth/2
	mov edx, xcenter
	mov l_bound, edx 	;l_bound = xcenter
	sub l_bound, ecx 	;l_bound = xcenter - dwWidth/2
	mov r_bound, edx 	;r_bound = xcenter
	add r_bound, ecx 	;r_bound = xcenter + dwWidth/2
;; setting height bounds 
	mov ecx, (EECS205BITMAP PTR [ebx]).dwHeight
	shr ecx, 1 			;ecx = dwHeight/2
	mov edx, ycenter 	
	mov t_bound, edx 	;t_bound = ycenter
	sub t_bound, ecx 	;t_bound = ycenter - dwHeight/2
	mov b_bound, edx 	;b_bound = ycenter
	add b_bound, ecx 	;b_bound = ycenter + dwHeight/2

;; loops
	mov outer_loops, 0	; outer_loops = 0
	mov edx, t_bound 
	mov outer_counter, edx ; outer_counter = t_bound
	jmp outer_eval

outer_loop:
	mov inner_loops, 0 ; inner_loops = 0
	mov edx, l_bound
	mov inner_counter, edx ; inner_counter = l_bound
	jmp inner_eval

inner_loop:
	mov eax, outer_loops
	mul dw_width 	;eax = outer_loops * dw_width
	add eax, inner_loops	; eax = outer_loops * dw_width + inner_loops

	mov cl, (EECS205BITMAP PTR [ebx]).bTransparent 
	mov t_color, cl 	; color = bTransparent
	mov edi, (EECS205BITMAP PTR [ebx]).lpBytes
	mov cl, (BYTE PTR [edi + eax])	;color at the current position
	cmp t_color, cl
	je dont_draw
	
	INVOKE DrawDinoPixel, inner_counter, outer_counter, ecx
	;; returns old color 
	cmp eax, 0; compare old color to white 
	;; if they are equal there is a collision 
	jne dont_draw
	mov isOver, 1
dont_draw:
	inc inner_counter			
	inc inner_loops
inner_eval:
	mov edx, r_bound
	cmp inner_counter, edx
	jl inner_loop 	; if (inner_counter<r_bound) jump

	inc outer_counter 	; outer_counter++
	inc outer_loops		; outer_loops++
outer_eval:
	mov edx, b_bound
	cmp outer_counter, edx
	jl outer_loop	; if (outer_counter<b_bound) outer_loop

	mov eax, isOver 	;; return eax
	ret 			; Don't delete this line!!!	
BasicBlitDino ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawPixel PROC USES eax ebx x:DWORD, y:DWORD, color:DWORD
;; screen is 640 (x) by 480 (y)
	cmp x, 0 	; 0<= x<=639
	jl the_end
	cmp x, 639
	jg the_end

	cmp y, 0 	; 0<=y<=479
	jl the_end
	cmp y, 479
	jg the_end
;; pixel at  ((y * dwWidth) + x)
	mov eax, 640	; eax = dwWidth
	imul eax, y 	; eax = eax*y
	add eax, x 	; eax = y*dwWidth + x 
;; the first pixel of the first row is at (0,0) at the address held in ScreenBitsPtr, 
;; the next pixel of the first row (1,0) is at the next byte address and subsequent pixels in that row are at increasing addresses.
;; after (639, 0) the next byte contains the pixel color for (0,1)
	add eax, ScreenBitsPtr
	mov ebx, color
	mov BYTE PTR[eax], bl ;; color the byte
the_end:
	ret 			; Don't delete this line!!!
DrawPixel ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BasicBlit PROC USES eax ebx ecx edx edi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
; ptrBitmap holds the address of a EECS205BITMAP
; draw it so that the center of the bitmap appears at (xcenter, ycenter)
; use nested loops with DrawPixel

	LOCAL dw_width: DWORD, l_bound: DWORD, r_bound: DWORD, t_bound: DWORD, b_bound: DWORD 
	LOCAL outer_loops: DWORD, inner_loops: DWORD, outer_counter: DWORD, inner_counter: DWORD, t_color: BYTE
;; edx is placeholder register
;; ebx holds ptrBitmap
	mov ebx, ptrBitmap	; ebx = ptrBitmap
	mov edx, (EECS205BITMAP PTR [ebx]).dwWidth ; edx = dwWidth
	mov dw_width, edx 	; dw_width = dwWidth
;; setting width bounds 
	mov ecx, edx 	; ecx = dwWidth
	shr ecx, 1 	; ecx = dwWidth/2
	mov edx, xcenter
	mov l_bound, edx 	;l_bound = xcenter
	sub l_bound, ecx 	;l_bound = xcenter - dwWidth/2
	mov r_bound, edx 	;r_bound = xcenter
	add r_bound, ecx 	;r_bound = xcenter + dwWidth/2
;; setting height bounds 
	mov ecx, (EECS205BITMAP PTR [ebx]).dwHeight
	shr ecx, 1 			;ecx = dwHeight/2
	mov edx, ycenter 	
	mov t_bound, edx 	;t_bound = ycenter
	sub t_bound, ecx 	;t_bound = ycenter - dwHeight/2
	mov b_bound, edx 	;b_bound = ycenter
	add b_bound, ecx 	;b_bound = ycenter + dwHeight/2

;; loops
	mov outer_loops, 0	; outer_loops = 0
	mov edx, t_bound 
	mov outer_counter, edx ; outer_counter = t_bound
	jmp outer_eval

outer_loop:
	mov inner_loops, 0 ; inner_loops = 0
	mov edx, l_bound
	mov inner_counter, edx ; inner_counter = l_bound
	jmp inner_eval

inner_loop:
	mov eax, outer_loops
	mul dw_width 	;eax = outer_loops * dw_width
	add eax, inner_loops	; eax = outer_loops * dw_width + inner_loops

	mov cl, (EECS205BITMAP PTR [ebx]).bTransparent 
	mov t_color, cl 	; color = bTransparent
	mov edi, (EECS205BITMAP PTR [ebx]).lpBytes
	mov cl, (BYTE PTR [edi + eax])	;color at the current position
	cmp t_color, cl
	je dont_draw
	
	INVOKE DrawPixel, inner_counter, outer_counter, ecx

dont_draw:
	inc inner_counter			
	inc inner_loops
inner_eval:
	mov edx, r_bound
	cmp inner_counter, edx
	jl inner_loop 	; if (inner_counter<r_bound) jump

	inc outer_counter 	; outer_counter++
	inc outer_loops		; outer_loops++
outer_eval:
	mov edx, b_bound
	cmp outer_counter, edx
	jl outer_loop	; if (outer_counter<b_bound) outer_loop

	ret 			; Don't delete this line!!!	
BasicBlit ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RotateBlit PROC USES eax edx ebx esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	LOCAL cosa:FXPT, sina: FXPT
	LOCAL t_color: BYTE, lp_bytes: DWORD, width_: DWORD, height_: DWORD, shiftX: DWORD, shiftY: DWORD
	LOCAL dstWidth: DWORD, dstHeight: DWORD, dstX: DWORD, dstY: DWORD
	LOCAL srcX: DWORD, srcY: DWORD, x_bit: DWORD, y_bit: DWORD
; set cosa and sina
	INVOKE FixedCos, angle
	mov cosa, eax	; cosa = FixedCos(angle)
	INVOKE FixedSin, angle
	mov sina, eax	; sina = FixedSin(angle)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;Special draw 
	INVOKE FixedCos, 0
	cmp cosa, eax
	jne continue

	INVOKE FixedSin, 0
	cmp sina, eax
	jne continue
	INVOKE BasicBlit, lpBmp, xcenter, ycenter
	jmp the_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
continue:	
;; store color bitmap info
	mov esi, lpBmp	; get pointer to bitmap
	mov al, (EECS205BITMAP PTR[esi]).bTransparent
	mov t_color, al 		; set t_color
	mov eax, (EECS205BITMAP PTR[esi]).lpBytes
	mov lp_bytes, eax 		; set pointer to colors
	mov eax, (EECS205BITMAP PTR[esi]).dwWidth
	mov width_, eax 			; set width
	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
	mov height_, eax 		; set height
; shiftX = (EECS205BITMAP PTR [esi]).dwWidth * cosa / 2 ​  
; 			-  (EECS205BITMAP PTR [esi]).dwHeight * sina / 2  
; shiftY = (EECS205BITMAP PTR [esi]).dwHeight * cosa / 2 
; 			+  (EECS205BITMAP PTR [esi]).dwWidth * sina / 2  
	mov eax, width_
	sal eax, 16	; convert to FXPT
	mov ebx, cosa
	sar ebx, 1	; ebx = cosa/2
	imul ebx	; eax = width * cos(a)/2
	mov shiftX, edx ; keeping the integer part

	mov eax, height_
	sal eax, 16	; convert to FXPT
	imul ebx	; eax = height * cos(a)/2
	mov shiftY, edx ; keeping the integer part

	mov eax, height_
	sal eax, 16 			; convert to FXPT
	mov ebx, sina			
	sar ebx, 1 				; ebx = sina /2
	imul ebx 				
	sub shiftX, edx 		; shiftX = width*cosa - height*sina

	mov eax, width_
	sal eax, 16 			; convert to FXPT
	imul ebx 			
	add shiftY, edx 		; shiftY = height*cosa + width*sina
; set dstHeight and dsWidth
	mov eax, width_
	add eax, height_
	mov dstWidth, eax	; dstWidth = width + height
	mov dstHeight, eax	; dstHeight = width + height
; loops
	; outer loop init: for(dstX = -​dstWidth; 
	neg eax
	mov dstX, eax	; dstX = -dstWidth
	jmp outer_eval
inner_init: 
	; inner loop init: for(dstY = -​dstHeight; dstY < dstHeight; dstY++) 
	mov eax, dstHeight
	neg eax		; eax = -dstHeight
	mov dstY, eax
	jmp inner_eval
inner_loop:
; srcX = dstX*cosa + dstY*sina 
	mov eax, dstX
	sal eax, 16 	; convert to FXPT
	imul cosa 	; {edx, eax} = cosa*dstX
	mov srcX, edx	; get the integer part only, srcX = dstX*cosa

	mov eax, dstY
	sal eax, 16 	; covert to FXPT
	imul sina	; {edx, eax} = sina*dstY
	add srcX, edx 	; add the integer part only to srcX
; srcY = dstY*cosa – dstX*sina 
	mov eax, dstY
	sal eax, 16 	; convert to FXPT
	imul cosa 	; {edx, eax} = cosa*dstY
	mov srcY, edx	; get the integer part only, srcY = dstX*cosa

	mov eax, dstX
	sal eax, 16 	; covert to FXPT
	imul sina	; {edx, eax} = sina*dstY
	sub srcY, edx 	; add the integer part only to srcX
; all the inner loop if statement conditions
	cmp srcX, 0 ; srcX >= 0
	jl inner_incr

	mov ebx, width_ ; srcX < (EECS205BITMAP PTR [esi]).dwWidth
	cmp srcX, ebx
	jge inner_incr
	
	cmp srcY, 0	; srcY >= 0
	jl inner_incr
	
	mov ebx, height_ ; srcY < (EECS205BITMAP PTR [esi]).dwHeight
	cmp srcY, ebx
	jge inner_incr

	mov ebx, xcenter ; (xcenter+dstX-​shiftX) >= 0 
	add ebx, dstX
	sub ebx, shiftX
	mov x_bit, ebx	; x_bit = xcenter+dstX-​shiftX
	cmp ebx, 0
	jl inner_incr

	cmp ebx, 639 	; (xcenter+dstX​-shiftX) < 639
	jge inner_incr

	mov ebx, ycenter ; (ycenter+dstY​-shiftY) >= 0
	add ebx, dstY
	sub ebx, shiftY
	mov y_bit, ebx	; y_bit = ycenter+dstY​-shiftY
	cmp ebx, 0
	jl inner_incr

	cmp ebx, 479	; (ycenter+dstY​-shiftY) < 479 
	jge inner_incr

	; bitmap pixel (srcX,srcY) is not transparent 
	; posn = srcY*width + srcX
	mov eax, srcY
	mov ebx, width_ 
	imul ebx
	add eax, srcX
	; get the color
	add eax, lp_bytes
	mov al, (BYTE PTR [eax])
	and eax, 0ffh	; last byte
	; check for transparency
	mov dh, t_color
	cmp al, dh
	je inner_incr

	INVOKE DrawPixel, x_bit, y_bit, eax	; finally draw the pixel 
inner_incr: ; the inner loop increment, where we go if we don't draw
	inc dstY
inner_eval: ; dstY < dstHeight
	mov ebx, dstHeight
	cmp dstY, ebx
	jl inner_loop

	inc dstX	; outer loop increment
outer_eval:	; dstX < dstWidth
	mov ebx, dstWidth
	cmp dstX, ebx
	jl inner_init
the_end:

	ret 			; Don't delete this line!!!		
RotateBlit ENDP



END
