TITLE Project   (project.asm)

; Author: Mikayla Friend
; Last Modified: 11/21/20
; Description: Displays the introduction. Generates 200 random integers in a 
;		specified range and stores then in an array. Displays the list of ints.
;		Sorts the list in ascending order. Calculates the median values.
;		Displays the sorted array. Counts and displays the count of each number
;		in the array.
;              

INCLUDE Irvine32.inc

LO = 10
HI = 29
ARRAYSIZE = 200

.data

intro			BYTE		"Generating, Sorting, and Counting Random integers! Programmed by Mikayla Friend",13,10,0
instructions1	BYTE		"This program generates ",0
instructions2	BYTE		" random numbers in the range ",0
instructions3	BYTE		" - ",0
instructions4	BYTE		"Displays the original list, sorts the lists, displays the median value of the list, displays the list ",0 
instructions5	BYTE		"sorted in ascending order, then displays the number of instances of each generated value.",13,10,0
unsortedTitle	BYTE		"Your unsorted random numbers:",13,10,0
sortedTitle		BYTE		"Your sorted random numbers:",13,10,0
medianTitle		BYTE		"The median value of the array: ",0
countTitle1		BYTE		"Your list of instances of each generated number, starting with the number of ",0
countTitle2		BYTE		"s:",13,10,0
byeBye			BYTE		"Thank you! Goodbye!",13,10,0

countSize		DWORD		?
randArray		DWORD		ARRAYSIZE DUP(?)
countArray		DWORD		ARRAYSIZE DUP(0)

.code
main PROC
	push	OFFSET intro
	push	OFFSET instructions1
	push	OFFSET instructions2
	push	OFFSET instructions3
	push	OFFSET instructions4
	push	OFFSET instructions5
	push	LO
	push	HI
	push	ARRAYSIZE
	call	introduction

	push	ARRAYSIZE
	push	OFFSET	randArray
	push	HI
	push	LO
	call	fillArray

	push	ARRAYSIZE
	push	OFFSET randArray
	push	OFFSET unsortedTitle
	call	displayList

	push	OFFSET randArray
	push	ARRAYSIZE
	call	sortList

	push	ARRAYSIZE
	push	OFFSET randArray
	push	OFFSET sortedTitle
	call	displayList

	push	OFFSET medianTitle
	push	OFFSET randArray
	push	ARRAYSIZE
	call	displayMedian

	push	OFFSET countSize
	push	ARRAYSIZE
	push	HI
	push	LO
	push	OFFSET countArray
	push	OFFSET randArray
	call	countList

	mov		EDX, OFFSET countTitle1				;"Your list of instances..."
	call	WriteString
	mov		EAX, LO
	call	WriteDec
	push	countSize
	push	OFFSET countArray
	push	OFFSET countTitle2
	call	displayList
	
	push	OFFSET byeBye
	call	goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ------------------------------------------------------------------------------
; Name: goodBye
;
; Says goodbye to user
;
; Postconditions: Changes registers EAX, EDX, EBP
;
; Receives: 
;	[ebp+4]		= OFFSET of byeBye
; ------------------------------------------------------------------------------
goodBye	PROC
	mov		EBP, ESP

	call	Crlf
	mov		EDX, [ebp+4]						;"Thank you! Goodbye!"
	call	WriteString

	ret		4
goodBye	ENDP


; ------------------------------------------------------------------------------
; Name: countList
;
; Counts the number of instances of each number in an array.
;
; Preconditions: The difference between HI and LO must be less than 
;	ARRAYSIZE. Array must be sorted.
;
; Postconditions: Changes registers EBP, EAX, EBX, ECX, and EDX
;
; Receives: 
;			[ebp+24] = OFFSET of countSize
;			[ebp+20] = ARRAYSIZE
;			[ebp+16] = HI
;			[ebp+12] = LO
;			[ebp+8] = OFFSET of countArray
;			[ebp+4] = OFFSET of randArray
;
; Returns: Returns countArray and countSize
; ------------------------------------------------------------------------------
countList PROC
	mov		EBP, ESP

	;Find number of numbers in randArray
	mov		EAX, [ebp+16]						;HI
	sub		EAX, [ebp+12]						;LO
	inc		EAX
	mov		EBX, [ebp+24]						;OFFSET of countSize
	mov		[EBX], EAX

	mov		EDX, [ebp+12]						;LO					
	mov		EAX, [ebp+8]						;OFFSET of countArray
	mov		EBX, [ebp+4]						;OFFSET of randArray
	mov		ECX, [ebp+20]						;ARRAYSIZE

;Loop through randArray and compare EDX to each element. If not equal, inc EDX
_countLoop:
	cmp		[EBX], EDX
	jne		_nextCountNum
	push	EBX									;Utilize stack for local variable	
	mov		EBX, [EAX]						
	add		EBX, 1								;Add 1 to countArray element if equal
	mov		[EAX], EBX
	pop		EBX
	add		EBX, 4								;move to next element in randArray
	loop	_countLoop

	jmp _end
_nextCountNum:
	inc		EDX
	add		EAX, 4								;go to next element in countArray
	jmp		_countLoop
	
_end:
	ret		24
countList ENDP


; ------------------------------------------------------------------------------
; Name: displayMedian
;
; Finds the median of an assorted array
;
; Preconditions: array must be DWORDS, sorted, and numbers must be unsigned.
;
; Postconditions: Registers EBX, EAX, EDX are changed
;
; Receives: 
;			[ebp+16] = OFFSET medianTitle
;			[ebp+12]  = OFFSET of randArray
;			[ebp+8]  = ARRAYSIZE
;			-4 after pop of local variable
;
; Returns: Prints the median.
; ------------------------------------------------------------------------------
displayMedian PROC
	mov		EBP, ESP
	
	mov		EDX, [ebp+12]						;"The median value..."
	call	WriteString

	;Find middle number
	xor		EDX, EDX
	mov		EAX, [ebp+4]						;ARRAYSIZE
	mov		EBX, 2
	div		EBX
	push	EDX
	imul	EAX, 4
	mov		EBX, [ebp+8]						;Offset of randArray
	add		EBX, EAX							;Move EBX to point to middle num
	mov		EAX, [EBX]

	pop		EDX									;Test if there is remainder from div		
	cmp		EDX, 0								;if odd num of elements, mid num
	jnz		_print								;already found

	;even number of elements, calculate median
	mov		EAX, EBX							;get number before EBX
	sub		EAX, 4

	mov		EAX, [EAX]
	add		EAX, [EBX]
	mov		ECX, 2
	xor		EDX, EDX
	div		ECX

	cmp		EDX, 0
	jz		_print								;If no remainder, no need to round up
	inc		EAX
	
_print:
	call	WriteDec
	call	Crlf
	call	Crlf

_end:
	ret 12
displayMedian ENDP


; ------------------------------------------------------------------------------
; Name: exchangeElements
;
; Swaps two values by reference
;
; Preconditions: Value passed is at least one BYTE behind the last BYTE in list.
;
; Postconditions: Register EAX and EBX are changed.
;
; Receives: 
;			[ebp+8] = element to be swapped
;
; Returns: Swaps [ebp+8] with [ebp+8]+4
; ------------------------------------------------------------------------------
exchangeElements PROC
	push	EBP
	mov		EBP, ESP
	
	mov		ESI, [ebp+8]						;get offset of values that will be swapped
	mov		EDI, ESI
	add		EDI, 4

	mov		EAX, [ESI]							;get values
	mov		EBX, [EDI]

	mov		[ESI], EBX							;swap
	mov		[EDI], EAX

	pop		EBP
	ret		4
exchangeElements ENDP


; ------------------------------------------------------------------------------
; Name: sortList
;
; Sorts array in ascending order using bubble sort.
;
; Preconditions: randArr and correct ARRAYSIZE must be on stack.
;
; Postconditions: Changes registers EBP, EAX, EBX, ECX, EDX
;
; Receives: 
;			[ebp+8] = reference to randArr
;			[ebp+4] = ARRAYSIZE
;			[ebp-4] = I
;			[ebp-8] = N-1
;			[ebp-12] = J
;			[ebp-16] = N - I - 1
;
; Returns: Reorganizes randArray to be sorted.
; ------------------------------------------------------------------------------
sortList PROC
	mov		EBP, ESP
	push	0									;first counter (i)
	mov		EAX, [ebp+4]
	dec		EAX
	push	EAX									;first counter limit (n-1)
	push	0									;second counter (j)
	push	EAX									;second counter limit (n-i-1)
	mov		EDX, [ebp+8]						;reference to randArr

_sortLoop1:
	mov		EAX, [ebp+4]						;calculate second counter limit
	sub		EAX, [ebp-4]
	dec		EAX
	mov		[ebp-16], EAX
	mov		EAX, 0								;reset second counter
	mov		[ebp-12], EAX					
	mov		EDX, [ebp+8]						;start at beginning of array

_sortLoop2:
	mov		EAX, [EDX]							;compare elements
	mov		EBX, [EDX+4]
	cmp		EAX, EBX
	jle		_sortLoop2Cond
	push	EDX
	call	exchangeElements

_sortLoop2Cond:
	;inc 2nd counter, inc up list and save
	add		EDX, 4
	mov		ECX, [ebp-12]						
	inc		ECX
	mov		[ebp-12], ECX
	cmp		ECX, [ebp-16]						;second loop condition
	jl		_sortLoop2

_sortLoop1Cond:
	;inc 1st counter and save
	mov		ECX, [ebp-4]						
	inc		ECX
	mov		[ebp-4], ECX
	cmp		ECX, [ebp-8]						;first loop condition
	jl		_sortLoop1
	
	mov		ESP, EBP
	ret		8
sortList ENDP


; ------------------------------------------------------------------------------
; Name: displayList
;
; Prints an array.
;
; Preconditions: Array must have 4 BYTE elements.
;
; Postconditions: Changes registers EBP, ECX, EAX, EBX
;
; Receives: 
;			[ebp+16] = ARRAYSIZE
;			[ebp+12]  = reference to randArray
;			[ebp+8]  = reference to title1
; ------------------------------------------------------------------------------
displayList PROC
	push	20									;inline counter
	mov		EBP, ESP
	mov		ECX, [ebp+16]						;ARRAYSIZE
	mov		EBX, [ebp+12]						;reference to randArray

	mov		EDX, [ebp+8]						;"Your unsorted..."
	call	WriteString

_printArr:
	mov		EAX, [EBX]							;print num and space
	call	WriteDec
	mov		AL, ' '
	call	WriteChar

	add		EBX, 4								;Move to next element
	mov		EAX, [EBP]							;decrement inline counter
	dec		EAX
	mov		[EBP], EAX

	cmp		EAX, 0								;test if 20 numbers have been printed
	jnz		_noNewLine
	call	crlf
	mov		EAX, 20
	mov		[EBP], EAX
_noNewLine:
	loop	_printArr

	call	Crlf
	pop		EBP
	ret		12
displayList ENDP


; ------------------------------------------------------------------------------
; Name: fillArray
;
; Fills randArray with random integers within specified range.
;
; Preconditions: Array must have 4 BYTE elements.
;
; Postconditions: Changes registers EBP, EAX, EBX, ECX
;
; Receives: 
;			[ebp+16] = ARRAYSIZE
;			[ebp+12] = reference to randArray
;			[ebp+8]	 = HI
;			[ebp+4]  = LO
;
; Returns: randArray
; ------------------------------------------------------------------------------
fillArray PROC
	mov		EBP, ESP
	call	Randomize
	mov		ECX, [ebp+16]						;ARRAYSIZE
	mov		EBX, [ebp+12]						;reference to randArray

;generates random number in range
_generateRandNum:
	mov		EAX, [ebp+8]						;HI
	inc		EAX
	call	RandomRange
	cmp		EAX, [ebp+4]
	jl		_generateRandNum					;generate new number if less than
												;lowest range
	mov		[EBX], EAX
	add		EBX, 4
	LOOP	_generateRandNum

	ret		16
fillArray ENDP


; ------------------------------------------------------------------------------
; Name: introduction
;
; Introduce the program and instructions
;
; Postconditions: Changes registers EAX, EDX, EBP
;
; Receives: 
;	[ebp+36]	= reference to intro
;	[ebp+32]	= reference to instructions1
;	[ebp+28]	= reference to instructions2
;	[ebp+24]	= reference to instructions3
;	[ebp+20]	= reference to instructions4
;	[ebp+16]	= reference to instructions5
;	[ebp+12]	= value of LO
;	[ebp+8]		= value of HI
;	[ebp+4]		= value of ARRAYSIZE
; ------------------------------------------------------------------------------
introduction PROC
	mov		EBP, ESP

	;Display Intro
	mov		EDX, [ebp+36]						;"Generating, Sorting..."
	call	WriteString
	call	Crlf

	;Display instructions
	mov		EDX, [ebp+32]						;"This program generates "
	call	WriteString
	mov		EAX, [ebp+4]						; ARRAYSIZE
	call	WriteDec
	mov		EDX, [ebp+28]						;" random numbers..."
	call	WriteString
	mov		EAX, [ebp+12]						;LO
	call	WriteDec
	mov		EDX, [ebp+24]						;" - "
	call	WriteString
	mov		EAX, [ebp+8]						;HI
	call	WriteDec
	call	Crlf
	mov		EDX, [ebp+20]						;", displays the original..."
	call	WriteString
	call	Crlf
	mov		EDX, [ebp+16]						;" the list sorted..."
	call	WriteString
	call	Crlf

	ret		36
introduction ENDP

END main
