.486
.model flat, stdcall
option casemap :none
include windows.inc
include kernel32.inc
include user32.inc
include masm32.inc
includelib kernel32.lib
includelib masm32.lib
includelib user32.lib 

;------------------------ подпрограмма factorial --------------------------
; void fact(int &number);
; number ( [ EBP + 8 ] ) - число дл€ вычислени€ факториала
; (не больше 16)
.code
fact:	
	push EBP
	mov EBP, ESP         
	
	mov EAX, 0
	mov dword ptr EBX, [ EBP + 8 ] ; <-- обращаемс€ к number через [ EBX ]
	cmp [ EBX ], EAX
	je numberIsZero
	mov EAX, 1
	cmp [ EBX ], EAX
	jbe endFactFunc
;============================= –≈ ”–—»я ===================================
	sub ESP, 8 ; <-- добавление локальных переменной
	mov dword ptr EAX, [ EBX ]
	mov dword ptr [ EBP - 4 ], EAX
	dec dword ptr [ EBX ]
	mov EAX, [ EBP - 8 ]
	mov [ EBP - 8 ], EBX
	push EBX
	call fact
	mov EBX, [ EBP - 8 ]
	mov EAX, [ EBX ]
	mov EDX, 0
	mul dword ptr [ EBP - 4 ]
	mov [ EBX ], EAX
	add ESP, 8 ; <-- удаление локальных переменной
;==========================================================================
	jmp endFactFunc
numberIsZero:
	mov dword ptr [ EBX ], 1
endFactFunc:

	pop EBP
ret 4
;--------------------------------------------------------------------------

.data
	szInputMessage db "Input number (0-16): ", 0
	numberOfBytesToRead dd 256
.data?
	inputBuffer db 256 dup(?)
	inputHandle dd ?
	outputHandle dd ?
	numberOfChars dd ?
.code
entryPoint:	
	push STD_INPUT_HANDLE  
	call GetStdHandle 
	mov inputHandle, EAX 
	
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX

	;-------------------- получение числа ---------------
	push offset szInputMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset szInputMessage 
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push numberOfBytesToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0

	; преобразование строки в дробное число
	push offset inputBuffer
	call atodw
	mov nNumber, EAX 
	;----------------------------------------------------
.data
	nNumber dd 0
	szNumber db 256 dup(0)
     	szFactorial db 256 dup(0)
.code
	push offset szNumber
	push nNumber
	call dwtoa  
        push offset nNumber      ; <--- использование рекурсивной функции
	call fact                ; <--/
	push offset szFactorial
	push nNumber
	call dwtoa	
.data
     	szTemplateAnswer db "Factorial of %s is %s", 10, 13, 0
     	szAnswer db 256 dup(0)
.code
	push offset szFactorial  ; <-- уже значение факториала
	push offset szNumber ; <-- введенное значение number
	push offset szTemplateAnswer
	push offset szAnswer
	call wsprintf
       	push offset szAnswer
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset szAnswer 
	push outputHandle
	call WriteConsole
	
	; в качестве паузы
	push NULL
	push offset numberOfChars
	push 1
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	push 0
	call ExitProcess

end entryPoint