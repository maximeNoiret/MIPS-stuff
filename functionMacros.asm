.data
	message: .asciiz ""

.text

# EXIT MACRO
.macro exit
	li		$v0,	10
	syscall
.end_macro

# FUNCTION MACROS
.macro stra
    addi $sp, $sp, -4					# allocate space on stack
    sw $ra, 0($sp)						# store the current return address into stack
.end_macro

.macro ldra
    lw $ra, 0($sp)      				# retrieve correct return address for current recursive level
    addi $sp, $sp, 4					# deallocate space on stack
.end_macro

.macro return
	ldra								# retrieve return address from stack
	jr $ra								# return
.end_macro

.macro stargs
	addi	$sp,	$sp, -16			# allocate 4 slots in stack
	sw		$a0,	0($sp)				# stock $a0
	sw		$a1,	4($sp)				# stock $a1
	sw		$a2,	8($sp)				# stock $a2
	sw		$a3,	12($sp)				# stock $a3
.end_macro

.macro ldargs
	lw		$a0,	0($sp)				# restore $a0
    lw		$a1,	4($sp)				# restore $a1
    lw		$a2,	8($sp)				# restore $a2
    lw		$a3,	12($sp)				# restore $a3
    addi	$sp,	$sp, 16				# deallocate 4 slots in stack
.end_macro

.macro storeStack(%register)
	addi	$sp,	$sp,	-4			# allocate 1 word in stack
	sw		%register,	($sp)			# stock register to stack
.end_macro

.macro loadStack(%register)
	lw		%register,	($sp)			# retrieve register from stack
	addi	$sp,	$sp,	4			# deallocate 1 word in stack
.end_macro

.macro print(%text)
	.data
	__print_str: .asciiz %text			# Yes, this will create an impossible amount of labels. Yes, I don't care.
	.text
	storeStack($a0)
	li		$v0,	4					# load syscall code 4 (print string)
	la		$a0,	__print_str			# load message
	syscall
	loadStack($a0)
.end_macro

.macro printString(%string_ptr)
	storeStack($a0)
	storeStack($v0)
	
	li		$v0,	4
	la		$a0,	%string_ptr
	syscall
	
	loadStack($v0)
	loadStack($a0)
.end_macro

.macro printRegInt(%register)
	storeStack($a0)						# save $a0
	
	move	$a0,	%register			# move value from register to argument
	li		$v0,	1					# load syscall code 1 (print int)
	syscall
	
	loadStack($a0)						# restore $a0
.end_macro

.macro swapReg(%reg1, %reg2)
	move	$t0,	%reg1
	move	%reg1,	%reg2
	move	%reg2,	$t0
.end_macro

.macro swapRam(%reg1, %reg2)
	storeStack($t0)
	storeStack($t1)
	storeStack($t2)
	storeStack($t3)
	
	move	$t0,	%reg1
	lw		$t2,	($t0)
	move	$t1,	%reg2
	lw		$t3,	($t1)
	sw		$t2,	($t1)
	sw		$t3,	($t0)
	
	loadStack($t3)
	loadStack($t2)
	loadStack($t1)
	loadStack($t0)
.end_macro

.macro rand(%min, %max, %rng)
	storeStack($a0)
	
	li		$v0,	41					# load in syscall code 41 (random int)
	lw		$a0,	%rng
	syscall
	andi	$a0,	$a0,	0x7fffffff	# FORCE it to be positive :3
	li		$t0,	%max				# load max in register
	subi	$t0,	$t0,	%min		# subtract min from max
	rem		$v0,	$a0,	$t0			# modulo to (max-min) and store result in $v0 (why tf is it stored in $a0 in the first place??)
	addi	$v0,	$v0,	%min		# add min, result is now %min < $v0 < %max (I think, to test)
	
	loadStack($a0)
.end_macro
