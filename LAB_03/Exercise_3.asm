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

.data 
	numberOfCharsToRead dd 255
	a dd 0
	b dd 0
	z dd 0 
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
	
	;==================== получение 3 числа ====================== 
	; чтение третьего числа из потока
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
	mov z, EAX
	;=============================================================	
	
.data  
	;=================== вычисления и вывод ====================== 
     	messageString db 10, "result: "
     	result db 10 dup(" ") ; строка для вывода результата в консоль
	; максимальное значение результата операции будет 2^32 (4294967296)
	tmp_1 dd 0
	tmp_2 dd 0
	tmp_3 dd 0
	tmp_4 dd 0
.code    
	;----------------------- вычисления -------------------------- 
	mov EAX, 128
	mul b ; 128 * b в ( EDX : EAX )
	mov tmp_1, EDX
	mov tmp_2, EAX
	; tmp_1 = с.ч. 128 * b, tmp_2 = м.ч. 128 * b,
	; tmp_3 = 0, tmp_4 = 0
	
	mov EAX, a
	mul EAX ; a^2  в ( EDX : EAX )
	mul EAX ; a^4  в ( EDX : EAX )
	mul a   ; a^5  в ( EDX : EAX )
	mul EAX ; a^10 в ( EDX : EAX )
	mov tmp_3, EDX
	mov tmp_4, EAX
	; tmp_1 = с.ч. 128 * b, tmp_2 = м.ч. 128 * b,
	; tmp_3 = с.ч. a^10, tmp_4 = м.ч. a^10
	
	; помещение a^10 и 128 * a в регистры
	mov EDX, tmp_1
	mov ECX, tmp_2  ; 128 * b в ( EDX : ECX )
	mov EBX, tmp_3
	mov EAX, tmp_4  ;   a^10  в ( EBX : EAX )
	; сложение 64-разрядных чисел
	add EAX, ECX
	adc EBX, EDX ;        a^10 + 128 * b в ( EBX : EAX )	
	mov EDX, EBX ; теперь a^10 + 128 * b в ( EDX : EAX )
	div z ;	(a^10 + 128 * b) / z в EAX
	      ; (a^10 + 128 * b) % z в EDX
	add EAX, EDX ; 	(a^10 + 128 * b) / z + (a^10 + 128 * b) % z в EAX
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