.text
	
# Function power
# Input:
#     $a0: number
#     $a1: power
# Output:
#     $v0: result
# Registers used:
#     $t0: $a1 % 2
# Note:
#     Complexity of O(log2(n)), aka logarithmic, aka good, much better than the other one
power:
	addi	$sp,	$sp,	-8		# allocate 2 words in stack (don't save $a0 since never modified)
	sw		$ra,	4($sp)			# store return address for recursion
	sw		$a1,	($sp)			# store power argument
	# if $a1 == 1, return $a0
	bne		$a1,	1,	notOne
	or		$v0,	$zero,	$a0
	lw		$ra,	4($sp)			# retrieve current return address
	addi	$sp,	$sp,	8		# deallocate 2 words in stack
	jr		$ra						# return $a0
	# else,
	notOne:
	andi	$t0,	$a1,	1		# get $a1 modulo 2 to know if it's even or odd
	bnez	$t0,	odd				# if the power is even,
	srl		$a1,	$a1,	1		# get $a1 / 2
	jal		power					# z = power(x, n/2)
	mul		$v0,	$v0,	$v0		# multiply the result by itself (z*z)
	lw		$a1,	($sp)			# retreive previous power argument
	lw		$ra,	4($sp)			# retrieve current return address
	addi	$sp,	$sp,	8		# deallocate 2 words in stack
	jr		$ra						# return z * z
	# else, if the power is odd,
	odd:
	addi	$a1,	$a1,	-1		# get $a1 - 1
	srl		$a1,	$a1,	1		# get ($a1 - 1) / 2
	jal		power					# z = power(x, (n-1)/2)
	mul		$v0,	$v0,	$v0		# z * z
	mul		$v0,	$a0,	$v0		# then by the number, so basically x * (z * z)
	lw		$a1,	($sp)			# retreive previous power argument
	lw		$ra,	4($sp)			# retrieve current return address
	addi	$sp,	$sp,	8		# deallocate 2 words in stack
	jr		$ra						# return x * z * z


# Function dumbPower
# Input:
#     $a0: number
#     $a1: power
# Output:
#     $v0: result
# Registers used:
#     None	
# Note:
#     Has complexity of O(n). Do not use. Only for educational purposes. Instead use power (Olog2(n))
dumbPower:
	addi	$sp,	$sp,	-4		# allocate a word in stack
	sw		$ra,	($sp)
	
	# if $a1 == 1, return $a0
	bne		$a1,	1,	notOneDumb
	or		$v0,	$zero,	$a0
	lw		$ra,	($sp)
	addi	$sp,	$sp,	4
	jr		$ra
	# else, return $a0 * dumbPower($a0, $a1 - 1)
	notOneDumb:
	addi	$a1,	$a1,	-1
	jal		dumbPower
	mul		$v0,	$v0,	$a0

	lw		$ra,	($sp)
	addi	$sp,	$sp,	4
	jr		$ra
