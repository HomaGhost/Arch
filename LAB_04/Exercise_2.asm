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

; ВАЖНО:
;     ПРОГРАММА СЧИТАЕТ СУММУ НЕАДЕКВАТНО, ЕСЛИ ВВЕСТИ N БОЛЬШЕ 45
;

.data
	messageString db "input N: ", 0
	messageResultTemplate db "sum of elements of sequence: %d", 10, 13, 0
	messageResult db 256 dup(0) 
	numberOfCharsToRead dd 256
	inputBuffer db 0
        N dd 0
        result dd 0
.data?
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
	
       	;================ получение N ===============
       	push offset messageString
       	call lstrlen
       	push NULL
       	push offset numberOfChars
       	push EAX
       	push offset messageString
       	push outputHandle
       	call WriteConsole
       	  
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0 
	
	push offset inputBuffer
	call atodw
	mov N, EAX
	;============================================
	
	cmp N, 1
	jbe value_error
	inc result
	cmp N, 2
	je value_error  ; (базовые случаи): N = 1, N = 2
	
	;============================= вычисления ===============================
	mov EBX, 0 ; <-- первый элемент последовательности из двух предыдущих
	mov ECX, 2 ; <-- счетчик
	mov EDX, 1 ; <-- второй элемент последовательности из двух предыдущих  
	
;    числа Фибоначчи: 0, 1, 1, 2, 3, 5, 8, ...
;                     ^  ^  ^
;                     |  |  |
;                     |  |  EAX
;                   EBX  EDX

continue:	
	mov EAX, 0
	add EAX, EBX
	add EAX, EDX
	add result, EAX
	
	mov EBX, EDX
	mov EDX, EAX	
	
	inc ECX        
	cmp ECX, N
	jb continue   ; <-- переход на след. итерацию, если счетчик меньше N
	;========================================================================
        
value_error:
	
	; вывод результата 
	push result
	push offset messageResultTemplate
	push offset messageResult
	call wsprintf
	
	push offset messageResult
       	call lstrlen
       	push NULL
       	push offset numberOfChars
       	push EAX
       	push offset messageResult
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