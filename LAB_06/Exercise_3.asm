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

; заметки:
; - передать через стек адреса массивов не получается, приходится исп-ть ESI и EDI 

.data?
	trash dq ?   ; <-- сюда буду сбрасывать ненужные значения из вершины стека сопроцессора	

;---------------------------------------- подпрограмма pow ----------------------------------
; void pow(&value, &power)
;   value( [ EBP + 8 ] ) - значение (будет перезаписано)
;   power( [ EBP + 12 ] ) - степень (только положительная)
.data?
	tmp dq ?     ; переменная (исп-ся в pow())
.code
pow:
	push EBP
	mov EBP, ESP
	sub ESP, 8
	
	fld1
	; 1 в ST(0)
        mov EAX, [ EBP + 12 ]
        fld qword ptr [ EAX ]
        ; power в ST(0), 1 в ST(1)
	mov EAX, [ EBP + 8 ]
        fld qword ptr [ EAX ]
        ; value в ST(0), power в ST(1), 1 в ST(2)
        fyl2x       
        ; power*log2value в ST(0), 1 в ST(1)
	fst qword ptr tmp ; <--  power*log2value в tmp  
	; переменная (исп-ся в pow())
	fprem1
	; {power*log2value} в ST(0), 1 в ST(1)
	f2xm1
	; 2^{power*log2value} - 1 в ST(0), 1 в ST(1)
	fld1
	faddp ST(1), ST(0)
	; 2^{power*log2value} в ST(0), 1 в ST(2)	
	fld qword ptr tmp	
	; power*log2value в ST(0), 2^{power*log2value} в ST(1), 1 в ST(2)
	frndint
	; (power*log2value) в ST(0), 2^{power*log2value} в ST(1), 1 в ST(2)
	fld1
	fscale
	; 2^(power*log2value) в ST(0), (power*log2value) в ST(1), 2^{power*log2value} в ST(2), 1 в ST(3)
	fmul ST(0), ST(2)
	
	; результат получен, помещаем его в value
	mov EAX, [ EBP + 8 ]
	fstp qword ptr [ EAX ]
	
	; очищение стека сопроцессора
	fstp trash
	fstp trash
	fstp trash ; 3 раза
	
	mov ESP, EBP
	pop EBP
ret 8
;--------------------------------------------------------------------------------------------
      
;----------- подпрограмма по созданию массивов аргументов и значений функций ----------------
; void makingArray(&arrayWherePutArguments, &arrayWherePutValues, &x1, &x2, &delta_x, &a, &b)
;   arrayWherePutArguments ( [ ESI ] ) - массив, куда функция поместит значения
;   arrayWherePutValues ( [ EDI ] ) - массив, куда функция поместит значения функций
;   x1 ( [ EBP + 16 ] ) - нижняя граница интервала аргументов функции
;   x2 ( [ EBP + 20 ] ) - верхняя граница интервала аргументов функции
;   delta_x ( [ EBP + 24 ] ) - шаг между значениями аргументов
;   a ( [ EBP + 28 ] ) - значение a
;   b ( [ EBP + 32 ] ) - значение b 
; + в ECX будет лежать длина массивов
.data?
	power dq ?
	value dq ?
.code
makingArrays:
	push EBP
	mov EBP, ESP
	sub ESP, 8
	
	finit
	fldz
	; 0 в ST(0)	
	mov EAX, [ EBP + 16 ]
	fld qword ptr [ EAX ]  ; x1 в ST(0), 0 в ST(1) x1 <=> currentXValue
	; currentXValue в ST(0), 0 в ST(1)
	
	mov ECX, 0 ; <-- индекс элемента массива
newIteration:	 
 	fcom ; сравнение currentXValue с 0
 	fstsw AX
 	sahf
 	ja isPositive 
isNegativeOrZero:
        ; x <= 0  
        fld1
	; 1 в ST(0), currentXValue в ST(1), 0 в ST(2)
	mov EAX, [ EBP + 28 ]
	fld qword ptr [ EAX ]
	fmul ST(1), ST(0)
	fstp trash
	fmul ST(0), ST(1)
	fmul ST(0), ST(1)
	; a * x^2 в ST(0), currentXValue в ST(1), 0 в ST(2)
	mov EAX, [ EBP + 32 ]
	fld qword ptr [ EAX ]
	; b в ST(0), a * x^2 в ST(1), currentXValue в ST(2), 0 в ST(3)
	faddp ST(1), ST(0)
	; a * x^2 + b в ST(0), currentXValue в ST(1), 0 в ST(2) 
	; занесение значений в массивы
        fstp qword ptr [ EDI ] ; занесение значения в массив значений функции
        ; currentXValue в ST(0), 0 в ST(1)
        fst qword ptr [ ESI ]  ; занесение значения в массив аргументов функции
        	  
 	jmp finish
isPositive:
 	; x > 0	
	; currentXValue в ST(0), 0 в ST(1)
	fst power ; <-- сразу помещаю значение x в переменную power для вычисления a^x
	mov EAX, [ EBP + 32 ]
	fld qword ptr [ EAX ]
	; b в ST(0), currentXValue в ST(1), 0 в ST(2)
	fld1
	faddp ST(1), ST(0) 
	; b + 1 в ST(0), currentXValue в ST(1), 0 в ST(2)	
	mov EAX, [ EBP + 28 ]
	fld qword ptr [ EAX ]
	; a в ST(0), b + 1 в ST(1), currentXValue в ST(2), 0 в ST(3)
	fstp value
	; value = a, power = currentXValue
	push offset power
	push offset value
	call pow
	fld qword ptr value
	; a^x в ST(0), b + 1 в ST(1), currentXValue в ST(2), 0 в ST(3)
	fsubp ST(1), ST(0)
	; b - a^x + 1 в ST(0), currentXValue в ST(1), 0 в ST(2)
        fstp qword ptr [ EDI ] ; занесение значения в массив значений функции
        ; currentXValue в ST(0), 0 в ST(1)
        fst qword ptr [ ESI ]  ; занесение значения в массив аргументов функции	 	
finish:
	inc ECX ; <-- увеличение индекса элемента в массиве
	; currentXValue в ST(0), 0 в ST(1)
       	add ESI, 8  ; - переход к следующему элементу массива
       	add EDI, 8  ; /
	; currentXValue в ST(0), 0 в ST(1)
	mov EAX, [ EBP + 24 ]
	fld qword ptr [ EAX ]
	fadd ST(1), ST(0) ; <-- увеличение currentXValue на delta_x
	fstp trash
	mov EAX, [ EBP + 20 ]
	fld qword ptr [ EAX ]
	; x2 в ST(0), currentXValue в ST(1), 0 в ST(2)
	fcomp ; сравнение x2 с currentXValue
 	fstsw AX
 	sahf
 	jae newIteration 
	
	mov ESP, EBP
	pop EBP
ret 28
;--------------------------------------------------------------------------------------------

.data
	x1 dq 0
	 x1Str db 256 dup(0)
	x2 dq 0
	 x2Str db 256 dup(0) 
	delta_x dq 0
	 delta_xStr db 256 dup(0)
	a dq 0
	 aStr db 256 dup(0)
	b dq 0   
	 bStr db 256 dup(0)
	                         
	inputX1Message db "input x1: ", 0 
	inputX2Message db "input x2: ", 0 
	inputDeltaXMessage db "input delta x: ", 0
	inputAMessage db "input a: ", 0
	inputBMessage db "input b: ", 0
	
	numberOfBytesToRead dd 256
.data?
	inputBuffer db 256 dup(?)
	inputHandle dd ?
	outputHandle dd ?
	numberOfChars dd ?
.code
entryPoint:

.data
        alertsStr db " - x2 must be greater than x1", 10, 13,
                     " - delta_x must be positive", 10, 13, 10, 13, 0
.code
	
	push STD_INPUT_HANDLE  
	call GetStdHandle 
	mov inputHandle, EAX 
	
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX

	push offset alertsStr 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset alertsStr 
	push outputHandle
	call WriteConsole

	;-------------------- получение x1 ------------------
	push offset inputX1Message 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset inputX1Message 
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
	push offset x1
	push offset inputBuffer
	call StrToFloat
	;----------------------------------------------------
	;-------------------- получение x2 ------------------
	push offset inputX2Message 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset inputX2Message 
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
	push offset x2
	push offset inputBuffer
	call StrToFloat
	;----------------------------------------------------
	;-------------------- получение delta_x -------------
	push offset inputDeltaXMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset inputDeltaXMessage 
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
	push offset delta_x
	push offset inputBuffer
	call StrToFloat
	;----------------------------------------------------
	;-------------------- получение a -------------------
	push offset inputAMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset inputAMessage 
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
	push offset a
	push offset inputBuffer
	call StrToFloat
	;----------------------------------------------------
	;-------------------- получение b ------------------
	push offset inputBMessage 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset inputBMessage 
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
	push offset b
	push offset inputBuffer
	call StrToFloat
	;----------------------------------------------------     	
        
.data
     	arrayOfArguments dq 10 dup(1.0), 502 dup(0)
     	arrayOfFunctionValues dq 10 dup(2.0), 502 dup(3.0)
.code
	; void makingArray(&arrayWherePutArguments, &arrayWherePutValues, &x1, &x2, &delta_x, &a, &b)
	mov EDI, offset arrayOfFunctionValues
	mov ESI, offset arrayOfArguments
	push offset b
	push offset a
	push offset delta_x
	push offset x2
	push offset x1
	push offset arrayOfFunctionValues 
	push offset arrayOfArguments 
	call makingArrays	     
.data
	;                                                          надпись в заголовке		
	headlineStr db 201, 37 dup(205), 187, 10, 13, 186, "     arg ", 20 dup(" "), "val     ", 186, 10, 13, 204, 18 dup(205), 203, 18 dup(205), 185, 10, 13, 0
	footerStr db 200, 18 dup(205), 202, 18 dup(205), 188, 10, 13, 0
        numberOfElements dd 0
        currentIndex dd 0 ; <-- индекс элемента массива
        templateArgAndValStrStr db 186, " %16.16s ", 186, " %16.16s ", 186, 10, 13, 0
        argAndValStr db 256 dup(0) ;        /                /
        argStr db 16 dup(0)   ;------------/                /
        valStr db 16 dup(0)  ;-----------------------------/
.code 
        mov ESI, offset arrayOfArguments
        mov EDI, offset arrayOfFunctionValues

	cmp ECX, 0
	je arraysAreEmpty ; <-- если массивы пустые, то ничего выводится не будет
	mov numberOfElements, ECX ; <-- после работы makingArrays ECX хранит количество элементов
	push offset headlineStr 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset headlineStr 
	push outputHandle
	call WriteConsole
showArgumentWithValue:
	push offset argStr
	push dword ptr [ ESI ] + 4
	push dword ptr [ ESI ]
	call FloatToStr
	push offset valStr
	push dword ptr [ EDI ] + 4
	push dword ptr [ EDI ]
	call FloatToStr
	push offset valStr
	push offset argStr
	push offset templateArgAndValStrStr 
	push offset argAndValStr 
	call wsprintf
	push offset argAndValStr 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset argAndValStr 
	push outputHandle
	call WriteConsole
       	add ESI, 8  ; - переход к следующему элементу массива
       	add EDI, 8  ; /
	add currentIndex, 1
	mov EAX, currentIndex
	cmp EAX, numberOfElements
	jl showArgumentWithValue
	
	push offset footerStr 
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push offset footerStr 
	push outputHandle
	call WriteConsole

arraysAreEmpty:
	
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