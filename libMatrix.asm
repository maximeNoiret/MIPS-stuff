.text


# Function initArray
# Input:
#     $a1: size of array
# Output:
#     $v0: base of array
# Registers used:
#     None
# Note:
#     Made to be used by initMatrix ($a1 instead of $a0). Not made to be used by itself, though it can be.
initArray:
	storeStack($a0)
	li		$v0,	9							# load in syscall code 9 (allocate heap)
	sll		$a0,	$a1,	2					# make size of array * 4 size in heap to allocate
	syscall										# call sbrk, $v0 is now allocated array base
	loadStack($a0)
	jr		$ra									# return $v0 as array base

# Function initMatrix
# Input:
#     $a0: height of matrix (how many arrays?)
#     $a1: width of matric (arrays of how long?)
# Output:
#     $v0: base of matrix
# Registers used:
#     $t0: current index
#     $t1: current offset -> current address
#     $t2: matrix base
initMatrix:
	stra
	
	# allocate space for matrix (array of array pointers)
	storeStack($a0)
	li		$v0,	9							# load in syscall code 9 (allocate heap)
	sll		$a0,	$a0,	2					# make height of matrix * 4 size in heap to allocate 
	syscall										# call sbrk, $v0 is now base of matrix
	loadStack($a0)
	move	$t2,	$v0							# store it for function exit and for loop
	
	# allocate space for every arrays in matrix
	li		$t0,	0							# $t0 = 0
	initMatrix_l:
	beq		$t0,	$a0,	initMatrix_el		# for ($t0 < $a0) {
	jal		initArray							#   call initArray
	sll		$t1,	$t0,	2					#   get offset from index
	add		$t1,	$t1,	$t2					#   get address with matrix base
	sw		$v0,	($t1)						#   store $v0 into (matrix[$t0])
	addi	$t0,	$t0,	1					#   ++$t0
	j		initMatrix_l						# }
	initMatrix_el:
	
	# end of loop, restore $v0 from $t2 for function output
	move	$v0,	$t2
	return										# return matrix base
	
	
# Function printlnMatrix
# Input:
#     $a0: matrix base
#     $a1: matrix length
#     $a2: matrix width
# Output:
#     None
# Registers used:
#     $t2: current index
#     $t3: current array base
# Note:
#     Temp register choice is because of printlnArray
printlnMatrix:
	stra
	li		$t2,	0							# $t2 = 0
	lw		$t3,	($a0)						
	printlnMatrix_l:
	beq		$t2,	$a1,	printlnMatrix_el	# for ($t2 < $a1) {
	sll		$t3,	$t2,	2					#   get $t2 * 4 to get array base offset
	add		$t3,	$t3,	$a0					#   add $a0 to get array base address
	lw		$t3,	($t3)						#   load the value to get array base
	customPrintlnArrayReg($t3, $a2)				#   call customPrintlnArrayReg(current array base, matrix width)
	addi	$t2,	$t2,	1					#   ++$t2
	j		printlnMatrix_l						# }
	printlnMatrix_el:
	return										# return



# Function setMatrixElement
# Input:
#     $a0: matrix base
#     $a1: y
#     $a2: x
#     $a3: value
# Output:
#     None
# Registers used:
#     $t0: address of array at index y -> address of element at index x
#     $t1: array base
setMatrixElement:
	sll		$t0,	$a1,	2					# multiply y by 4
	add		$t0,	$t0,	$a0					# add matrix base to it
	lw		$t1,	($t0)						# get array base
	sll		$t0,	$a2,	2					# multiply x by 4
	add		$t1,	$t1,	$t0					# add array base to it
	sw		$a3,	($t1)						# store word at address
	jr		$ra									# return