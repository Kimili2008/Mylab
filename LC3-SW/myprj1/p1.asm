.ORIG x0001     
        LD R1, n        ; R1 = N
        AND R0, R0, #0  ; R0 = RES
        AND R2, R2, #0  ; R2 = 0 (a_{n-1})
        ADD R3, R2, #1  ; R3 = 1 (a_n)
        
        JSR FIB
        
        HALT

; Fibonacci Sequence
FIB     BRz DONE        ; 
        ADD R4, R3, #0  ;
        ADD R3, R3, R2  ; a_{n+1} = a_n + a_{n-1}
        ADD R2, R4, #0  ; a_{n-1} = a_n
        ADD R1, R1, #-1 ; N--
        BRnzp FIB       ; 

DONE    ADD R0, R2, #0  ; Res
        RET

n       .FILL #5        ; Fib(5)
.END