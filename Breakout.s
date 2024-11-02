    .text
    .globl _start 
    

_start:
   la t0, starting_sentence #Prints the greeting
   la t1, next_sentence    #Print the following lines which tell the user how to start the program and how to move the paddle
   li t3, 0x10000000 
   li t5, 18
   li s0, 1
print_start:			#This label prints out the first sentence 
	lb t2, 0(t0)
	beq t5, zero, next_load
	sb t2, 0(t3)
	addi t0, t0, 1
	addi t5, t5, -1
	j print_start
	
next_load: li t5, 68
next: 			#Prints out the following lines stored in next_sentence
	lb t4, 0(t1)
	beq t5, zero, button
	sb t4, 0(t3)
	addi t1, t1, 1
	addi t5, t5, -1
	j next

button:				#This keeps looping until the user presses a key on the keyboard  
	li t0, 0x10000005 
	li s1, 1
	lb t1, 0(t0)
	and s1, s1, t1
	beq s1, s0, start_game
	j button

    
start_game:
   la t0, pic 
   li t1, 0xffff8000
   li a3, 0xffff8000
   li s0, 16
   li s10, 0
   li s9, 1
   li s2, 31
   li a0, 16  
   li a1, 26 
   li a6, 0     #Score
   	      
   li s10, 1
   slli s10, s10, 29
print:				#Prints the row of pixels at the middle of the screen 
    addi t1, t1, 56
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t1, t1, 40   
    addi a3, a3, 124
    j print_paddle		#Jumps to the label which prints the paddle
    continue:
    li t3, 1
    sll t3, t3, a0
    
    lw t2, 0(t1)
    or t2, t2, t3
    sw t2, 0(t1)
    
    li t2, 0x00000000
    and t2, t2, t3
    sw t2, 0(t1)
    addi a1, a1, -1
    
right_up_offset:		#If the ball hits the right most edge of the paddle it offests the ball's x position by 2 
	li t2, -3
	add t2, a0, t2
	ble t2, zero, right_up
	addi a0, a0, -2
	    
right_up: 			#Moves the ball right diagonally up the screen 

	li t2, 0x00000000
    	and t2, t2, t3
    	sw t2, 0(t1)
	li a2, 0
	beq a1, s0, rem_pixel_checkr		#If the ball hits the top of the screen it jumps to a label to see if the ball hit a pixel
	beq a1, s0, right_down			#Once the ball reaches the top of the screen it goes down right diagonally
	beq a0, zero, left_up 			#If the ball hits the edge of the screen going up, it still goes up but goes up left diagonally
	
	addi t1, t1, -4
	
	addi a1, a1, -1
	li t3, 1
	addi a0, a0, -1
	sll t3, t3, a0
	lw t2, 0(t1)
	or t2, t2, t3
	sw t2, 0(t1)
	
	
	j moving				#Jumps to the label that checks if the paddle needs to be moved 
	move_back_right_up:
	j right_up			
	
right_down: 			#Moves the ball right diagonally down the screen

	li t2, 0x00000000
    	and t2, t2, t3
    	sw t2, 0(t1)
	
	li a2, 1
	beq a1, s2, check_if_over_right		#If the ball hits the bottom of the screen then it jumps to this label which checks whether the paddle was underneath the ball or if the game ends
	right_down_continue:
	beq a1, s2, right_up			#If the ball hits the bottom and hits the paddle then it starts heading up the screen right diagonally
	beq a0, zero, left_down			#If it hits the edge of the screen the ball heads down the screen screen in the left direction
	li t2, 3
	addi t1, t1, 4
	addi a1, a1, 1
	li t3, 1
	addi a0, a0, -1
	sll t3, t3, a0
	
	lw t2, 0(t1)
	or t2, t2, t3
	sw t2, 0(t1)
	
	
    	j moving				
    	move_back_right_down:
	j right_down
	

left_down: 

	li t2, 0x00000000
    	and t2, t2, t3
    	sw t2, 0(t1)
	li a2, 2
	
	beq a0, s2, right_down
	beq a1, s2, check_if_over_left
	left_down_continue:
	beq a1, s2, left_up
	li t2, 27
	addi t1, t1, 4
	addi a1, a1, 1
	li t3, 1
	addi a0, a0, 1
	sll t3, t3, a0
	lw t2, 0(t1)
	or t2, t2, t3
	sw t2, 0(t1)
	
    	
    	j moving				
    	move_back_left_down:
    	
    	
	j left_down
	
left_up_offset:
	li t2, 3
	add t2, a0, t2
	bge t2, s2, left_up
	addi a0, a0, 2
	
left_up: 

	li t2, 0x00000000
    	and t2, t2, t3
    	sw t2, 0(t1)
	
	li a2, 3
	beq a1, s0, rem_pixel_checkl
	beq a1, s0, left_down
	beq a0, s2, right_up
	
	addi t1, t1, -4
	addi a1, a1, -1
	li t3, 1
	addi a0, a0, 1
	sll t3, t3, a0
	
	lw t2, 0(t1)
	or t2, t2, t3
	sw t2, 0(t1)
	
	
    	
    	
    	j moving				
    	move_back_left_up:
    	
	j left_up
	
	
rem_pixel_checkr:
	li a4, 1
	j check_if_hit

rem_pixel_right:         #If a pixel has been hit then it will be removed and will jump back to moving the ball
	li t6, 1
	sll t6, t6, a0
	lw t3, -4(t1)
	or t3, t3, t6
	xor t3, t3, t6
	sw t3, -4(t1)
	li t6, 32
	beq a6, t6, win_over
	j right_down
	
	
rem_pixel_checkl:
	li a4, 0
	j check_if_hit
rem_pixel_left:		#If a pixel has been hit then it will be removed and will jump back to moving the ball
	li t6, 1
	sll t6, t6, a0
	lw t3, -4(t1)
	or t3, t3, t6
	xor t3, t3, t6
	sw t3, -4(t1)
	li t6, 32
	beq a6, t6, win_over
	j left_down
	
rem_pixel_right_dif:	#If a pixel has been hit then it will be removed and will jump back to moving the ball
	li t6, 1
	sll t6, t6, s11
	lw t3, -4(t1)
	or t3, t3, t6
	xor t3, t3, t6
	sw t3, -4(t1)
	li t6, 32
	beq a6, t6, win_over
	
	
	j right_down
	
rem_pixel_left_dif:	#If a pixel has been hit then it will be removed and will jump back to moving the ball
	li t6, 1
	sll t6, t6, s11
	lw t3, -4(t1)
	or t3, t3, t6
	xor t3, t3, t6
	sw t3, -4(t1)
	li t6, 32
	beq a6, t6, win_over
	j left_down


check_if_hit:
	li t6, 1
	lw t3, -4(t1)
	sll t6, t6, a0
	and t6, t6, t3 
	beq t6, zero, checker_side  #If there is not a pixel directly above the ball then it checks to see if there is a pixel to the right or left of the ball depending on what direction the ball was heading before hitting the top
	li t6, 1
	add a6, a6, t6
	j load_num
	
checker_side:	
	beq a4, zero, checker_side_left
	
checker_side_right:		#If the pixel was moving right than it check to see if there is a pixel to the right of the ball at the top
	li t6, 1
	mv s11, a0
	addi s11, s11, -1
	lw t3, -4(t1)
	sll t6, t6, s11
	and t6, t6, t3
	beq t6, zero, checker
	li a4, 2
	li t6, 1
	add a6, a6, t6
	j load_num

checker_side_left:		#If the pixel was moving left than it check to see if there is a pixel to the right of the ball at the top
	li t6, 1
	mv s11, a0
	addi s11, s11, 1
	lw t3, -4(t1)
	sll t6, t6, s11
	and t6, t6, t3
	beq t6, zero, checker
	li t6, 1
	add a6, a6, t6
	li a4, 3
	j load_num
	 
	
load_num:			#If a pixel has been hit the score needs to be updated and stored on the 7 segment display
	la t6, Num
	la t0, Display
	#Load the hex code for each digit into an array
	li t2, 0x67
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x7F
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x07
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x7C
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x6D
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x66
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x4F
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x5b
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x06
	sb t2, 0(t0)
	addi t0, t0, 4
	li t2, 0x3F
	sb t2, 0(t0)
	
	mv a5, a6
	mv s10, a5
	li s3, 10
	
	#Checks to see if a number contains 2 digits or 1
	blt a5, s3, loop
	rem t2, a5, s3
	mv t4, t2
	div a5, a5, s3	
	rem t3, a5, s3
	
	j loop2 
	
	#Note on what loop, loop2, and loop3 do
	#-The digit that needs to be displayed is stored in a regitser for example a5 in loop
	#-Then a5 is decremented in each iteration of the loop and at the same time t0 is being iterated through backwards
	#-When a5 reaches zero then the correct code for the number is found and can be displayed on the 7 segment
		
	
loop:   beq a5, zero, done
	addi t0, t0, -4
	addi a5, a5, -1
	j loop
	
loop2: beq t2, zero, done
       addi t0, t0, -4
       addi t2, t2, -1
	j loop2
	
	
return: 
	li t2, 4
	mul t4, t4, t2
return_loops:			#Return the pointer to the start of the Array
	beq t4, zero, loop3
	addi t0, t0, 4
	sub t4, t4, t2
	j return_loops
	
	
loop3:	beq t3, zero, done2
	addi t0, t0, -4
	addi t3, t3, -1
	j loop3

done:				#Displays the digit on the right 7 segment display
	li s8, 0xffff0010
	lb t5, 0(t0)
	sw t5, 0(s8)
	bge s10, s3, return
	j checker
	
			
done2: 				#If the number is 2 digits in size the second digit is then displayed the on the left 7 segment
       addi s8, s8, 1
       lb t5, 0(t0)
       sb t5, 0(s8)
       j checker
       
checker:			#Returns to moving the pixel
	li t6, 1
	li t5, 2
	beq a4, zero, rem_pixel_left
	beq a4, t6, rem_pixel_right
	beq a4, t5, rem_pixel_right_dif
	j rem_pixel_left_dif
	
	
	
print_paddle:			#This label initially prints the paddle on the left most side of the screen
	li s4, 27
	li ra, 0
	li t6, 1
	lw t3, 0(a3)
	
	sll t6, t6, s4
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	sw t3, 0(a3)
	j continue
		
moving:
	li s7, 0x10000005 
	li s5, 1
	li t0, 1
	lb t5, 0(s7)
	and s5, s5, t5
	bne s5, t0, moving		#If a button on the keyboard has not been pressed then the paddle does not move
	li s7, 0x10000000 
	la t2, left_button
	lb s6, 0(t2)
	la t4, right_button
	lb t5, 0(t4)
	li s5, 0
	
calc_move:				#Checks to see if 'a' or 'd' has been pressed on the keyboard
	lw t0, 0(s7)
	beq t0, s6, shift_left
	beq t0, t5, shift_right
	j doneM 
	
	

shift_left:
	li t0, 27
	lw t3, 0(a3)
	li t6, 1
	sll t6, t6, s4
	xor t3, t3, t6
	beq s4, t0, doneM		#If the paddle is at the edge of the screen it will not move the paddle any more to the left
	addi s4, s4, 1
	li t6, 1
	sll t6, t6, s4
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	sw t3, 0(a3)
	j doneM

shift_right:				
	lw t3, 0(a3)
	li t6, 1
	addi t2, s4, 4
	sll t6, t6, t2
	xor t3, t3, t6
	beq s4, zero, doneM		#If the paddle is at the edge of the screen it will not move the paddle any more to the left
	addi s4, s4, -1
	li t6, 1
	sll t6, t6, s4
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	slli t6, t6, 1
	or t3, t3, t6
	sw t3, 0(a3)
	j doneM
	
doneM:						#When the paddle has been moved return back to moving the ball
	beq a2, zero, move_back_right_up
	li t2, 1
	beq a2, t2, move_back_right_down
	li t2, 2
	beq a2, t2, move_back_left_down
	li t2, 3
	beq a2, t2, move_back_left_up
	
check_if_over_left: 				#Checks to see if there is no paddle underneath the ball when it reaches the bottom of the screen
	li t6, 1				#If there is no paddle then the game ends
	lw t3, 0(a3)
	sll t6, t6, a0
	and t6, t6, t3
	beq t6, zero, game_over
	srli t6, t6, 1
	and t6, t6, t3
	beq t6, zero, right_up_offset
	j left_down_continue
	
check_if_over_right: 
	li t6, 1
	lw t3, 0(a3)
	sll t6, t6, a0
	and t6, t6, t3
	beq t6, zero, game_over
	slli t6, t6, 1
	and t6, t6, t3
	beq t6, zero, left_up_offset
	j right_down_continue
	

	#If game ends and the user loses the game over message is displayed
game_over: 
	la t0, end_sentence
	li t1, 0x10000000
	li t5, 17
game_over_loop:
	lb t2, 0(t0)
	beq t5, zero, over
	sb t2, 0(t1)
	addi t0, t0, 1
	addi t5, t5, -1
	j game_over_loop
	
	
	#If the user hits all the pixels and has a score of 32 the game ends and the user is shown the winner message
win_over: 
	la t0, win_sentence
	li t1, 0x10000000
	li t5, 19

win_over_loop:
	lb t2, 0(t0)
	beq t5, zero, over
	sb t2, 0(t1)
	addi t0, t0, 1
	addi t5, t5, -1
	j win_over_loop 

over:
	li a7, 11
	ecall
	
	

.data


Num: .word 2
pic: .word 0xffffffff, 0xffffffff
new_line: .space 32
starting_sentence: .ascii "*** Breakout! ***\n"
next_sentence: .ascii "Press any button to start!\nPress a to move left and d to move right\n"
end_sentence: .ascii "*** Game Over ***\n"
win_sentence: .ascii "*** You WIN!!! ***\n"
left_button: .ascii "a"
right_button: .ascii "d"

.section .bss
Display: .space 10



   
