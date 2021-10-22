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
     	buffer db 256 dup(0)
        sz dd 20
.data?
	array dd 20 dup(?) ; <-- 20 - это знач. sz
.code 
	; инициализация массива array
	mov ECX, 0
continue:	
	mov [ array + 4 * ECX ], ECX ; массив будет: 0, 1, 2, 3, 4 ...
	inc ECX
	cmp ECX, sz
	jb continue 
	
	; использование подпрограммы
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