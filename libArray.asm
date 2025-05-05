.data
	space:		.asciiz	" "

.text

# Function printlnArray
# Input:
#     $a0: array
# Output:
#     None
# Registers used:
#     $t0: current index
#     $t1: current address
#     $t2: array length
printlnArray:
	stra
	li		$t0,	0						# initialize index
	addi	$t1,	$a0,	8				# initialize current address to first array element
	lw		$t2,	($a0)					# load array length into $t2
	storeStack($a0)							# save argument
	printArray_l:
	beq		$t0,	$t2,	printArray_el	# while (index != length) {
	lw		$a0,	($t1)					#   $a0 = array[index]
	jal print_int							#   print($a0 + " ")
	addi	$t0,	$t0,	1				#   ++index
	addi	$t1,	$t1,	4				#   next array element
	j		printArray_l					# }
	printArray_el:
	jal newline								# go to next line
	loadStack($a0)							# restore argument
	return


# Function print_int
# Input:
#     $a0: int to print
# Output:
#     None
# Registers used:
#     None
print_int:
	storeStack($a0)
	li		$v0,	1						# load syscall code 1 (print int)
	syscall									# print argument
	li		$v0,	4						# load syscall code 4 (print string)
	la		$a0,	space					# set space character as argument
	syscall									# print a space
	loadStack($a0)
	jr		$ra								# return


# Function sumArray
# Input:
#     $a0: base of array to sum up
# Output:
#     $v0: sum of the array
# Registers used:
#     $t0: current element
#     $t1: array length
sumArray:
	# save argument registers (note: might remove these. It would cause the function to corrupt arg regs, but the macro handles it)
	storeStack($a0)							# store $a0 to avoid losing it
	lw		$t1,	($a0)					# load array length
	addi	$t1,	$t1,	-1				# length - 1 to get last item
	li		$v0,	0						# init result at 0
	li		$t0,	0						# init index at 0
	addi	$a0,	$a0,	8				# skip meta data
	sumArray_l:
		bltz	$t1,	sumArray_el			# while (index >= 0) {
		lw		$t0,	($a0)				#   $t0 = elem
		add		$v0,	$v0,	$t0			#   $v0 += $t0
		addi	$a0,	$a0,	4			#   next elem
		addi	$t1,	$t1,	-1			#   --index
		j		sumArray_l					# }
	sumArray_el:
	loadStack($a0)							# restore $a0 to before function
	jr		$ra								# return



# Function maxArray
# Input:
#     $a0: base of array
# Output:
#     $v0: max of the array
# Registers used:
#     $t0: current element
#     $t1: array length
maxArray:
	# save argument registers (note: might remove these. It would cause the function to corrupt arg regs, but the macro handles it)
	storeStack($a0)							# store $a0 to avoid losing it
	lw		$t1,	($a0)					# get length
	addi	$t1,	$t1,	-1				# length - 1 to get last item
	li		$v0,	0						# init result at 0
	li		$t0,	0						# init index at 0
	addi	$a0,	$a0,	8				# skip meta data
	maxArray_l:
		bltz	$t1,	maxArray_el			# while (index >= 0) {
		lw		$t0,	($a0)				#   $t0 = elem
		bge		$v0,	$t0,	max_false	#   if ($v0 < $t0) {
		move	$v0,	$t0					#     $v0 = $t0
		max_false:							#   }
		addi	$a0,	$a0,	4			#   next elem
		addi	$t1,	$t1,	-1			#   --index
		j		maxArray_l					# }
	maxArray_el:
	loadStack($a0)							# restore $a0 to before function
	jr		$ra								# return
	
	
# Function minArray
# Input:
#     $a0: base of array
# Output:
#     $v0: min of the array
# Registers used:
#     $t0: current element
#     $t1: array length
# Note:
#     FIXME: kinda dumb to have a whole copy of maxArray just to change ONE letter (bge -> ble) lol
#         nvm, we also set $v0 at max signed integer and not 0
minArray:
	# save argument registers (note: might remove these. It would cause the function to corrupt arg regs, but the macro handles it)
	storeStack($a0)							# store $a0 to avoid losing it
	lw		$t1,	($a0)					# get length
	addi	$t1,	$t1,	-1				# length - 1 to get last item
	li		$v0,	0x7fffffff				# init result at max signed integer
	li		$t0,	0						# init index at 0
	minArray_l:
		blt		$t1,	2,	minArray_el		# while (index >= 2) { 2 because of meta data
		lw		$t0,	($a0)				#   $t0 = elem
		ble		$v0,	$t0,	min_false	#   if ($v0 > $t0) {
		move	$v0,	$t0					#     $v0 = $t0
		min_false:							#   }
		addi	$a0,	$a0,	4			#   next elem
		addi	$t1,	$t1,	-1			#   --index
		j		minArray_l					# }
	minArray_el:
	loadStack($a0)							# restore $a0 to before function
	jr		$ra								# return



# Functon realloc (basically just sbrk syscall lmao)
# Input:
#     $a0: number of slots to allocate
# Output:
#     $v0: address of allocated memory
realloc:
	sll		$a0,	$a0,	2				# transform slots into bytes
	li		$v0,	9						# load syscall code 9 (sbrk/allocate heap memory)
	syscall
	jr $ra


# Function moveArray
# Input:
#     $a0: newArray base
#     $a1: oldArray base
# Output:
#     None
# Registers used:
#     $t0: current index
#     $t1: current oldAddress
#     $t2: current element
#     $t3: current newAddress
#     $t4: oldArray capacity
moveArray:
	li 		$t0,	0						# initialize index
	move	$t1,	$a1						# initialize current oldAddress
	move	$t3,	$a0						# initialize current newAddress
	lw		$t4,	($a1)					# initialize old array capacity
	addi	$t4,	$t4,	2				# add 2 to capacity for meta data
	moveArray_l:
	beq		$t0,	$t4,	moveArray_el	# while (index != oldArray capacity) {
	lw		$t2,	($t1)					#   $t2 = oldArray[index]
	sw		$t2,	($t3)					#   newArray[index] = $t2
	addi	$t0,	$t0,	1				#   ++index
	addi	$t1,	$t1,	4				#   next oldAddress
	addi	$t3,	$t3,	4				#   next newAddress
	j		moveArray_l						# }
	moveArray_el:
	jr		$ra								# return
	

# Function append
# Input:
#     $a0: array
#     $a1: element (word)
# Output:
#     $v0: 0 if no realloc, 1 if realloc occured
#     $a0: becomes new array base in case of realloc
#     $a2: becomes new array length
#     $a3: becomes new array capacity in case of realloc
#     Yes, argument registers are being modified. However, as someone said:
#         "If C (a language obsessed with safety) does it, you’re fine."
# Registers used:
#     $t0: array length
#     $t1: array capacity
append:
	stra
	li		$v0,	0						# default $v0 at 0
	lw		$t0,	($a0)					# load in array length
	lw		$t1,	4($a0)					# load in array capacity
	# check if array full
	bne		$t0,	$t1,	skip_realloc	# if not equal, means free space, therefore skip realloc
	
	# if full, reallocate double the space in heap
	sll		$t1,	$t1,	1				# double capacity
	sw		$t1,	4($a0)					# update capacity in array meta data
	addi	$t1,	$t1,	2				# add 2 slots for metadata during realloc
	storeStack($a0)							# save old array base to stack
	move	$a0,	$t1						# load amount of capacity as argument for realloc
	jal realloc								# realloc space in heap for new array
	move	$a0,	$v0						# update array base
	storeStack($a1)							# save $a1
	lw		$a1,	4($sp)					# load old array base as oldArray base argument
	jal 	moveArray						# move array content from old heap location to new one
	lw		$a1,	($sp)					# restore $a1
	addi	$sp,	$sp,	8				# deallocate 2 word on stack
											# we deallocate 2 words because we stocked $a0 earlier
	li		$v0,	1						# set $v0 as 1 since realloc has occured
	# FIXME: no freeing of old memory. HUGE MEMORY LEAKS POTENTIAL :3
	# TODO: find some way to free memory (tho doesn't appear to be one in MIPS...)
	
	# add element to end of array
	skip_realloc:
	lw		$t0,	($a0)					# get length
	addi	$t0,	$t0,	1				# add 1 to length (since we're adding an element)
	sw		$t0,	($a0)					# store change in length
	sll		$t0,	$t0,	2				# multiply length by 4 to become an offset
	addi	$t0,	$t0,	4				# add 2 to skip meta data + remove one to be at end of elements
	add		$t0,	$t0,	$a0				# add offset to array base
	sw		$a1,	($t0)					# store element in array
	return


# Function sortArray
# Input:
#     $a0: array base
#     $a1: array length
# Output:
#     None
# Registers used:
#     $t0: i
#     $t1: j					Note: might be able to save this register by checking [j] == $a0 instead of j == 0
#     $t3: j offset -> A[j]
#     $t4: A[j-1]
#     $t5: A[j] element
#     $t6: A[j-1] element
# Note:
#     Original array is sorted.
#     TODO: Shift every register number down by 1 after $t1
#     TODO: Find a way to use less registers maybe
sortArray:
	stra
	li		$t0,	1						# i = 1
	sortArray_l0:
	beq		$t0,	$a1,	sortArray_el0	# while (i < $a1) {
	move	$t1,	$t0						#   j = i
	sortArray_l1:							#   while (j > 0 && $a0[j-1] > $a0[j])
	beqz	$t1,	sortArray_el1			#   check if j == 0
	sll		$t3,	$t1,	2				#   (j ofst) = j * 4
	add		$t3,	$t3,	$a0				#   A[j] = (j ofst) + $a0
	addi	$t4,	$t3,	-4				#   A[j-1]
	lw		$t5,	($t3)					#   $a0[$t3]
	lw		$t6,	($t4)					#   $a0[$t4]
											#   while (j > 0 &&
	ble		$t6,	$t5,	sortArray_el1	#          $a0[j-1] > $a0[j]) {
	swapRam($t3, $t4)						#     swap A[j] and A[j-1]
	addi	$t1,	$t1,	-1				#     --j
	j		sortArray_l1					#   }
	sortArray_el1:
	addi	$t0,	$t0,	1				#   ++i
	j		sortArray_l0					# }
	sortArray_el0:
	return



# Function medianArray
# Input:
#     $a0: array
#     $a1: array_len
# Output:
#     $v0: array median
# Registers used:
#     $t0: $a1 % 8
# Notes:
#     This function is VERY BADLY written (it was written during a math class leave me alone)
#     TODO: obviously, fix it so it's not bad lmao
medianArray:
	stra
	
	# we store our arguments in the stack to retrieve them later
	storeStack($a0)
	storeStack($a1)
	storeStack($a2)
	
	# stock array in stack (because no free() for heap)
	sll		$a2,	$a1,	2				# get array size in bytes
	sub		$sp,	$sp,	$a2				# allocate this much in stack
	move	$a2,	$a1						# set array_cap argument as array length (no need for cap)
	move	$a1,	$a0						# set array pointer as oldArray argument
	move	$a0,	$sp						# set stack pointer as new array position argument
	jal		moveArray						# call moveArray procedure
	# The stack pointer is now technically the base of our temp array
	# Therefore, we can now use that as argument for sortArray
	# reminder, $a2 is now array length and $sp is now array base
	move	$a0,	$sp						# set new array base as argument (array base being stack pointer)
	move	$a1,	$a2						# set array length as argument
	jal		sortArray						# sort the array
	# The array is now sorted.
	# Now, all we have to do is get the element at array_len / 2
	# reminder that now, array length is $a1, though $a2 also has the same value (maybe an optimization possible here?)
	# and, $a0 is array base, though $sp also is
	sll		$a1,	$a1,	2				# length * 4 = size in bytes of array
	move	$a2,	$a1						# set $a2 as size in bytes of array for later
	rem		$t0,	$a1,	8				# get $a1 % 8
	beqz	$t0,	isAligned				# if $a1 % 8 != 0 (aka if it's won't be aligned after dividing by 2),
	addi	$a1,	$a1,	-4				# remove 4 from it
	isAligned:
	srl		$a1,	$a1,	1				# size in bytes of array / 2 = offset to middle element of array (I think, to test)
	add		$a1,	$a1,	$a0				# array base + offset to middle = address of median
	lw		$v0,	($a1)					# load the median with its address
	add		$sp,	$sp,	$a2				# deallocate size in bytes of the array in stack
	
	# the stack being back at the correct position now, we can reload our arguments
	loadStack($a2)
	loadStack($a1)
	loadStack($a0)
	
	return     
	
	
# Function binarySearch
# Input:
#     $a0: array base
#     $a1: index min
#     $a2: index max
#     $a3: target
# Output:
#     $v0: index of target, -1 if not found or if incorrect arguments
#     $v1: return code (0 = found, 1 = not found, -1 = incorrect arguments, -2 = Wake up. Wake up. Wake up.)
# Registers used:
#     $t0: index mid
#     $t1: offset mid ($t0 * 4) -> address mid ([($t1)]) -> middle element (array[($t1)])
binarySearch:
	stra
	
	ble		$a1,	$a2,	a1lea2			# if $a1 > $a2, return -1
	li		$v0,	-1						# return index 0
	li		$v1,	-1						# return code -1
	return
	
	a1lea2:
	bne		$a1,	$a2,	a1nea2			# if $a1 = $2...
	move	$t0,	$a1						# move min index to result in case it's correct
	sll		$t1,	$a1,	2				# make the index as an offset
	add		$t1,	$t1,	$a0				# add array base to make it a pointer
	lw		$t1,	($t1)					# load the element pointed at
	beq		$t1,	$a3		found			# ...AND array[($a1)] != target, return index -1 and code -1
	li		$v0,	-1						# set both $v0 and $v1 at -1
	move	$v1,	$v0
	return
		
	a1nea2:
	# get middle index
	sub		$t0,	$a2,	$a1				# get max - min
	srl		$t0,	$t0,	1				# divide that by 2
	add		$t0,	$t0,	$a1				# add that to min to get min + (diff/2), aka the middle point of min and max
	# since it's an index (and not an offset), there is no way it can be misaligned to words.
	# get middle offset
	sll		$t1,	$t0,	2				# multiply middle index by 4 to become offset
	# get middle pointer
	add		$t1,	$t1,	$a0				# we then add onto that the base of the array to become a pointer
	lw		$t1,	($t1)					# then we read the value in this pointer to get the middle element
	
	# we can now begin the conditions:
	bne		$t1,	$a3,	notEqual		# if array[($t1)] = target, return $t0
	found:
	move	$v0,	$t0						# return value the index
	li		$v1,	0						# return code 0 since it was found
	return
	notEqual:
	bgt		$t1,	$a3,	notLess			# if array[($t1)] < target, binarySearch($a0, $a1, $t0 - 1, target)
	storeStack($a1)							# store the argument to restore it when exiting the function
	addi	$a1,	$t0,	1				# set (mid index + 1) as min for next level
	jal		binarySearch					# every other arguments are the same, recall function
	loadStack($a1)							# restore previous argument
	return
	notLess:
	blt		$t1,	$a3,	wtf				# if array[($t1)] > target, binarySearch($a0, $t0 + 1, $a2, target)
	storeStack($a2)							# store the argument to restore it when exiting function
	addi	$a2,	$t0,	-1				# set (mid index - 1) as max for next level
	jal		binarySearch					# every other arguments are the same, recall function
	loadStack($a2)							# once coming out of the recursion, restore previous argument
	return
	# if none are true, something in the universe broke.
	# Set return code as -2 and exit entire program.
	wtf:
	li		$v1,	-2
	exit
	
