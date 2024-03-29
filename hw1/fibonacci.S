## fibonacci.S
## put input n in register x10 (a0)  
## put output fibonacci(n) in register x11 (a1)
## use Venus to test correctness

.text
main:
## write assembly code here.
## call fibonacci function and get return value.
	li     a0, 16
    jal    fibonacci
    j      exit


fibonacci:
## fibonacci function
    beq a0, x0, ret_zero
    li t0, 1
    beq a0, t0, ret_one
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    addi a0, a0, -1
    jal fibonacci
    sw a1, 8(sp)
    addi a0, a0, -1
    jal fibonacci
    j  done
    
ret_zero:
	mv a1, x0
    jr ra
ret_one:
    li a1, 1
    jr ra
done:
	lw ra, 0(sp)
    lw a0, 4(sp)
    lw t0, 8(sp)
    addi sp, sp, 12
    add a1, t0, a1
	jr ra
exit:
    ecall  