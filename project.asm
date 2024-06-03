include irvine32.inc

BUFFER_SIZE = 501

DisplayGame PROTO

.data
	     board        BYTE '0','1','2','3','4','5','6','7','8','9'
	     dash         BYTE '-', 0
	     line         BYTE '|', 0
	     prompt0      BYTE "Player O's Move: ", 0
	     prompt1      BYTE "Player X's Move: ", 0
	     win0         BYTE "Player O wins!", 0
	     win1         BYTE "Player X wins!", 0
	     comp         BYTE "Computer wins!", 0
	     drawMsg      BYTE "Game ended in a Draw!", 0
	     continueMsg  BYTE "Press Any Key To Continue......", 0
	     menu1        BYTE "-------------------TIC TAC TOE-------------------", 0
	     menu2        BYTE "What Mode Do You Want to Play?", 0dh, 0ah, 0dh, 0ah, "1. Player Vs Player", 0dh, 0ah, "2. Player Vs Computer", 0dh, 0ah, "3. Watch Computer Vs Computer :)", 0dh, 0ah, "4. Exit", 0dh, 0ah, 0dh, 0ah, "Select: ",0
	     buffer       BYTE BUFFER_SIZE DUP(?)
	     stringLength DWORD ?
	     bytesWritten DWORD ?
	     count        DWORD 0

.code
main PROC
	                   mov    ecx, -1

	menuLoop:          
	                   mov    edi, 0
	                   mov    count, 0
	                   mov    edi, offset buffer
	                   mov    edx, offset menu1
	                   call   writestring
	                   call   crlf
	                   call   crlf
	                   mov    edx, offset menu2
	                   call   writestring
	                   call   crlf
	                   call   readint
	                   cmp    eax, 1
	                   je     playervsplayer
	                   cmp    eax, 2
	                   je     playervscomputer
	                   cmp    eax, 3
	                   je     computervscomputer
	                   cmp    eax, 4
	                   je     endProgram
	                   loop   menuLoop
	
	playervsplayer:    
	                   call   PVP
	                   mov    ecx, -1
	                   jmp    menuLoop

	playervscomputer:  
	                   call   PVC
	                   mov    ecx, -1
	                   jmp    menuLoop

	computervscomputer:
	                   call   CVC
	                   mov    ecx, -1
	                   jmp    menuLoop

	endProgram:        
	                   exit
main ENDP

;------------------------------------------------------
makeMove PROC USES ecx
	                   mov    esi, offset board

	L1:                
	                   mov    cl, [esi]
	                   cmp    cl, bl
	                   je     jumping
	                   inc    esi
	                   jmp    L1

	jumping:           
	                   mov    bl, 'O'
	                   mov    [esi], bl
	                   cmp    eax, 0
	                   je     skip
	
	                   mov    bl, 'X'
	                   mov    [esi], bl

	skip:              
	                   ret
makeMove ENDP
;------------------------------------------------------


;------------------------------------------------------
initializeBoard PROC USES eax
	                   mov    esi, offset board
	                   mov    al, '0'
	                   mov    ecx, 9
	L1:                
	                   mov    [esi], al
	                   inc    al
	                   inc    esi
	                   loop   L1
			
	                   ret
initializeBoard ENDP
;------------------------------------------------------


;------------------------------------------------------
CVC PROC
	                   call   initializeBoard
	                   mov    eax, 0
	                   mov    ecx, -1
	gameLoop:          
	                   invoke DisplayGame
	                   push   eax
	                   mov    eax, 1000
	                   call   delay
	                   pop    eax
	                   call   CVCRandom
	                   call   checkWin
	                   cmp    ebx, 404
	                   je     gameOver
	                   call   checkDraw
	                   cmp    ebx, 50
	                   je     gameDraw
	                   not    eax
	                   loop   GameLoop
	
	gameOver:          
	                   invoke DisplayGame
	                   mov    edx, offset win0
	                   cmp    eax, 0
	                   je     skip
	                   mov    edx, offset win1
	                   jmp    skip

	gameDraw:          
	                   invoke DisplayGame
	                   mov    edx, offset drawMsg

	skip:              
	                   call   writestring
	                   call   crlf
	                   mov    edx, offset continueMsg
	                   call   writestring
	                   call   crlf
	                   call   crlf
	                   call   readchar
	                   ret
CVC ENDP
;------------------------------------------------------


;------------------------------------------------------
CVCRandom PROC USES ecx
	                   mov    ecx, eax
	repLoop:           
	                   mov    eax, 9
	                   call   randomrange
	                   cmp    eax, 0
	                   jl     repLoop
	                   cmp    eax, 9
	                   jg     repLoop
	                   mov    esi, offset board
	                   add    esi, eax
	                   mov    al, [esi]
	                   cmp    al, 'O'
	                   je     repLoop
	                   cmp    al, 'X'
	                   je     repLoop

	                   mov    al, 'O'
	                   mov    [esi], al

	                   cmp    ecx, 0
	                   je     proceed
	                   mov    al, 'X'
	                   mov    [esi], al              	;
	proceed:           
	                   mov    eax, ecx
	                   ret
CVCRandom ENDP
;------------------------------------------------------


;------------------------------------------------------
PVC PROC
	                   call   initializeBoard
	                   mov    eax, 0
	                   mov    ecx, -1
	gameLoop:          
	                   invoke DisplayGame
	                   call   GetMove
	                   call   checkWin
	                   cmp    ebx, 404
	                   je     gameOver
	                   call   checkDraw
	                   cmp    ebx, 50
	                   je     gameDraw
	                   not    eax
	                   call   ComputerRandom
	                   call   checkWin
	                   cmp    ebx, 404
	                   je     gameOver
	                   call   checkDraw
	                   cmp    ebx, 50
	                   je     gameDraw
	                   not    eax
	                   loop   GameLoop
	
	gameOver:          
	                   invoke DisplayGame
	                   mov    edx, offset win0
	                   cmp    eax, 0
	                   je     skip
	                   mov    edx, offset comp
	                   jmp    skip

	gameDraw:          
	                   invoke DisplayGame
	                   mov    edx, offset drawMsg

	skip:              
	                   call   writestring
	                   call   crlf
	                   mov    edx, offset continueMsg
	                   call   writestring
	                   call   crlf
	                   call   crlf
	                   call   readchar
	                   ret
PVC ENDP
;------------------------------------------------------


;------------------------------------------------------
ComputerRandom PROC USES eax
	repLoop:           
	                   mov    eax, 9
	                   call   randomrange
	                   mov    esi, offset board
	                   add    esi, eax
	                   mov    al, [esi]
	                   cmp    al, 'O'
	                   je     repLoop
	                   cmp    al, 'X'
	                   je     repLoop

	                   mov    al, 'X'
	                   mov    [esi], al              	;
	                   ret
ComputerRandom ENDP
;------------------------------------------------------


;------------------------------------------------------
PVP PROC
	                   call   initializeBoard
	                   mov    eax, 0
	                   mov    ecx, -1
	gameLoop:          
	                   invoke DisplayGame
	                   call   GetMove
	                   call   checkWin
	                   cmp    ebx, 404
	                   je     gameOver
	                   call   CheckDraw
	                   cmp    ebx, 50
	                   je     gameDraw
	                   not    eax
	                   loop   GameLoop
	
	gameOver:          
	                   mov    edx, offset win0
	                   cmp    eax, 0
	                   je     skip
	                   mov    edx, offset win1
	                   jmp    skip

	gameDraw:          
	                   mov    edx, offset drawMsg

	skip:              
	                   invoke DisplayGame
	                   call   writestring
	                   call   crlf
	                   mov    edx, offset continueMsg
	                   call   writestring
	                   call   crlf
	                   call   crlf
	                   call   readchar
	                   ret
PVP ENDP
;------------------------------------------------------


;------------------------------------------------------
checkDraw PROC USES eax edx ecx
	                   mov    esi, offset board
	
	                   mov    al, [esi+0]
	                   cmp    al, '0'
	                   je     notDraw

	                   mov    al, [esi+1]
	                   cmp    al, '1'
	                   je     notDraw

	                   mov    al, [esi+2]
	                   cmp    al, '2'
	                   je     notDraw

	                   mov    al, [esi+3]
	                   cmp    al, '3'
	                   je     notDraw

	                   mov    al, [esi+4]
	                   cmp    al, '4'
	                   je     notDraw

	                   mov    al, [esi+5]
	                   cmp    al, '5'
	                   je     notDraw

	                   mov    al, [esi+6]
	                   cmp    al, '6'
	                   je     notDraw

	                   mov    al, [esi+7]
	                   cmp    al, '7'
	                   je     notDraw

	                   mov    al, [esi+8]
	                   cmp    al, '8'
	                   je     notDraw

	                   mov    ebx, 50
	                   ret

	notDraw:           
	                   mov    ebx, 101
	                   ret
checkDraw ENDP
;------------------------------------------------------


;------------------------------------------------------
checkWin PROC USES eax edx ecx
	                   mov    esi, offset board

	                   mov    al, [esi+0]
	                   mov    cl, [esi+1]
	                   mov    dl, [esi+2]
	                   cmp    al, cl
	                   jne    con1
	                   cmp    cl, dl
	                   jne    con1
	                   mov    ebx, 404
	                   ret

	con1:              
	                   mov    al, [esi+3]
	                   mov    cl, [esi+4]
	                   mov    dl, [esi+5]
	                   cmp    al, cl
	                   jne    con2
	                   cmp    cl, dl
	                   jne    con2
	                   mov    ebx, 404
	                   ret

	con2:              
	                   mov    al, [esi+6]
	                   mov    cl, [esi+7]
	                   mov    dl, [esi+8]
	                   cmp    al, cl
	                   jne    con3
	                   cmp    cl, dl
	                   jne    con3
	                   mov    ebx, 404
	                   ret

	con3:              
	                   mov    al, [esi+0]
	                   mov    cl, [esi+3]
	                   mov    dl, [esi+6]
	                   cmp    al, cl
	                   jne    con4
	                   cmp    cl, dl
	                   jne    con4
	                   mov    ebx, 404
	                   ret

	con4:              
	                   mov    al, [esi+1]
	                   mov    cl, [esi+4]
	                   mov    dl, [esi+7]
	                   cmp    al, cl
	                   jne    con5
	                   cmp    cl, dl
	                   jne    con5
	                   mov    ebx, 404
	                   ret

	con5:              
	                   mov    al, [esi+2]
	                   mov    cl, [esi+5]
	                   mov    dl, [esi+8]
	                   cmp    al, cl
	                   jne    con6
	                   cmp    cl, dl
	                   jne    con6
	                   mov    ebx, 404
	                   ret

	con6:              
	                   mov    al, [esi+0]
	                   mov    cl, [esi+4]
	                   mov    dl, [esi+8]
	                   cmp    al, cl
	                   jne    con7
	                   cmp    cl, dl
	                   jne    con7
	                   mov    ebx, 404
	                   ret

	con7:              
	                   mov    al, [esi+2]
	                   mov    cl, [esi+4]
	                   mov    dl, [esi+6]
	                   cmp    al, cl
	                   jne    con8
	                   cmp    cl, dl
	                   jne    con8
	                   mov    ebx, 404
	                   ret

	con8:              
	                   mov    ebx, 202
	                   ret
checkWin ENDP
;------------------------------------------------------


;------------------------------------------------------
GetMove PROC USES ecx edx
	                   mov    ecx, eax
	                   mov    edx, offset prompt0
	                   cmp    eax, 0
	                   je     skip
	                   mov    edx, offset prompt1

	skip:              

	repLoop:           
	                   call   writestring
	                   call   readint
	                   cmp    eax, 0
	                   jl     repLoop
	                   cmp    eax, 9
	                   jg     repLoop
	                   mov    esi, offset board
	                   add    esi, eax
	                   mov    al, [esi]
	                   cmp    al, 'O'
	                   je     repLoop
	                   cmp    al, 'X'
	                   je     repLoop

	                   mov    al, [esi]
	                   mov    [edi], al
	                   inc    edi
	                   inc    count

	                   mov    al, 'O'
	                   mov    [esi], al

	                   cmp    ecx, 0
	                   je     proceed
	                   mov    al, 'X'
	                   mov    [esi], al              	;

	proceed:           
	
	                   mov    eax, ecx
	                   ret
GetMove ENDP
;------------------------------------------------------


;------------------------------------------------------
ColorWrite PROC

	                   cmp    al, 'X'
	                   je     colorGreen

	                   cmp    al, 'O'
	                   je     colorRed

	                   jmp    skip

	colorRed:          
	                   push   eax
	                   mov    eax, red + (black*16)
	                   call   settextcolor
	                   pop    eax
	                   jmp    skip

	colorGreen:        
	                   push   eax
	                   mov    eax, green + (black*16)
	                   call   settextcolor
	                   pop    eax
	                   jmp    skip

	skip:              
	                   call   writechar
	                   mov    eax, white + (black*16)
	                   call   settextcolor
	                   ret
ColorWrite ENDP
;------------------------------------------------------


;------------------------------------------------------
DisplayGame PROC USES eax esi edx ecx
	                   call   clrscr
	                   mov    dh, 2
	                   mov    dl, 0
	                   mov    ecx, 20
	outer1:            
	                   call   gotoxy
	                   push   edx
	                   mov    edx, offset dash
	                   call   writestring
	                   pop    edx
	                   inc    dl
	                   loop   outer1

	                   mov    dh, 4
	                   mov    dl, 0
	                   mov    ecx, 20
	outer2:            
	                   call   gotoxy
	                   push   edx
	                   mov    edx, offset dash
	                   call   writestring
	                   pop    edx
	                   inc    dl
	                   loop   outer2

	                   mov    dh, 0
	                   mov    dl, 6
	                   mov    ecx, 7
	outer3:            
	                   call   gotoxy
	                   push   edx
	                   mov    edx, offset line
	                   call   writestring
	                   pop    edx
	                   inc    dh
	                   loop   outer3

	                   mov    dh, 0
	                   mov    dl, 12
	                   mov    ecx, 7
	outer4:            
	                   call   gotoxy
	                   push   edx
	                   mov    edx, offset line
	                   call   writestring
	                   pop    edx
	                   inc    dh
	                   loop   outer4
	
	                   mov    esi, offset board
	                   mov    dl, 2
	                   mov    dh, 1
	                   call   gotoxy
	                   mov    al, [esi]
	                   call   colorWrite

	                   mov    esi, offset board
	                   mov    dl, 9
	                   mov    dh, 1
	                   call   gotoxy
	                   mov    al, [esi+1]
	                   call   colorWrite
	
	                   mov    esi, offset board
	                   mov    dl, 16
	                   mov    dh, 1
	                   call   gotoxy
	                   mov    al, [esi+2]
	                   call   colorWrite

	                   mov    esi, offset board
	                   mov    dl, 2
	                   mov    dh, 3
	                   call   gotoxy
	                   mov    al, [esi+3]
	                   call   colorWrite

	                   mov    esi, offset board
	                   mov    dl, 9
	                   mov    dh, 3
	                   call   gotoxy
	                   mov    al, [esi+4]
	                   call   colorWrite
	
	                   mov    esi, offset board
	                   mov    dl, 16
	                   mov    dh, 3
	                   call   gotoxy
	                   mov    al, [esi+5]
	                   call   colorWrite

	                   mov    esi, offset board
	                   mov    dl, 2
	                   mov    dh, 3
	                   call   gotoxy
	                   mov    al, [esi+3]
	                   call   colorWrite

	                   mov    esi, offset board
	                   mov    dl, 9
	                   mov    dh, 3
	                   call   gotoxy
	                   mov    al, [esi+4]
	                   call   colorWrite
	
	                   mov    esi, offset board
	                   mov    dl, 16
	                   mov    dh, 3
	                   call   gotoxy
	                   mov    al, [esi+5]
	                   call   colorWrite

	                   mov    esi, offset board
	                   mov    dl, 2
	                   mov    dh, 5
	                   call   gotoxy
	                   mov    al, [esi+6]
	                   call   colorWrite

	                   mov    esi, offset board
	                   mov    dl, 9
	                   mov    dh, 5
	                   call   gotoxy
	                   mov    al, [esi+7]
	                   call   colorWrite
	
	                   mov    esi, offset board
	                   mov    dl, 16
	                   mov    dh, 5
	                   call   gotoxy
	                   mov    al, [esi+8]
	                   call   colorWrite
	
	                   mov    dl, 0
	                   mov    dh, 10
	                   call   gotoxy
	                   ret
DisplayGame ENDP
;------------------------------------------------------
END main