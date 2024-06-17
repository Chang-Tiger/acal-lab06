# sudoku_2x2_asm.S
   
    .text                           # code section 
    .global sudoku_2x2_asm          # declare the asm function as a global function
    .type sudoku_2x2_asm, @function # define sum_asm as a function 
sudoku_2x2_asm:
prologue:
	addi	sp, sp, -4
    sw		ra, 0(sp)
sudoku_2x2:
    li	    a1, 0 # a1 save sudoku idx 0
	jal		backtracking
    j       epilogue

check:
    srli    t1, a1, 2#int y = idx / 4;
	andi    t0, a1, 3#int x = idx % 4;
    
    add		t2, a0, a1  #addr = base addr +idx(offset)
    lb		t2, 0(t2)   #check_num(t2) = sudoku[idx]

    addi	sp, sp, -16 
	sw		s1, 0(sp)
	sw		s2, 4(sp)
    sw		s3, 8(sp)
	sw		s4, 12(sp)
/*for(int j = 0; j < 4; ++j){//check each row
		if(sudoku[y*4 + j] == sudoku[idx] && x != j) {
            return false;
        }
	}*/
    # t0 for x, t1 for y, t2 = check_num
    #for(int j = 0; j < 4; ++j)
    li	    t3, 4 # max
	li	    t4, 0 # j
check_r_loop:
    slli    t5, t1, 2
    add     t5, t5, t4 #y*4 + j(offset)
    add     t5, t5, a0 # t5 = base + offset
    lb		t5, 0(t5)  # t5 = sudoku[y*4 + j]
    beq		t0, t4, check_r_for_next
    bne		t5, t2, check_r_for_next
    j       return_false  # jump to return_false
check_r_for_next:
    addi    t4, t4, 1
    bne     t3, t4, check_r_loop    #t3 < 4 loop continue, t3==t4 leave loop

    /*for(int j = 0; j < 4; ++j){//check each col
		if(sudoku[j*4 + x] == sudoku[idx] && y != j) {
            return false;
        }
	}*/
    #for(int j = 0; j < 4; ++j){
    li	    t3, 4 # max
	li	    t4, 0 # j
check_c_loop:
    slli    t5, t4, 2   #j*4
    add     t5, t5, t0 #j*4 + x(offset)
    add     t5, t5, a0 # t5 = base + offset
    lb		t5, 0(t5)  # t5 = sudoku[j*4 + x]
    beq		t1, t4, check_c_for_next#if(sudoku[j*4 + x] == sudoku[idx] && y != j)
    bne		t5, t2, check_c_for_next
    j       return_false  # jump to return_false
check_c_for_next:
    addi    t4, t4, 1
    bne     t3, t4, check_c_loop    #t3 < 4 loop continue, t3==t4 leave loop
    /*
    int BLKrow = y / 2 * 2;
	int BLKcol = x / 2 * 2;//check each block
	for(int j = BLKrow; j < BLKrow + 2; ++j){
		for(int k = BLKcol; k < BLKcol + 2; ++k){
			if(sudoku[j*4+k] == sudoku[idx] && j != y && k != x){
				return false;
			}
		}
	}
	return true;*/
    srli s1, t1, 1 # s1 = y / 2
    slli s1, s1, 1 # s1 = y / 2 * 2 = BLKrow
    srli s3, t0, 1 # s3 = x / 2
    slli s3, s3, 1 # s3 = x / 2 * 2 = BLKcol

    mv	t3, s1	# j(t3) = BLKrow(s1)
	addi s2, s1, 2 # s2 = j_max = BLKrow(s1) + 2

check_b_loop_r:
    mv	t4, s3	# k(t4) = BLKcol(s3)
	addi s4, s3, 2 # s4 = k_max = BLKcol(s3) + 2
    check_b_loop_c:
        slli    t5, t3, 2#t5 = j*4
        add     t5, t5, t4#t5 = j*4+k(offset)
        add     t5, t5, a0 # t5 = base + offset
        lb		t5, 0(t5)  # t5 = sudoku[j*4+k]
        bne     t5, t2, check_b_for_next_c # sudoku[j*4 + k] != check_num(t2), continue
        beq     t3, t1, check_b_same_row # j == y, continue
        j	return_false # sudoku[j*4+k] == sudoku[idx] && j != y && k != x, return false
        check_b_same_row:
            beq     t4, t0, check_b_for_next_c # k == x, continue
            j	    return_false #not same pos with same value, return false
    check_b_for_next_c:
        addi    t4, t4, 1 # ++k(t4)
        bne     t4, s4, check_b_loop_c # t4 != k_max(s4), next col. t4 == k_max(s4), next row.
check_b_for_next_r:
    addi    t3, t3, 1 # ++j(t3)
    bne     t3, s2, check_b_loop_r # t3 != k_max(s2), next row. t4 == k_max(s4), return true.

return_true:
    sw		s1, 0(sp)
    sw		s2, 4(sp)
    sw		s3, 8(sp) 
    sw		s4, 12(sp)
    addi	sp, sp, 16
    li		a2, 1
    jr	    ra


return_false:
    sw		s1, 0(sp)
    sw		s2, 4(sp)
    sw		s3, 8(sp) 
    sw		s4, 12(sp)
    addi	sp, sp, 16
    li		a2, 0
    jr	    ra

backtracking:
    addi	sp, sp, -12 
    sw		ra, 0(sp) # save ra
	sw		a1, 4(sp) # save idx
	sw		s0, 8(sp) # save num
    li      t0, 16
    bge		a1, t0, true_output#if(idx >= 16){ return true;}

    add		t0, a0, a1# base address + offset
    lb      t0, 0(t0)

    bgtz	t0, next_tracking#sudoku[idx] > 0, return backtracking(sudoku, idx+1)

##for loop: for(int s0 = 1; s0 < 5; ++s0)
    li      s0, 1
backtracking_loop:
    add		t0, a0, a1  #addr = base addr +idx(offset)
    sb		s0, 0(t0)   #sudoku[idx] = s0
    jal		check
	beqz	a2, for_next
    addi	a1, a1, 1
    jal		backtracking
    addi	a1, a1, -1
	beqz	a2, for_next
    j		true_output
    for_next:
        addi	s0, s0, 1	# ++s0
        li		t0, 5
        blt		s0, t0, backtracking_loop #s0 < 5

    add		t0, a0, a1  #addr = base addr +idx(offset)
	sb		x0, 0(t0)   #sudoku[idx] = 0;
	j		false_output
##for loop end

next_tracking:
    addi	a1, a1, 1	# add index by 1
	jal		backtracking		# backtracking(sudoku, idx+1)
	# return value save in a2 and don't need changes
	addi    a1, a1, -1	# recover index

	lw      s0, 8(sp) # recover current num
    lw      a1, 4(sp) # recover idx
	lw      ra, 0(sp) # recover ra
	addi    sp, sp, 12
	jr	    ra

true_output:
	li	    a2, 1
	lw      s0, 8(sp)
    lw      a1, 4(sp)
	lw      ra, 0(sp)
	addi    sp, sp, 12
	jr	    ra
false_output:
	li	    a2, 0
	lw      s0, 8(sp)
    lw      a1, 4(sp)
	lw      ra, 0(sp)
	addi    sp, sp, 12
	jr	    ra
epilogue:
    lw		ra, 0(sp) # return main function addr
	addi	sp, sp, 4
	jr		ra
    .size sudoku_2x2_asm, .-sudoku_2x2_asm