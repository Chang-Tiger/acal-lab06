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
	if(idx >= 16){ return true;}
	
	if(sudoku[idx] == 0){
		for(int i = 1; i < 5; ++i){
			sudoku[idx] = i;
			if (check(sudoku,idx) && backtracking(sudoku,idx+1)){
				return true;
			}
		}
		sudoku[idx] = 0;
    	return false;	
	}else{
		return backtracking(sudoku, idx+1);
	}
}

void sudoku_2x2_c(char *test_c_data){
	backtracking(test_c_data, 0);
}
