.ORIG	x3000
    LD	R2,	M1
    LD	R1,	Zero
    LD  R3, M2
Loop brz done
    ADD	R1,	R1,	R3
    ADD	R2,	R2,	#-1
    br Loop
done ST	R1,	result
    Halt
result .FILL	x0000
M1 .FILL	x0004
M2 .FILL	x0004
Zero .FILL	x0000
.END


.ORIG	x3000




;main

	ld R1,M1
	JSR comple2s ;st PC+1 into R7 to return
	HALT



;subroutines

comple2s:
	ST R7,SaveR7 ; prevent recusion error
	Not R1,R1
	Add R1,R1,#1
	LD R7,SaveR7
	ret ; same as jmp R7

M1 .fill x0010
SaveR7 .fill x0000
.End


;--------------

; comment
;factorial
.orig x3000
	ld R1,M1
	ld R2,res
	jsr factorial
	st R2,res
	Halt
;subroutine
factorial:
	add R1,R1,#-1
	brz termin ; if the function iterates to the end
	br propag
termin:
	ld R7, SaveR7
	jmp R7
propag:
	st R1,SaveR1
	add R1,R1,#1 ;restore the value of R1
	st R2,SaveR2
	ld R3,SaveR2
	ld R0,SaveR1
	jsr multi
	add R1,R1,#-1 ; subtract the R1
	jsr factorial
multi:
Loop brz done
	add R2,R2,R3
	add R0,R0,#-1
	br Loop
done ret

;data
SaveR1 .FILL x0000
M1 .FILL	x0001
res .FILL	x0001
SaveR2 .FILL x0000
SaveR7 .FILL x3004


;--------------
.orig x3000
	ld R1,M1
	ld R2,res
	jsr factorial
	st R2,res
	Halt
factorial:
	add R1,R1,#-1
	brz termin ; if the function iterates to the end
	br propag
termin:
	ld R7, SaveR7
	jmp R7
propag:
	st R1,SaveR1
	st R2,SaveR2 ;store R2
	ld R3,SaveR2 ;use R3 as the base 
	ld R0,SaveR1 ;use R0 as the counter
Loop brz done
	add R2,R2,R3
	add R0,R0,#-1
	br Loop
done jsr factorial
;data
SaveR1 .FILL x0000
M1 .FILL	x0005
res .FILL	x0001
SaveR2 .FILL x0000
SaveR7 .FILL x3004 ;stores the location of halt

;-------------
.orig x3000
;implement an array(length 5)
	lea R0,array;store the address
	ld R1,length;index
	ld R4,index
loop brz done4
	add R3,R0,R4 ;calculate the address
	str R1,R3,#0 ;store the value in array[R0+R4]
	and R3,R3,#0
	add R4,R4,#-1
	add R1,R1,#-1
	br loop
bubblesort:
	ld R1,length
	lea R0,array
loop BRz done3
	loop1 BRn done2
		add R3,R0,R2
		add R4,R3,#1
		st R4,SaveR4
		st R3,SaveR3
		ldr R4,R3,#1 ;calcalate and load the array[i+1]
		ldr R3,R3,#0 ;calculate and load the array[i]
		
		not R3,R3
		add R3,R3,#1
		add R4,R3,R4;R4=a[i+1]-a[i]

		BRp done1;if a[i] < a[i+1]
		br loop1
		done1:
		ld R4,SaveR4
		ld R3,SaveR3
		ldr R5,R4,#0;store R5 <- a[i+1]
		ldr R6,R3,#0;R6 <- a[i]
		str R5,R3,#0;a[i] <- R5
		str R6,R4,#0;a[i+1] <- R6
		add R2,R2,#-1
		br loop1
	done2
	ld R2,index
	add R2,R2,#-1 ;index-[0,3]
	add R1,R1,#-1
	br loop
done3
add R1,R1,#0
ret
done4
	and R2,R2,#0
	and R1,R1,#0
	and R4,R4,#0
	jsr bubblesort
	halt


array .blkw 5
length .fill x0005
index .fill x0004
SaveR3 .fill x0000
SaveR4 .fill x0000

