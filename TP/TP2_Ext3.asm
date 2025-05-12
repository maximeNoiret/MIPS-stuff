# the other functions are not globl since in anonymous namespace (I think lmao I dunno)
.globl main


.data
	TailleT:	.word	10 			# PS: There are 10 elements, not 9?
	T: 			.word	1, 3, 5, 2, 9, 8, 6, 4, 7, 0
	newline:	.asciiz	"\n"
	printT:		.asciiz "T : "
	printSpace:	.asciiz	"  "

.text

j main

# Function AfficherTableau
# Input:
#     $a0: T[]
#     $a1: N
# Output:
#     None (array is printed to screen)
# Registers used:
#     $s0: T[] ($a0 is used by printing, so have a copy)
#     $t0: i
#     $t1: loop condition
#          AND THEN offset -> pointer -> element of T[i]
# Note:
#     Are we REALLY supposed to reproduce setw() in MIPS?????
AfficherTableau:
	addi	$sp,	$sp,	-4						# allocate word in stack
	sw		$s0,	($sp)							# save $s0 in stack
	
	or		$s0,	$zero,	$a0						# save T[] against printing
	
	ori		$v0,	$zero,	4						# load syscall code 4 (print string)
	la		$a0,	printT							# load "T : " as argument
	syscall											# cout << "T : ";
	or		$t0,	$zero,	$zero					# unsigned i = 0;
	AfficherTableau_l:
	slt		$t1,	$t0,	$a1						# if i < N, $t1 = 1
	beq		$t1,	$zero,	AfficherTableau_el		# while (i < N) AKA until !(i < N)
	sll		$t1,	$t0,	2						# i * 4 to get offset
	add		$t1,	$t1,	$s0						# add array base to get pointer
	lw		$a0,	($t1)							# get T[i]
	ori		$v0,	$zero,	1						# load syscall code 1 (print int)
	syscall											# print(T[i])
	ori		$v0,	$zero,	4						# load syscall code 4 (print string)
	la		$a0,	printSpace						# load two spaces as argument
	syscall											# print("  "), this is setw(3) lol
	addi	$t0,	$t0,	1						# ++i
	j		AfficherTableau_l
	AfficherTableau_el:
	ori		$v0,	$zero,	4						# load syscall code 4 (print string)
	la		$a0,	newline							# load newline as arg
	syscall											# print("\n")
	
	or		$a0,	$zero,	$s0						# restore argument
	
	lw		$s0,	($sp)							# restore $s0 from stack
	addi	$sp,	$sp,	4						# deallocate word from stack
	jr		$ra										# return



# Function Swap
# Input:
#     $a0: T[]
#     $a1: k (index to swap with following one)
# Output:
#     None (T[k] and T[k+1] get swapped)
# Registers used:
#     $t0: Address of T[k]
#     $t1: T[k], aka Temp
#     $t2: T[k+1]
Swap:
	sll		$t0,	$a1,	2						# k * 4 to get offset
	add		$t0,	$t0,	$a0						# add array base to get pointer
	lw		$t1,	($t0)							# get T[k]
	lw		$t2,	4($t0)							# get T[k+1]
	sw		$t1,	4($t0)							# load T[k] into T[k+1]
	sw		$t2,	($t0)							# load T[k+1] into T[k]


# Function Sort
# Input:
#     $a0: T[]
#     $a1: N
# Output:
#     None (T[] gets sorted)
# Registers used:
#     $s0: i
#     $s1: j
#     $t0: i < N condition
#          AND THEN j < 0 condition
#          AND THEN address of T[j]
#          AND THEN T[j] < T[j+1] condition
#     $t1: T[j]
#     $t2: T[j+1]
Sort:
	# Non-terminal function register conservation
	addi	$sp,	$sp,	-20						# allocate 5 words in stack
	sw		$ra,	16($sp)							# save return address in stack
	sw		$a0,	12($sp)							# save $a0 in stack
	sw		$a1,	8($sp)							# save $a1 in stack
	sw		$s0,	4($sp)							# save $s0 in stack since used
	sw		$s1,	($sp)							# save $s1 in stack since used
	
	ori		$s0,	$zero,	1						# unsigned i = 1
	Sort_l0:
		slt		$t0,	$s0,	$a1					# if i < N, $t0 = 1
		beq		$t0,	$zero,	Sort_el0			# while (i<N) aka until !(i<N)
		add		$s1,	$s0,	-1					# unsigned j = i - 1
		Sort_l1:
		# while ((j>=0) && (T[j] > T[j+1]))
			slt		$t0,	$s1,	$zero			# if j < 0: $t0 = 1
			bne		$t0,	$zero,	Sort_el1		# while (j>=0) AKA until (j<0)
			sll		$t0,	$s1,	2				# get j * 4 to become offset
			add		$t0,	$t0,	$a0				# add array base to become address
			lw		$t1,	($t0)					# get T[j]
			lw		$t2,	4($t0)					# get T[j+1]
			# while !(T[j] <= T[j+1])   PS: is there a better way for gt?
			beq		$t1,	$t2,	Sort_el1		# while (T[j] != T[j+1] && ...
			slt		$t0,	$t1,	$t2				#   if T[j] < T[j+1], $t0 = 1
			bne		$t0,	$zero,	Sort_el1		# ... T[j] !< T[j+1])
			or		$a1,	$zero,	$s1				# set j as argument $a1 for Swap
			jal		Swap							# Swap(T, j);
			lw		$a1,	8($sp)					# restore N as $a1 from stack (might be bad memory ethics?? maybe consider using an $s register?)
			addi	$s1,	$s1,	-1				# --j
			j		Sort_l1
		Sort_el1:
		addi	$s0,	$s0,	1					# ++i
		j		Sort_l0
	Sort_el0:
	
	lw		$s1,	($sp)							# restore $s1 from stack since used
	lw		$s0,	4($sp)							# restore $s0 from stack since used
	lw		$a1,	8($sp)							# restore $a1 from stack
	lw		$a0,	12($sp)							# restore $a0 from stack
	lw		$ra,	16($sp)							# restore return address from stack
	addi	$sp,	$sp,	20						# deallocate 5 words in stack
	jr		$ra										# return


main:
	la		$a0,	T								# load T as arg
	la		$a1,	TailleT							# get TailleT address
	lw		$a1,	($a1)							# load TailleT as arg
	jal		AfficherTableau							# AfficherTableau(T, TailleT);
	jal		Sort									# Sort(T, TailleT);
	jal		AfficherTableau							# AfficherTableau(T,TailleT);
	
	ori		$v0,	$zero,	10						# load syscall code 10 (exit)
	syscall											# return 0;
