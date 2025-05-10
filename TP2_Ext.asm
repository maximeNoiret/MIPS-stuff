
.text


j main

# Function power
# Input:
#     $a0: x
#     $a1: n
# Output:
#     $v0: result
# Registers used:
#     $s0: result
#     $t0: i
#     $t1: condition
power:
	addi	$sp,	$sp,	-4				# allocate word in stack
	sw		$s0,	($sp)					# save $s0
	
	#ori		$t0,	$zero,	1				# int i = 1;
	or		$t0,	$zero,	$zero			# int i = 0
	ori		$s0,	$zero,	1				# int result = 1;
	power_l:
	# This instruction was saved by changing the condition from i<=n to i<n
	# since we don't have to check if it's equal anymore
	#beq		$t0,	$a1,	skipLTCheck		# if i == n, skip check to see if not less than
	# LOOP while(i < n) AKA until(i >= n):
	slt		$t1,	$t0,	$a1				# if i < n, $t1 = 1
	beq		$t1,	$zero,	power_el		# if i >= n, exit loop
	skipLTCheck:
	mul		$s0,	$s0,	$a0				# result = result * x;
	addi	$t0,	$t0,	1				# ++i;
	j		power_l							# loop
	power_el:
	or		$v0,	$zero,	$s0				# return result
	
	lw		$s0,	($sp)					# retrieve $s0 from stack
	addi	$sp,	$sp,	4				# deallocate word in stack
	jr		$ra								# return result;

# $s0: x
# $s1: n
main:
	ori		$v0,	$zero,	5				# load syscall code 5 (read int)
	syscall									# read user input
	or		$s0,	$zero,	$v0				# cin >> x;
	ori		$v0,	$zero,	5				# load syscall code 5 (read int)
	syscall									# read user input
	or		$s1,	$zero,	$v0				# cin >> n;
	# function call
	or		$a0,	$zero,	$s0				# set x as power 'x' argument
	or		$a1,	$zero,	$s1				# set n as power 'n' argument
	jal		power							# power(x, n);
	or		$a0,	$zero,	$v0				# move result from function into argument for printing
	ori		$v0,	$zero,	1				# load syscall code 1 (print int)
	syscall									# cout << power(x,n);
	ori		$v0,	$zero,	10				# load syscall code 10 (exit)
	syscall									# return 0;
