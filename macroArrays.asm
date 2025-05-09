.data
	__tempArrayPtrInStack: .word 0

.text

# TODO
.macro customAppend(%element, %array_ptr)
	# save argument registers
	stargs

	# function call
	lw		$a0,	%array_ptr			# load in array base as argument 0
	li		$a1,	%element			# load in element to append as argument 1
	jal append							# call in append
	sw $a0, %array_ptr					# update the pointer to new array base
	
	# restore argument registers
    ldargs
.end_macro

# TODO
.macro customPrintlnArray(%array_ptr)
	storeStack($a0)							# store $a0 to avoid losing it

	# function call
	lw		$a0,	%array_ptr				# load in array_ptr as argument 0
	jal printlnArray						# print the array
	
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

# TODO
.macro customPrintlnArrayReg(%array_ptr, %array_len)
	storeStack($a0)							# store $a0 to avoid losing it
	storeStack($a1)							# store $a1 to avoid losing it

	# function call
	la		$a0,	(%array_ptr)			# load in address contained in (%array_ptr) as argument 0
	move	$a1,	%array_len				# load in array_len as argument 1 as a register (move)
	jal printlnArray						# print the array
	
	loadStack($a1)							# restore $a1 to pre-function state
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

.macro swi(%value, %address)
	li		$t0,	%value				# load immediate value to $t0
	sw		$t0,	%address			# store it in ram at address
.end_macro

.macro init_element(%array_ptr, %offset, %value)
	lw		$t0,	%array_ptr			# load array base to $t0
	addi	$t0,	$t0,	8			# skip metadata
    li		$t1,	%value				# load immidate value to $t1
    sw		$t1,	%offset($t0)		# write it at array base + offset
.end_macro

.macro set_length(%value, %array_ptr)
	lw		$t0,	%array_ptr			# get array base (which is also where length is stored)
	li		$t1,	%value				# get value
	sw		$t1,	($t0)				# store value as length
.end_macro

.macro createArray(%size, %array_ptr)
	storeStack($a0)
	
	# function call
	li		$a0,	%size				# sets size as argument 0
	addi	$a0,	$a0,	2			# add two slots for metadata
	jal		realloc						# allocate size * 4 bytes in heap
	sw		$v0,	%array_ptr			# store newly created allocation to array_ptr
	li		$t0,	%size				# load size, which becomes capacity
	sw		$t0,	4($v0)				# store capacity in array meta data
	
	loadStack($a0)
.end_macro

.macro customSumArray(%array_ptr)
	storeStack($a0)							# store $a0 to avoid losing it
	
	# function call
	lw		$a0,	%array_ptr				# load in array pointer as first argument
	jal		sumArray						# call sumArray procedure
	
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

.macro customAvgArray(%array_ptr)
	customSumArray(%array_ptr)				# get the sum of the array
	lw		$t0,	%array_ptr				# load in its length
	lw		$t0,	($t0)					# get length
	div		$v0,	$v0,	$t0				# sum / length = avg
.end_macro

.macro customMaxArray(%array_ptr)
	storeStack($a0)							# store $a0 to avoid losing it
	
	# function call
	lw		$a0,	%array_ptr				# load in array pointer as first argument
	jal		maxArray						# call sumArray procedure
	
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

.macro customMinArray(%array_ptr)
	storeStack($a0)							# store $a0 to avoid losing it
	
	# function call
	lw		$a0,	%array_ptr				# load in array pointer as first argument
	jal		minArray						# call sumArray procedure
	
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

.macro customSortArray(%array_ptr)
	storeStack($a0)							# store $a0 to avoid losing it
	
	# function call
	lw		$a0,	%array_ptr				# load in array pointer as first argument
	jal		sortArray						# call sumArray procedure
	
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

# TODO
.macro customMedianArray(%array_ptr, %array_len)
	storeStack($a0)
	storeStack($a1)
	
	# function call
	lw		$a0,	%array_ptr
	lw		$a1,	%array_len
	jal		medianArray
	
	loadStack($a1)
	loadStack($a0)
.end_macro

# TODO
.macro customBinarySearch(%array_ptr, %target) # no min since when calling, it's 0.
	stargs  # check if can remove this.
	
	# function call
	lw		$a0,	%array_ptr				# set array as array pointer
	li		$a1,	0						# set index min as 0
	lw		$a2,	($a0)					# load in array length
	addi	$a2,	$a2,	-1				# set index max as length - 1
	li		$a3,	%target					# set target as target
	jal		binarySearch					# call function
	
	ldargs  # same as stargs
.end_macro
