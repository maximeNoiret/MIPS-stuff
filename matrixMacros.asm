.text

.macro initMatrixI(%height, %width, %matrix_ptr, %matrix_len, %matrix_wid)
	storeStack($a0)
	storeStack($a1)
	
	li		$a0,	%height
	li		$a1,	%width
	jal		initMatrix
	sw		$v0,	%matrix_ptr
	sw		$a0,	%matrix_len
	sw		$a1,	%matrix_wid
	
	loadStack($a1)
	loadStack($a0)
.end_macro

.macro printMatrix(%matrix_ptr, %matrix_len, %matrix_wid)
	storeStack($a0)
	storeStack($a1)
	storeStack($a2)
	
	lw		$a0,	%matrix_ptr
	lw		$a1,	%matrix_len
	lw		$a2,	%matrix_wid	
	jal		printlnMatrix
	
	loadStack($a2)
	loadStack($a1)
	loadStack($a0)
.end_macro

.macro setMatrixElementI(%matrix_ptr, %y, %x, %value)
	stargs
	
	lw		$a0,	%matrix_ptr
	li		$a1,	%y
	li		$a2,	%x
	li		$a3,	%value
	jal		setMatrixElement
	
	ldargs
.end_macro