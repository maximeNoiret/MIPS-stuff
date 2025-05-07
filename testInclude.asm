.data
	array0_ptr: .word 0
	array0_len: .word 0
	array0_cap: .word 0
	array1_ptr: .word 0
	array1_len: .word 0
	array1_cap: .word 0
	
	comma:		.asciiz	", "

.text
.include "functionMacros.asm"
.include "macroArrays.asm"

# WELCOME to stack abuse simulator :3

arrayTest:
	print("This program was made to test out dynamic arrays, .include, parametered macros and saving registers.\n")
	jal		initArray
	
	loop:
	customAppend(1337, array0_ptr)
	printRegInt($v0)
	jal newline
	j loop
	
	customPrintlnArray(array1_ptr)
	
	li		$a0,	13					 # write 13 to $a0
	print("Wrote 13 to $a0\n")
	
	print("Current value of $a0: ")
	jal print_int
	jal newline
	
	print("Adding an element to array1, no reallocation needed. (2/5) -> (3/5)\n")
	customAppend(13, array1_ptr)
	customPrintlnArray(array1_ptr)
	
	print("Now adding an element to array0, reallocation needed! (5/5) -> (6/10)\n")
	customAppend(216, array0_ptr)
	customPrintlnArray(array0_ptr)
	
	print("The sum of this last array is: ")
	customSumArray(array0_ptr)
	printRegInt($v0)
	jal newline
	
	print("The average of this last array is: ")
	customAvgArray(array0_ptr)
	printRegInt($v0)
	jal newline
	
	print("The max of this last array is: ")
	customMaxArray(array0_ptr)
	printRegInt($v0)
	jal newline
	
	print("The min of this last array is: ")
	customMinArray(array0_ptr)
	printRegInt($v0)
	jal newline
	
	#print("The median of this last array is: ")
	#customMedianArray(array0_ptr, array0_len)
	#printRegInt($v0)
	#jal newline
	
	print("As you can see, the median isn't the average of the two middles. Oh well! :3\nJust add a new element lmao\n")
	customAppend(257, array0_ptr)
	customPrintlnArray(array0_ptr)
	
	#print("The median of this last array is: ")
	#customMedianArray(array0_ptr, array0_len)
	#printRegInt($v0)
	#jal newline
	
	#print("Sorting the array...\n")
	#customSortArray(array0_ptr)
	#print("Sorted array: ")
	#customPrintlnArray(array0_ptr)
	
	print("The array being sorted, we can do a binary search on it.\nIndex of 80: ")
	customBinarySearch(array0_ptr, 80)
	printRegInt($v0)
	printString(comma)
	printRegInt($v1)
	jal newline
	
	print("The binary search works! But what if the element isn't here...?\nIndex of 42: ")
	customBinarySearch(array0_ptr, 42)
	printRegInt($v0)
	printString(comma)
	printRegInt($v1)
	jal newline
	print("We see it's -1, the return value when not found. Same for $v1, which is 0 when found, and -1 when not\n")
	
	print("Current value of $a0: ")
	jal print_int
	jal newline
	print("We can see that $a0 was conserved out of all of the functions :3\n")
	exit


initArray:
	stra
	# creation of arrays
	createArray(5, array0_ptr) # init array0
	createArray(5, array1_ptr) # init array1
	
	# elements insertion
	init_element(array0_ptr, 0, 3)		# write 3 to array0[0]
	init_element(array0_ptr, 4, 5)		# write 7 to array0[1]
	init_element(array0_ptr, 8, 19)	# write 2 to array0[2]
	init_element(array0_ptr, 12, 80)	# write 8 to array0[3]
	init_element(array0_ptr, 16, 200)		# write 5 to array0[4]
	set_length(5, array0_ptr)			# set length to 5
	
	init_element(array1_ptr, 0, 8)		# write 8 to array1[0]
	init_element(array1_ptr, 4, 14)		# write 14 to array1[1]
	set_length(2, array1_ptr)			# set length to 2
	return

.include "libFunctions.asm"
.include "libArray.asm"
