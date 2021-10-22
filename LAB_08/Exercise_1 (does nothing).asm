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


.data
; Пример описания структуры и объявления массива:
complex struct
	re dq ?
	im dq ?
complex ends
	zero dq 0
	; объявление массива из 5-ти комплексных чисел
	array complex <1.0, 2.0>, <-4.5, 1.25>, <0.0, -3.1>, <3.5, -1.5>, <2.0, 3.0>
.code
; Пример подпрограммы, сравнивающих два комплексных числа:
complexCompareByRealPart:
	; получаем адрес первого аргумента
	mov EAX, [ ESP + 4 ]
	; заносим в вершину стека сопроцессора
	; действительную часть первого аргумента
	fld qword ptr [ EAX ]
	; получаем адрес второго аргумента
	mov EAX, [ ESP + 8 ]
	; сравниваем действительную часть первого
	; аргумента из вершины стека сопроцессора
	; с действительной частью второго аргумента,
	; находящегося в памяти; при этом число из
	; вершины стека сопроцессора удаляется
	fcomp qword ptr [ EAX ]
	; копируем флаги сопроцессора в регистр
	; флагов основного процессора
	fstsw AX
	sahf
	; возвращаем необходимый целочисленный результат
	ja great1
	jb less1
		mov EAX, 0
		jmp return1
	great1:
		mov EAX, 1
		jmp return1
	less1:
		mov EAX, -1
	return1:
ret 8

; Пример подпрограммы, сравнивающих два комплексных числа:
complexCompareByModulus:
	; получаем адрес первого аргумента
	mov EAX, [ ESP + 4 ]
	; заносим в вершину стека сопроцессора
	; действительную часть первого аргумента
	fld qword ptr [ EAX ]
	; возводим действительную часть первого
	; аргумента в квадрат
	fmul ST (0), ST (0)
	; заномив в вершину стека сопроцессора
	; мнимую часть первого аргумента
	fld qword ptr [ EAX + 8 ]
	; возводим мнимую часть первого аргумента
	; в квадрат
	fmul ST (0), ST (0)
	; складываем в регистре ST (1) квадрат
	; действительной и мнимой части, после
	; второй операнд ST (0) удаляется из стека,
	; а результат подымается в вершину стека
	faddp ST (1), ST (0)
	; производим вычисление модуля второго
	; комплексного числа аналогично первому
	mov EAX, [ ESP + 8 ]
	fld qword ptr [ EAX ]
	fmul ST (0), ST (0)
	fld qword ptr [ EAX + 8 ]
	fmul ST (0), ST (0)
	faddp ST (1), ST (0)
	; находим разность квадратов модулей
	; комплексных чисел
	fsubp ST (1), ST (0)
	; сравнение разности модулей с нулём
	fcomp zero
	fstsw AX
	sahf
	; возвращаем целочисленный результат
	ja great2
	jb less2
		mov EAX, 0
		jmp return2
	great2:
		mov EAX, 1
		jmp return2
	less2:
		mov EAX, -1
	return2:
ret 8

; Пример поиска адреса максимального элемента массива:
max:
	; первый параметр - адрес первого
	; элемента массива
	mov EBX, [ ESP + 4 ]
	; количество элементов массива
	mov ECX, [ ESP + 8 ]
	; адрес функции, которая будет
	; сравнивать два элемента массива
	mov EDX, [ ESP + 12 ]

	; заносим в регистр ESI адрес
	; первого элемента массива, в
	; дальнейшем здесь будем хранить
	; адрес макстмального элемента
	mov ESI, EBX

	beginCycle:
		; проверяем, достигнут ли
		; конец массива
		cmp ECX, 0
		je endCycle
		; передаём в функцию сравнения
		; адрес текущего максимального
		; элемента массива
		push ESI
		; передаём в функцию сравнения
		; адрес очередного элемента массива
		push EBX
		; вызываем функцию сравнения,
		; используя концепцию косвенного вызова
		call EDX
		; сравниваем результат, возвращённый
		; функцией сравнения, с нулём
		cmp EAX, 0
		; если текущий максимальный элемент
		; меньше очередного элемента массива
		jng skip
			; запоминаем в качестве адреса
			; максимального элемента массива
			; адрес текущего элемента массива
			mov ESI, EBX
		skip:
		; переходим к следующему элементу массива
		; (используем смещение 16 байт - размер
		; структуры complex)
		add EBX, 16
		; уменьшаем количество элементов массива
		dec ECX
		jmp beginCycle
	endCycle:
	; заносим в регистр EAX адрес максимально
	; элемента массива
	mov EAX, ESI
ret 12

; Пример вызова подпрограммы max для поиска максимального элемента в массиве 
; комплексных чисел, используя сравнение действительных частей элементов:
;   push complexCompareByRealPart
;   push 5
;   push offset array
;   call max
 
; Пример вызова подпрограммы max для поиска максимального элемента в массиве 
; комплексных чисел, используя сравнение модулей элементов:
;   push complexCompareByModulus
;   push 5
;   push offset array
;   call max


;----------------------------- подпрограмма inputNumber -------------------------
; void inputNumber(char* inputMessage, float &number)
; 	inputMessage ( [ EBP + 8 ] ) - сообщение типа "Input number: "
;	number ( [ EBP + 12 ] ) - ссылка на число, которое нужно ввести
inputNumber:
       	push EBP
	mov EBP, ESP   

	push [ EBP + 8 ]
	call lstrlen
	push NULL
	push offset numberOfChars
	push EAX
	push [ EBP + 8 ] 
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

	push [ EBP + 12 ]
	push offset inputBuffer
	call StrToFloat
     
	pop EBP
ret 8

.data
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