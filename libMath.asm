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
	stra
	# if $a1 == 1, return $a0
	bne		$a1,	1,	notOne
	move	$v0,	$a0
	return
	# else,
	notOne:
	andi	$t0,	$a1,	1		# get $a1 modulo 2 to know if it's even or odd
	bnez	$t0,	odd				# if the power is even,
	srl		$a1,	$a1,	1		# get $a1 / 2
	jal		power					# z = power(x, n/2)
	mul		$v0,	$v0,	$v0		# multiply the result by itself
	return							# return z * z
	# else, if the power is odd,
	odd:
	addi	$a1,	$a1,	-1		# get $a1 - 1
	srl		$a1,	$a1,	1		# get ($a1 - 1) / 2
	jal		power					# z = power(x, (n-1)/2)
	mul		$v0,	$v0,	$v0		# z * z
	mul		$v0,	$a0,	$v0		# then by the number, so basically x * (z * z)
	return							# return x * z * z


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
	stra
	
	# if $a1 == 1, return $a0
	bne		$a1,	1,	notOneDumb
	move	$v0,	$a0
	return
	# else, return $a0 * dumbPower($a0, $a1 - 1)
	notOneDumb:
	addi	$a1,	$a1,	-1
	jal		dumbPower
	mul		$v0,	$v0,	$a0

	return
