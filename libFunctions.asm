.data
	endl:		.asciiz	"\n"

.text


newline:
	storeStack($a0)
	li		$v0,	4						# load syscall code 4 (print string)
	la		$a0,	endl					# load newline character as argument
	syscall									# print newline
	loadStack($a0)
	jr		$ra								# return