.data
	matrix_ptr:	.word	0
	matrix_len:	.word	0
	matrix_wid:	.word	0

.text

.include "functionMacros.asm"
.include "matrixMacros.asm"
.include "dynArrayMacros.asm"


main:
	print("Matrix of 5x5:\n")
	initMatrixI(5, 5, matrix_ptr, matrix_len, matrix_wid)
	printMatrix(matrix_ptr, matrix_len, matrix_wid)
	jal newline
	
	print("Now inserting 9 at [1][3].\n")
	setMatrixElementI(matrix_ptr, 1, 3, 9)
	printMatrix(matrix_ptr, matrix_len, matrix_wid)
	jal newline
	
	exit

.include "libFunctions.asm"
.include "libMatrix.asm"
.include "libDynamicArray.asm"