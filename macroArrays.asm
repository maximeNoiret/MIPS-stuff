.data
	__tempArrayPtrInStack: .word 0

.text

# TODO
.macro customAppend(%element, %array_ptr, %array_len, %array_cap)
	# save argument registers
	stargs

	# function call
	lw		$a0,	%array_ptr			# load in array base as argument 0
	li		$a1,	%element			# load in element to append as argument 1
	lw		$a2,	%array_len			# load in array length as argument 2
	lw		$a3,	%array_cap			# load in array capacity as argument 3
	jal append							# call in append
	beqz $v0, skippedRealloc			# if there was a reallocation
	sw $a0, %array_ptr					# update the pointer to new array base
	sw $a3, %array_cap					# update the capacity to new capacity
	# Note: wtf? How does this label work?
	# nvm, looked at the resulting assembly and it just creates new labels skippedRealloc_M5 and skippedRealloc_M6
	skippedRealloc:
	sw $a2, %array_len					# update the length to new length (so should be +1)
	
	# restore argument registers
    ldargs
.end_macro

# TODO
.macro customPrintlnArray(%array_ptr, %array_len)
	storeStack($a0)							# store $a0 to avoid losing it
	storeStack($a1)							# store $a1 to avoid losing it

	# function call
	lw		$a0,	%array_ptr				# load in array_ptr as argument 0
	lw		$a1,	%array_len				# load in array_len as argument 1
	jal printlnArray						# print the array
	
	loadStack($a1)							# restore $a1 to pre-function state
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
	
	loadStack($a0)
.end_macro

# TODO
.macro customSumArray(%array_ptr, %array_len)
	storeStack($a0)							# store $a0 to avoid losing it
	storeStack($a1)							# store $a1 to avoid losing it
	
	# function call
	lw		$a0,	%array_ptr				# load in array pointer as first argument
	lw		$a1,	%array_len				# load in array length as second argument
	jal		sumArray						# call sumArray procedure
	
	loadStack($a1)							# restore $a1 to pre-function state
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

# TODO
.macro customAvgArray(%array_ptr, %array_len)
	customSumArray(%array_ptr, %array_len)	# get the sum of the array
	lw		$t0,	%array_len				# load in its length
	div		$v0,	$v0,	$t0				# sum / length = avg
.end_macro

# TODO
.macro customMaxArray(%array_ptr, %array_len)
	storeStack($a0)							# store $a0 to avoid losing it
	storeStack($a1)							# store $a1 to avoid losing it
	
	# function call
	lw		$a0,	%array_ptr				# load in array pointer as first argument
	lw		$a1,	%array_len				# load in array length as second argument
	jal		maxArray						# call sumArray procedure
	
	loadStack($a1)							# restore $a1 to pre-function state
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

# TODO
.macro customMinArray(%array_ptr, %array_len)
	storeStack($a0)							# store $a0 to avoid losing it
	storeStack($a1)							# store $a1 to avoid losing it
	
	# function call
	lw		$a0,	%array_ptr				# load in array pointer as first argument
	lw		$a1,	%array_len				# load in array length as second argument
	jal		minArray						# call sumArray procedure
	
	loadStack($a1)							# restore $a1 to pre-function state
	loadStack($a0)							# restore $a0 to pre-function state
.end_macro

# TODO
.macro customSortArray(%array_ptr, %array_len)
	storeStack($a0)							# store $a0 to avoid losing it
	storeStack($a1)							# store $a1 to avoid losing it
	
	# function call
	lw		$a0,	%array_ptr				# load in array pointer as first argument
	lw		$a1,	%array_len				# load in array length as second argument
	jal		sortArray						# call sumArray procedure
	
	loadStack($a1)							# restore $a1 to pre-function state
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
.macro customBinarySearch(%array_ptr, %array_len, %target) # no min since when calling, it's 0.
	stargs  # check if can remove this.
	
	# function call
	lw		$a0,	%array_ptr				# set array as array pointer
	li		$a1,	0						# set index min as 0
	lw		$a2,	%array_len
	addi	$a2,	$a2,	-1				# set index max as length - 1
	li		$a3,	%target					# set target as target
	jal		binarySearch					# call function
	
	ldargs  # same as stargs
.end_macro
