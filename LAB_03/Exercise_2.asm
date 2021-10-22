.486
.model flat, stdcall
option casemap :none 
include windows.inc
include kernel32.inc
include masm32.inc
includelib kernel32.lib
includelib masm32.lib 

; ПРОГРАММА ВЕДЕТ СЕБЯ НЕАДЕКВАТНО, ЕСЛИ НЕ УЧИТЫВАТЬ:
; ЗДЕСЬ ОПЕРАНДЫ ВМЕЩАЮТ МАКСИМУМ 2^32 !
; ПЕРВОЕ ЧИСЛО ДОЛЖНО БЫТЬ БОЛЬШЕ ВТОРОГО, Т.К. ЗДЕСЬ ЕСТЬ ВЫЧИТАНИЕ
;  ПЕРВОГО ИЗ ВТОРОГО, А РЕЗУЛЬТАТЫ ВСЕХ ОПЕРАЦИЙ ДОЛЖНЫ БЫТЬ ПОЛОЖИТЕЛЬНЫМИ

; ПРОВЕРКА:
; a = 5, b = 1    результат: 9
; a = 2, b = 1    результат: 9
; a = 10, b = 10  результат: деление на 0
; a = 18, b = 9   результат: 81

.data 
	numberOfCharsToRead dd 255
	a dd 0
	b dd 0 
.data?
	inputHandle dd ?
	outputHandle dd ?
	numberOfChars dd ?
	inputBuffer db ? 
.code
entryPoint:
	
	push STD_INPUT_HANDLE     
	call GetStdHandle         
	mov inputHandle, EAX      
	
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX
	
	;==================== получение 1 числа ======================  
	; чтение первого числа из потока
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	; добавление 0 в конец строки
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0 
	
	push offset inputBuffer
	call atodw
	; как срабатывает:
	; если ввести не только цифры, тогда будет
	; (на заметку: у " " значение 240)
	; " " - это 240
	; " 1" - это 2401
	; "1 " - это 250
	; "1 1" - это 2501	
	
	; помещение полученного числа от функции atodw в переменную
	mov a, EAX 
	;=============================================================
	
	;==================== получение 2 числа ====================== 
	; чтение второго числа из потока
	push NULL
	push offset numberOfChars
	push numberOfCharsToRead 
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	; добавление 0 в конец строки
	mov EDX, offset inputBuffer
	mov EAX, numberOfChars
	mov byte ptr [ EDX + EAX - 2 ], 0 
	
	push offset inputBuffer
	call atodw
	
	; помещение полученного числа от функции atodw в переменную
	mov b, EAX
	;============================================================= 
	
.data  
	;=================== вычисления и вывод ====================== 
     	messageString db 10, "result: "
     	result db 10 dup(" ") ; строка для вывода результата в консоль
	; максимальное значение результата операции будет 2^32 (4294967296)
     	tmp dd 0
.code    
	;----------------------- вычисления --------------------------
        mov EAX, a
	sub EAX, b ; a - b в EAX
	mov tmp, EAX
	; @ теперь tmp = a - b
	mov EAX, a
	add EAX, b ; a + b в EAX
	mul EAX ; (a + b) * (a + b) в ( EDX : EAX )
	div tmp ; (a + b) * (a + b) / (a - b) в EAX	
	;-------------------------------------------------------------	
	
	push offset result
	push EAX
	call dwtoa
	
	push NULL
	push offset numberOfChars
	push 9 ; <-- размер messageString
	push offset messageString
	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 10 ; размер строки result
	push offset result
	push outputHandle
	call WriteConsole
     	;============================================================= 
	
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