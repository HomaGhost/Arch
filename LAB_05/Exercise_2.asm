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

; ------------- Подпрограмма ArrayToStr ---------------------
; void arrayToStr(char* buffer, int* array, int size)
;
; Формирует строковое представление целочисленного массива
;
; Входные параметры:
;       buffer ( [EBP + 8] )  - указатель на строку, в которой будет
;                               формироваться представление массива
;       array  ( [EBP + 12] ) - указатель на массив
;       size   ( [EBP + 16] ) - количество элементов в массиве

.data
        template db "%d ", 0    ; Образец строки для одного целого числа

.code

arrayToStr:
        ; Стандартный пролог функции
        push EBP
        mov EBP, ESP
        ; начало цикла - пока есть необработанные элементы
        cycle:
                cmp dword ptr [ EBP + 16 ], 0
                je endFunction
                ; Формирование текстового представления целого числа
                mov EAX, [ EBP + 12 ]         ; указатель на очередное число
                push [ EAX ]                  ; целое число (элемент массива),
                                              ; преобразуемое в строку
                push offset template          ; шаблон строки, в который
                                              ; подставляются значения
                push [ EBP + 8 ]              ; адрес буфера для размещения
                                              ; итоговой строки
                call wsprintf                 ; в EAX записывается число символов,
                                              ; записанных в буфер
                add ESP, 12                   ; выровняем стек
                ; Подготовка к следующему числу
                add [ EBP + 8 ], EAX          ; рассчитаем адрес строки для
                                              ; следующего числа
                add dword ptr [ EBP + 12 ], 4 ; перемещаем указатель на следующий
                                              ; элемент массива
                dec dword ptr [ EBP + 16 ]    ; уменьшаем счетчик
        ; конец цикла
        jmp cycle
        endFunction:
        ; Стандартный эпилог функции
        pop EBP
; Выйти и выровнять стек
ret 12 
;------------------------------------------------------------

;-------------- подпрограмма countSum -----------------------
; int countSum(int* array, int size)
;
; Считает сумму элементов целочисленного массива, возвращает
; сумму в регистре EAX (т.е. максимум 32-битное число)
;
; Входные параметры:
;       array ( EDX )  - указатель на массив
;       size   ( EAX ) - количество элементов в массиве
.data
	sum dd 0
.code

countSum:
	mov sum, 0
	mov ECX, 0
	cmp EAX, 0
	jbe endCountSum
countSum_cycle:
		mov EBX, [ EDX + 4 * ECX ]
	        add sum, EBX  ; <-- add <ячейка_памяти>, <регистр>
	        inc ECX                   
		cmp ECX, EAX
		jb countSum_cycle
endCountSum:	
	mov EAX, sum
ret
;------------------------------------------------------------

;--------- подпрограмма changeEvenElements ------------------
; void changeEvenElements(int* array, int size)
;
; Считает сумму элементов целочисленного массива
;
; Входные параметры:
;       array  ( [EBP + 8] )  - указатель на массив
;       size   ( [EBP + 12] ) - количество элементов в массиве  
.code
changeEvenElements:
	push EBP
	mov EBP, ESP
	   
	cmp dword ptr [ EBP + 12 ], 0
	je endChangeEvenElements 
	
	mov ECX, 0
	add dword ptr [ EBP + 8 ], 4 ; чтобы начать со 2 элемента
changeEvenElements_cycle:
	mov EDX, 0                  ;	\
	mov EBX, [ EBP + 8 ]        ;	 |
	mov dword ptr EAX, [ EBX ]  ;	  > возведение в квадрат
	mul EAX                     ;	 |
	mov [ EBX ], EAX            ;	/
	       
	add dword ptr [ EBP + 8 ], 8  ; переход к следующему элементу массива
	add ECX, 2	
	cmp ECX, [ EBP + 12 ]
	jb changeEvenElements_cycle
endChangeEvenElements:

	pop EBP
ret 8
;------------------------------------------------------------ 
	
.data?
	inputBuffer db ?
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
.data  
        arrayMessage db "array: ", 0
        
     	buffer db 256 dup(0)
        sz dd 12
.data?
	array dd 12 dup(?) ; <-- 12 - это знач. sz
.code 
        push offset arrayMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset arrayMessage 
	push outputHandle
	call WriteConsole
	
	; инициализация массива array	
	mov [ array ], 0
	mov [ array + 4 ], 1 
	mov EBX, [ array ]
	mov EDX, [ array + 4 ]
	
	mov ECX, 2	
continue:
       	mov EAX, 0
       	add EAX, EBX
       	add EAX, EDX
       	
       	mov EBX, EDX
       	mov EDX, EAX
		
	mov [ array + 4 * ECX ], EAX
	inc ECX
	cmp ECX, sz
	jb continue 
	
	; использование подпрограммы arrayToStr
	push sz
	push offset array
	push offset buffer
	call arrayToStr
	
	push offset buffer
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset buffer
	push outputHandle
	call WriteConsole

.data
        arraySumMessageTemplate db 10, 13, "sum of elements: %d", 10, 13, 0
        arraySumMessage db 256 dup(0)
.code 

	; использование подпрограммы countSum 
	mov EDX, offset array
	mov EAX, sz
	call countSum
	
	; вывод суммы
	push EAX
	push offset arraySumMessageTemplate 
	push offset arraySumMessage 
	call wsprintf
	
       	push offset arraySumMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset arraySumMessage 
	push outputHandle
	call WriteConsole
	
	;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	;|||||||||||||| использование подпрограммы changeEvenElements ||||||||||||
	;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	push sz
	push offset array
	call changeEvenElements  

	push offset arrayMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset arrayMessage 
	push outputHandle
	call WriteConsole
	
	mov ECX, 0
zeroMemory_cycle:
	mov [ buffer + ECX ], 0
	mov [ arraySumMessage + ECX ], 0
	inc ECX
	cmp ECX, 256
	jb zeroMemory_cycle
	
	; использование подпрограммы arrayToStr
	push sz
	push offset array
	push offset buffer
	call arrayToStr
	
	push offset buffer
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset buffer
	push outputHandle
	call WriteConsole
	
	; использование подпрограммы countSum 
	mov EDX, offset array
	mov EAX, sz
	call countSum
	
	; вывод суммы
	push EAX
	push offset arraySumMessageTemplate 
	push offset arraySumMessage 
	call wsprintf
	
       	push offset arraySumMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset arraySumMessage 
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