.data

inMsg: .asciiz "Enter a number: "
msg: .asciiz "Calculating F(n) for n = "
fibNum: .asciiz "\nF(n) is: "
.text

main:

	li $v0, 4
	la $a0, inMsg
	syscall

	# take input from user
	li $v0, 5
	syscall
	addi $a0, $v0, 0
	
	jal print_and_run
	
	# exit
	li $v0, 10
	syscall

print_and_run:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	add $t0, $a0, $0 

	# print message
	li $v0, 4
	la $a0, msg
	syscall

	# take input and print to screen
	add $a0, $t0, $0
	li $v0, 1
	syscall

	jal fib

	addi $a1, $v0, 0
	li $v0, 4
	la $a0, fibNum
	syscall

	li $v0, 1
	addi $a0, $a1, 0
	syscall
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

#################################################
#         DO NOT MODIFY ABOVE THIS LINE         #
#################################################	

# value is in a0
# return value will be in v0	
fib: 
	# Make space for return addrees, argument and 
	# return value from first recursive call
	addi $sp, $sp, -12
	sw $ra, 0($sp)

	# Check if argument is less than or equal to 1
	# if it is jump to label base_case
	li $t0, 2
	slt $t0, $a0, $t0
	bne $t0, $zero, base_case

	# otherwise we will do a recurisve call
	# first we will store our argument in s0
	addi $s0, $a0, 0
	sw $s0, 4($sp) # store our argument in the stack to not lose it after first recurisve call

	# Then we set the argument to our call value n-1
	# and then do the recursive call fib(n-1)
	addi $a0, $s0, -1
	jal fib

	sw $v0, 8($sp) # Store return value from first recursive call

	# never forget to get our argument back :)
	lw $s0, 4($sp)

	# Then we set the argument to our call value n-2
	# and then do the recursive call fib(n-2)
	addi $a0, $s0, -2
	jal fib

	# load the first recursive call return value back
	# and then add them together and store as return var.
	lw $s1, 8($sp)
	add $v0, $v0, $s1

	#Free the stack and return back
	#First retrieve the return address
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	jr $ra

base_case:
	# set our return val
	addi $v0, $a0, 0
	# free the stack
	addi $sp, $sp, 12

	# JUMMMPPPPP UPPPPP FINALLYYY
	jr $ra



