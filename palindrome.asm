# check if user provided string is palindrome

.data

userInput: .space 64
stringAsArray: .space 256

welcomeMsg: .asciiz "Enter a string: "
calcLengthMsg: .asciiz "Calculated length: "
newline: .asciiz "\n"
yes: .asciiz "The input is a palindrome!"
no: .asciiz "The input is not a palindrome!"
notEqualMsg: .asciiz "Outputs for loop and recursive versions are not equal"

.text

main:

	li $v0, 4
	la $a0, welcomeMsg
	syscall
	la $a0, userInput
	li $a1, 64
	li $v0, 8
	syscall

	li $v0, 4
	la $a0, userInput
	syscall
	
	# convert the string to array format
	la $a1, stringAsArray
	jal string_to_array
	
	addi $a0, $a1, 0
	
	# calculate string length
	jal get_length
	addi $a1, $v0, 0
	
	li $v0, 4
	la $a0, calcLengthMsg
	syscall
	
	li $v0, 1
	addi $a0, $a1, 0
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	addi $t0, $zero, 0
	addi $t1, $zero, 0
	la $a0, stringAsArray
	
	# Swap a0 and a1
	addi $t0, $a0, 0
	addi $a0, $a1, 0
	addi $a1, $t0, 0
	addi $t0, $zero, 0
	
	# Function call arguments are caller saved
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	
	# check if palindrome with loop
	jal is_pali_loop
	
	# Restore function call arguments
	lw $a0, 4($sp)
	lw $a1, 0($sp)
	addi $sp, $sp, 8
	
	addi $s0, $v0, 0
	
	# check if palindrome with recursive calls
	jal is_pali_recursive
	bne $v0, $s0, not_equal
	
	beq $v0, 0, not_palindrome

	li $v0, 4
	la $a0, yes
	syscall
	j end_program

	not_palindrome:
		li $v0, 4
		la $a0, no
		syscall
		j end_program
	
	not_equal:
		li $v0, 4
		la $a0, notEqualMsg
		syscall
		
	end_program:
	li $v0, 10
	syscall
	
string_to_array:	
	add $t0, $a0, $zero
	add $t1, $a1, $zero
	addi $t2, $a0, 64

	
	to_arr_loop:
		lb $t4, ($t0)
		sw $t4, ($t1)
		
		addi $t0, $t0, 1
		addi $t1, $t1, 4
	
		bne $t0, $t2, to_arr_loop
		
	jr $ra


#################################################
#         DO NOT MODIFY ABOVE THIS LINE         #
#################################################

# returns length in bytes
get_length:
	lb $t0, newline
	addi $t1, $zero, -4 # Serves to point at current address to check
	addi $t3, $zero, 0 # Keep track of length
	loop:
		addi $t3, $t3, 4 # Add 1 to length, this will be 0 initially
		addi $t1, $t1, 4 # Add 4 bytes to proceed to next char
		add $t2, $t1, $a0 # t2 = addr of A[i]
		lw $t2, 0($t2) # t2 = A[i]
		bne $t2, $t0, loop
		addi $v0, $t3, -4
		jr $ra
	
is_pali_loop:
	add $s0, $zero, $a1 # s0 = addr A[0]
	addi $s1, $a0, -4   # |
	add $s1, $a1, $s1   # | -> s1 = addr A[len(A)]
	pali_loop:
		addi $t0, $s1, -1  # redundant, only to check if left <= right using slt
		slt $t0, $s0, $t0 # if left <= right
		beq $t0, $zero, done_pali # if pointers crossed then end loop with positive result
		lw $t0, 0($s0) # get the left pointer value
		lw $t1, 0($s1) # get the right pointer value
		bne $t0, $t1, done_not_pali # if theyre not equal then its not palindrom
		addi $s0, $s0, 4 # advance left pointer
		addi $s1, $s1, -4 # advance right pointer
		j pali_loop 
	
	done_pali:
		addi $v0, $zero, 1 # return 1
		jr $ra # jump back
	
	done_not_pali:
		addi $v0, $zero, 0 # return 0
		jr $ra # jump back
	
is_pali_recursive:
	addi $sp, $sp, -8 # free up the stack to store local variables of previous function
	sw $ra, 0($sp) # store return address
	sw $s0, 4($sp) # store local variable
	jal is_pali_rec # begin the journey down the abyss
	lw $ra, 0($sp) # load return address
	lw $s0, 4($sp) # load local variable
	addi $sp, $sp, 8 # free up the stack
	jr $ra # return
	is_pali_rec:
		addi $sp, $sp, -12 # make space to store first byte in string and last byte in string and ra
		sw $ra, 0($sp) # store ra in the stack
        sw $a0, 4($sp) # store length in stack
        sw $a1, 8($sp) # store address of first char
        
        addi $t0 $zero, 4
		slt $t0, $a0, $t0 # check if length <= 4  | BASE CASE
		bne $t0, $zero, pali_base_case #If True then go to base case

		addi $a0, $a0, -8 # decrease length for next call
		addi $a1, $a1, 4 # increase left pointer for next call
		jal is_pali_rec # If not base case, then do recursive call

		# Restore function paramaters
		lw $s1, 8($sp)
		lw $s0, 4($sp)

        # get address of the char on the right
        add $s0, $s0, $s1
        addi $s0, $s0, -4

        # get the values of the chars at left and right pointers
        lw $s0, 0($s0)
        lw $s1, 0($s1)
        
		slt $t1, $s1, $s0 # if A[left] < A[right]
		slt $t0, $s0, $s1 # if A[right] < A[left]
		or $t2, $t1, $t0 # 0 iff A[right] == A[left]
        lw $ra, 0($sp) # get our return address
		bne $t2, $zero, pali_return_zero # return 0 if the result isnt 0
		
		# No need to update v0 here since we would return 1 and v0 from the previous call
		# 1 and v0 = v0
		addi $sp, $sp, 12 # free up the stack
		jr $ra # Spiderman: I'm coming home

	pali_base_case:
		addi $sp, $sp, 12 # free up the stack
		addi $v0, $zero, 1 # return positive
		jr $ra # Spiderman: Find my way home

	pali_return_zero:
		addi $v0, $zero, 0 # set return value to 0
		addi $sp, $sp, 12 # free up the stack
		jr $ra # Spiderman: I'm coming home


