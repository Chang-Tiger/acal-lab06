(NTHU_111065541_張騰午) ACAL 2024 Spring Lab 6 HW Submission
===


###### tags: `AIAS Spring 2024` `Submission Template`



## Gitlab code link
:::info
https://course.playlab.tw/git/Tiger_Chang/lab06
:::

- Gitlab link - 

## HW6-1 - Fibonacci Series
### Assembly Code
> 請放上你的程式碼並加上註解，讓 TA明白你是如何完成的。
```mipsasm=
.text
main:
## write assembly code here.
## call fibonacci function and get return value.
    li     a0, 16#用16存入a0傳入
    jal    fibonacci
    j      exit


fibonacci:
## fibonacci function
    beq a0, x0, ret_zero#fib(0)=0
    li t0, 1
    beq a0, t0, ret_one#fib(1)=1
    addi sp, sp, -12#3 spaces for ra, input par a0, return a1
    sw ra, 0(sp)
    sw a0, 4(sp)
    addi a0, a0, -1#fib(n-1)
    jal fibonacci
    sw a1, 8(sp)#save return value
    addi a0, a0, -1#fib(n-2)
    jal fibonacci
    j  done
    
ret_zero:
    mv a1, x0
    jr ra
ret_one:
    li a1, 1
    jr ra
done:#load num and add to final return a1
    lw ra, 0(sp)#return address
    lw a0, 4(sp)#para
    lw t0, 8(sp)#return value
    addi sp, sp, 12
    add a1, t0, a1#fib(n) = fib(n-1)+fib(n-2)
    jr ra
exit:
    ecall
```
### Simulation Result
> 請放上你在 Venus上的模擬結果，驗證程式碼的正確性。(螢幕截圖即可)
![](https://course.playlab.tw/md/uploads/1298971d-4c7d-4f78-93d4-7a6cb84e4fdf.png)
a0 input 16最終a1值為0x000003db也就是987是正確答案


## HW6-2 - Fibonacci Series with C/Assembly Hybrid 
### Assembly Code & C Code
> 請放上你的程式碼並加上註解，讓 TA明白你是如何完成的。
- `fibonacci.S`
```mipsasm=
## assembly code & comment
## fibonacci.S
    .text                          # code section 
    .global fibonacci_asm          # declar the sum_asm function as a  global function
    .type fibonacci_asm, @function # define sum_asm as a function 
fibonacci_asm:
    # Write your assembly code funtion here.
    # Please notice the rules of calling convention.
prologue:#save return address in prologue
    addi sp,sp,-4
    sw ra,0(sp)
    jal fibonacci
    j epilogue
fibonacci: 
    beq a0, x0, ret_zero#fib(0)=0
    li t0, 1
    beq a0, t0, ret_one#fib(1)=1
    addi sp, sp, -12#3 spaces for ra, input par a0, return a1
    sw ra, 0(sp)
    sw a0, 4(sp)
    addi a0, a0, -1
    jal fibonacci
    sw a1, 8(sp)#save return value
    addi a0, a0, -1
    jal fibonacci
    j  done
ret_zero:
    mv a1, x0
    jr ra
ret_one:
    li a1, 1
    jr ra
done:#load num and add to final return a1
    lw ra, 0(sp)#return addr
    lw a0, 4(sp)#para
    lw t0, 8(sp)#return value
    addi sp, sp, 12
    add a1, t0, a1#fib(n) = fib(n-1)+fib(n-2)
    jr ra
epilogue:#restore the address from caller
    lw ra,0(sp)
    addi sp,sp,4
    mv a0, a1    #boot.S中是去a0取return值所以再從a1搬到a0
    jr ra#go back to caller(main)
    
    
    .size fibonacci_asm, .-fibonacci_asm
```



### Simulation Result
> 請放上你在 docker中的 qemu模擬結果，驗證程式碼的正確性。 (螢幕截圖即可)
![](https://course.playlab.tw/md/uploads/517a8d24-0e4c-4767-a386-10ca69ec65be.png)

兩者算fib(16)出來一樣都是正確答案987

## HW6-3 - 2x2 Sudoku
### Assembly Code & C Code

- `sudoku_2x2_asm.S`
```mipsasm=
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
    lb	    t5, 0(t5)  # t5 = sudoku[y*4 + j]
    beq	    t0, t4, check_r_for_next
    bne	    t5, t2, check_r_for_next
    j       return_false  # jump to return_false
check_r_for_next:
    addi    t4, t4, 1
    bne     t3, t4, check_r_loop    #t3 < 4 loop continue, t3==t4 leave loop
#end for

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
#end for


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
#end for

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
    sw		s0, 8(sp) # the num input in check
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
        li        a2, 0
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
```

- `sudoku_2x2_c.c`
```c=
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
bool check(char *sudoku, int idx){
	int y = idx / 4;
	int x = idx % 4;
	for(int j = 0; j < 4; ++j){//check each row
		if(sudoku[y*4 + j] == sudoku[idx] && x != j) {
            return false;
        }
	}
	for(int j = 0; j < 4; ++j){//check each col
		if(sudoku[j*4 + x] == sudoku[idx] && y != j) {
            return false;
        }
	}
	int BLKrow = y / 2 * 2;
	int BLKcol = x / 2 * 2;//check each block
	for(int j = BLKrow; j < BLKrow + 2; ++j){
		for(int k = BLKcol; k < BLKcol + 2; ++k){
			if(sudoku[j*4+k] == sudoku[idx] && j != y && k != x){
				return false;
			}
		}
	}
	return true;
} 

bool backtracking(char *sudoku, int idx){
	if(idx >= 16){ return true;}// all sudoku complete return true
	
	if(sudoku[idx] == 0){//the idx not yet complete
		for(int i = 1; i < 5; ++i){
			sudoku[idx] = i;
			if (check(sudoku,idx) && backtracking(sudoku,idx+1)){
				return true;
			}
		}
		sudoku[idx] = 0;//fail, save 0
    	return false;	
	}else{//the idx complete, go next idx
		return backtracking(sudoku, idx+1);
	}
}

void sudoku_2x2_c(char *test_c_data){
	backtracking(test_c_data, 0);
}
```

### Simulation Result
> ![](https://course.playlab.tw/md/uploads/530c0bb0-d322-4645-b4fb-93ea01f4dbee.png)
4 1 2 3
3 2 1 4
2 3 4 1
1 4 3 2
是正確的
![](https://course.playlab.tw/md/uploads/cb480080-4b8a-4173-ab67-46bc4d76eec5.png)
若是遇到不可能找到解的最終會return原來題目

![](https://course.playlab.tw/md/uploads/d66ce374-b8aa-41e3-b40e-5078ee60369c.png)

## Bonus
### Step 1 C Implementation
> 請放上你C程式碼並加上註解，讓 TA明白你是如何完成的。
> 
### Step 2 Assembly Implementation
> 請放上你Assembly程式碼並加上註解，同時驗證程式碼的正確性。把驗證的結果截圖貼上

### Step 3 Performance Optimization
我們用Instruction Count 來代表performance 的測量metric 的話, 你能怎麼優化你的Assmbly implementation呢？


