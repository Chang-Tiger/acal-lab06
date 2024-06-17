## fibonacci.S

    .text                          # code section 
    .global fibonacci_asm          # declar the sum_asm function as a  global function
    .type fibonacci_asm, @function # define sum_asm as a function 
fibonacci_asm:
    # Write your assembly code funtion here.
    # Please notice the rules of calling convention.
prologue:
    addi sp,sp,-4
    sw ra,0(sp)
    jal fibonacci
    j epilogue
fibonacci: 
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
epilogue:
    mv a0, a1
    lw ra,0(sp)
    addi sp,sp,4
    jr ra
    
    
    .size fibonacci_asm, .-fibonacci_asm