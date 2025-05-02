.data
    prompt: .asciiz "Enter a number to count down from: "
    error: .asciiz "Incorrect input. Should be a number!\n"

.text
# EXIT MACRO
.macro exit
li $v0, 10									# load syscall code 10 (exit)
syscall
.end_macro
# STACK MACROS (for recusivity)
.macro stra
    addi $sp, $sp, -4						# allocate space on stack
    sw $ra, 0($sp)							# store the current return address into stack
.end_macro

.macro ldra
    lw $ra, 0($sp)      					# retrieve correct return address for current recursive level
    addi $sp, $sp, 4						# deallocate space on stack
.end_macro

.macro return
	ldra									# retrieve return address from stack
	jr $ra									# return
.end_macro

main:
    jal get_user_int						# get user input as int
    move $s0, $a0							# store user input is $s0
    loop:
        bltz $s0, end_loop					# while ($s0 >= 0)  {
        jal println_s0_int					#   print($s0)
        addi $s0, $s0, -1					#   --$s0
        j loop								# }
    end_loop:
    exit


# FUNCTIONS
# print value of $t9 as an int
println_s0_int:
stra										# store current return addr to stack
li $v0, 1									# load syscall code 1 (print int)
move $a0, $s0								# load $s0 as first argument
syscall										# print
jal newline									# print a newline
return

newline:
stra										# store current return addr to stack
li $v0, 11									# load syscall code 11 (print ascii)
li $a0, 10									# load newline ascii character
syscall										# print a newline
return

get_user_int:
stra										# store return address
user_int_loop:
    li $v0, 51								# load syscall code 51 (InputDialogInt)
    la $a0, prompt							# load prompt as argument
    syscall
    beq $a1, 0, user_int_loop_end			# if return status is 0, exit loop. else,
    li $v0, 55								# load syscall code 55 (MessageDialog)
    la $a0, error							# load error prompt as first argument
    li $a1, 0								# load 0 as second argument (error message)
    syscall
    j user_int_loop
user_int_loop_end:
return										# return user input as int
# END FUNCTIONS
