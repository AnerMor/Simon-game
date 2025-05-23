IDEAL
MODEL small
STACK 100h
p186
DATASEG
;--------------
 openScreen db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'     WELCOME TO THE SIMON GAME!'  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'        PRESS ANY KEY TO START '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                               '  ,10,13
			db'                made by Aner Mor   '  ,10,13
			db'                               '  ,10,13,'$'
			
			
     instructions db'                                                   '  ,10,13
					db'  HOW TO PLAY                                   '  ,10,13
					db'                                                 '  ,10,13
					db'                                                 '  ,10,13
					db'   IN EACH LEVEL A SEQUENCE OF COLORS          '  ,10,13
					db'   ANS SOUNDS WILL BE SHOWN                    '  ,10,13 
					db'                                                '  ,10,13
					db'   YOU WILL NEED TO REPEAT THE SEQUENCE     '  ,10,13
					db'   IN THE CORRECT ORDER                          '  ,10,13
					db'                                                 '  ,10,13
					db'     GOOD LUCK!                                   '  ,10,13, '$'

 
  message1 db 'press any key to start$'
  
  menu db'                                    '  ,10,13
	   db'                                    '   ,10,13
	   db'                                    '   ,10,13
	   db'                                    '  ,10,13
	   db'                                    '   ,10,13
	   db'                                    '   ,10,13
	   db '                           1 - BLUE'  ,10,13
	   db'                                    '   ,10,13
	   db '                           2 - GREEN'  ,10,13
	   db'                                    '   ,10,13
	   db '                           3 - YELLOW' ,10,13
	   db'                                    '   ,10,13
	   db '                           4 - RED '    ,10,13,'$'
	   
  
  
	x_coord dw 5 ; place in line
	y_coord dw 5 ; place in column
	color dw 1
	
	x_begin dw 50   ; Starting point on line
	y_begin dw 50    ; Starting point on column
	x_count db 50 ; loop count line draw
	Y_count db 50 ; loop count column draw
	
	difColor db 1
	prevColor dw 1
	
	sequence db 15 dup (?)
	
	level dw 1
	
	lost db '                        ' ,10,13
		 db '                        ' ,10,13
		 db '       YOU LOST THE GAME!' ,10, 13, '$'
	
	
	win db '   YOU WON THE GAME!$'
	
	msg1 db '1$'
	
	msg2 db 'SCORE:$'
	
	returnAdress dw ?
	;temp dw ?
	temp_note dw ?
	note dw 11EDh,0FE8h,0E2Bh,0D5Bh,0BE4h,0A98h,96Fh,8E5h ; 1193180 / SomeNumber -> (hex)
	
	
;--------------
CODESEG
;--------------

proc delay
	push cx
	push dx
	push ax
	
	mov cx, 03h ;High Word
	mov dx, 0d40h ;Low Word
	mov al, 0
	mov ah, 86h ;Wait
	int 15h
	
	pop ax
	pop dx
	pop cx
	
	ret
	endp delay


proc drawPixel
	pusha
	xor bh, bh
	mov cx, [x_coord] ; place in line
	mov dx, [y_coord] ; place in column
	mov ax, [color]
	mov ah, 0ch
	int 10h
	popa
	ret
	endp drawPixel
	
proc changeColor
	push ax
	
	cmp [difColor], 0
	je changeSquare0
	
	cmp [difColor], 1
	je changeSquare1
	
	cmp [difColor], 2
	je changeSquare2
	
	cmp [difColor], 3
	je changeSquare3
	
	changeSquare0:
	mov [x_begin], 50
	mov [y_begin], 50
	mov [color] , 11
	mov [prevColor], 1
	push [note]
	call openSpeaker
	jmp changeColorDraw
	
	changeSquare1:
	mov [x_begin], 100
	mov [y_begin], 50
	mov [color] , 10
	mov [prevColor], 2
	push [note+2]
	call openSpeaker
	jmp changeColorDraw
	
	changeSquare2:
	mov [x_begin], 50
	mov [y_begin], 100
	mov [color] , 14
	mov [prevColor], 43
	push [note+4]
	call openSpeaker
	jmp changeColorDraw
	
	changeSquare3:
	mov [x_begin], 100
	mov [y_begin], 100
	mov [color] , 12
	mov [prevColor], 4
	push [note+6]
	call openSpeaker
	jmp changeColorDraw
	
	changeColorDraw:
	call DrawRectangle
	
	call closeSpeaker

	call delay
	
	mov ax, [prevColor]
	mov [color], ax
	 
	 
	call DrawRectangle
	
	pop ax
	ret
	endp changeColor	
		
	
	
Proc DrawRectangle
	; Draw square at x_begin, y_begin position, size 25*35
	mov [x_count],50 ; Square width
	mov [Y_count],50 ; Square height
	mov ax,[x_begin] ; Save begin point on X
	mov [x_coord],ax
	mov ax,[y_begin] ; Save begin point on Y
	mov [y_coord],ax

line_loop:
	; Print one dot on screen
	call drawPixel
	inc [x_coord]
	dec [x_count]
	cmp [x_count], 0
	jnz line_loop
	
	mov ax,[x_begin] ; Reset line counters
	mov [x_coord], ax
	mov [x_count],50 ; Reset column counters
	inc [y_coord]
	dec [y_count]
	cmp [y_count], 0
	jnz line_loop
	ret
	endp DrawRectangle
	
proc getNext
	;mov al, 3       ; return only 2 for test
	;ret             
	mov ah, 00h
	int 1ah
	
	and dl, 11b
	mov al, dl
	
	ret
	endp getNext
	
proc checkClickSquare 
	;wait for character
	mov ah, 0h
    int 16h
	
	cmp al, '1'
	je changeBlue
	
	cmp al, '2'
	je changeGreen
	
	cmp al, '3'
	je changeYellow
	
	cmp al, '4'
	je changeRed
	
	call endGame
	
	changeBlue:
	mov [difColor], 0
	jmp callChangeColor
	
	changeGreen:
	mov [difColor], 1
	jmp callChangeColor
	
	changeYellow:
	mov [difColor], 2
	jmp callChangeColor
	
	changeRed:
	mov [difColor], 3
	jmp callChangeColor
	
	callChangeColor:
	call changeColor
	ret
	endp checkClickSquare
	

proc gameLevel
	push bx
	push ax
	
	;mov cx, [level]
	mov si, 0
	levelsLoop:
		call checkClickSquare
		mov bx, offset sequence
		mov al, [byte ptr bx + si]
		cmp al, [difColor]
		je matchColors
		call endGame
				
		matchColors:
		inc si
		cmp si, [level]
		jne levelsLoop
		
	pop ax
	pop bx
	ret
	endp gameLevel
	
proc endGame
	
	call loseSound
	
	;mov ax, 2h
	;int 10h	
	mov dx, offset lost
	mov ah, 9h
	int 21h
	
	mov ah, 0h
    int 16h
	
	; text mode   80* 25
	;mov ax, 2h
	;int 10h
	
	jmp exit
	ret
	endp endGame
	
proc playGame
	
	mainGameLoop:
		call printScore
		call getNext
		mov si, [level]
		dec si
		mov bx, offset sequence
		mov [byte ptr bx + si], al
		call displaySequence
		call gameLevel
		call delay
		
		inc [level]
		cmp [level], 12 ; number of levels to win
		jb mainGameLoop
		
	ret
	endp playGame
	
proc displaySequence
	mov si, 0
	mov bx, offset sequence
	
	displayLoop:
		mov al, [byte ptr bx + si] 
		mov [difColor], al
		call changeColor
		
		inc si
		cmp si, [level] 
		jb displayLoop
		
	ret
	endp displaySequence
	
proc printScore 
	push dx
	push ax
	push bx
	
	mov bx, [level]  
	cmp bl, 9
	jbe printToConsole
	
	sub bl, 10
	
	mov dh, 2 ; row
	mov dl, 1 ; column
	mov bh, 0 ; page number
	mov ah, 2
	int 10h
	
	mov dx, offset msg1
	mov ah, 9h
	int 21h
	
	printToConsole:
	mov dl, 8
	mov ah, 2
	int 21h
	
	mov dh, 2; row
	mov dl, 2 ; column
	mov bh, 0 ; page number
	mov ah, 2
	int 10h
	
	add bl, '0'
	mov dl, bl
	mov ah, 2
	int 21h
	
	pop bx
	pop ax
	pop dx
	ret
	endp printScore
	
proc closeSpeaker
; close the speaker
	push ax
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop ax
	ret
	endp closeSpeaker
	
proc openSpeaker
; open speaker
	pop [returnAdress]
	pop [temp_note]
	push ax
	in al, 61h
	or al, 00000011b
	out 61h, al
	
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	
	; play frequency 131Hz
	mov ax, [temp_note]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	pop ax
	push [returnAdress]
	
	call delay
	
	ret
	endp openSpeaker

proc winJingle
	push[note]
	call openSpeaker
	call closeSpeaker
	
	
	push[note+2]
	call openSpeaker
	call closeSpeaker
	
	push[note+4]
	call openSpeaker
	call closeSpeaker
	
	push[note+6]
	call openSpeaker
	call closeSpeaker
	
	push[note+8]
	call openSpeaker
	call closeSpeaker
	
	ret
	endp winJingle
	
proc loseSound
	push[note+3]
	call openSpeaker
	call closeSpeaker
	
	push[note+3]
	call openSpeaker
	call closeSpeaker
	
	ret
	endp loseSound
;--------------
start:
	mov ax, @data
	mov ds, ax
	
	mov ax, 13h
	int 10h
	
	
	mov dx, offset openScreen
	mov ah, 9h
	int 21h
	
	;wait for character
	mov ah, 0h
    int 16h
	
	mov ax, 13h
	int 10h
	
	mov dx, offset instructions
	mov ah, 9h
	int 21h
	
	;wait for character
	mov ah, 0h
    int 16h

	mov ax, 13h ; graphic mode
	int 10h
	
	mov dx, offset menu
	mov ah, 9h
	int 21h
	
	;call drawPixel
	call DrawRectangle
	
	mov [y_begin],100 
	mov [color], 43 
	call DrawRectangle
	
	mov [x_begin], 100
	mov [color], 4
	call DrawRectangle
	
	mov [y_begin], 50
	mov [color], 2
	call DrawRectangle
	
	mov ah, 0h
    int 16h
	
	call delay
	call playGame
	
	mov dx, offset win
	mov ah, 9h
	int 21h
	
	call winJingle
	
exit:
	mov ax, 4c00h
	int 21h
END start