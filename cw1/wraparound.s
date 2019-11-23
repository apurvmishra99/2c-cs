
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
no_match: 				.asciiz  "-1\n"
space: 					.asciiz  " "
comma:					.asciiz  ","
H:						.asciiz  "H"
V:						.asciiz  "V"
D:						.asciiz  "D"
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dict_num_words:		.word 0
.align 4
row_length:			.word 0
.align 4
col_length:			.word 0
.align 4
dictionary_idx:		.space 4004
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


main_start:
	li $s0, 0			# dict_idx = 0
	li $s1, 0			# start_idx = 0
	li $s3, 0			# idx = 0
	 	
do_while:
	lb $t0, dictionary($s3)		# c_input = dictionary[idx]	 	 	
	beq $t0, $zero, do_break	# if (c_input == "\0") break
	lb $t1, newline			# t1 = "\n"
	bne $t0, $t1, do_continue	# if (c_input != "\n") then goto do_continue
	sw $s1, dictionary_idx($s0)	# dictionary_idx[dict_idx] = start_idx
	addi $s0, $s0, 4		# dict_idx ++
	addi $s1, $s3, 1		# start_idx = idx + 1
	
do_continue:
	addi $s3, $s3, 1		# idx ++
	j do_while		 

do_break:
	div $t0, $s0, 4			# t0 = dict_idx / 4
	sw $t0, dict_num_words($zero)	# dict_num_words = t0
	addi $sp, $sp, -4		# stack manioulation
	sw $ra, 0($sp)
	jal strfind
	lw $ra, 0($sp)
	addi $sp, $sp, 4
 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#---------------------------------------------------------------------------------------------#
#			MY FUNCTIONS
#---------------------------------------------------------------------------------------------#
return_1:
		li   $v0 1 						# $v0 = 0
		jr 	 $ra						# return 0

return_0:
		li   $v0 0 						# $v0 = 0
		jr 	 $ra						# return 0

compute_dims:
		lw 	 $t0, row_length		    # t0 = row_length 
		lb   $t2, newline				# t2 = "\n"
row_len:
		lb   $t1, grid($t0)				# t1 = grid[t0]
		addi $t0, $t0, 1				# len++
		bne	 $t1, $t2, row_len		    # if *grid != "\n" then loop
		sw	 $t0, row_length($zero)		# row_length = len
		addi $a0, $a0, 1				# grid ++
		addi $t0, $t0, 1				# len ++
		
		lw   $t0, col_length            # $t0 = col_length
        lb   $t2, newline               # $t1 = newline

col_len:
		lb   $t1, grid($t0)				# t1 = grid[t0]
		addi $t0, $t0, 1				# len++ 
		bne  $t1, $zero, col_len		# if(grid[t0] != \0) then loop
		sub  $t0, $t0, 1				# t0 = t0 - 1 to fix extra line counted
		lw   $t3, row_length			# t3 = row_len
		div  $t0, $t0, $t3				# x*y = N => y = N/x
		sw   $t0, col_length($zero)     # col_length = len 
		
end_dim_calc:
		jr $ra
		
containHorWrap:                                
        lb   $t0, 0($a0)                # $t0 = string[0]
        lb   $t1, 0($a1)                # $t1 = word[0]
        lb	 $t2, newline				# $t2 = "\n"
        lw   $t3, row_length			# t3 = row_length
        subi $t3, $t3, 1				# t3 -= 1 for wrap offset
        beq  $t1, $t2, return_1			# if *word == "\n" then return 1
        bne  $t0, $t2, char_comparision_hor	# if *string != "\n" then go to char comparision
        sub  $a0, $a0, $t3				# string -= (row_length-1)
        j 	 containHorWrap				# loop back
        
char_comparision_hor:
		bne  $t0, $t1, return_0  		# if (*string != *word) then return 0
        addi $a0, $a0, 1                # string++
        addi $a1, $a1, 1                # word++
        j    containHorWrap             # loop again
        
containVerWrap:                                
        lb   $t0, 0($a0)                # $t0 = string[0]
        lb   $t1, 0($a1)                # $t1 = word[0]
        lw   $t3, row_length			# t3 = row_length
        lw   $t4, col_length			# t4 = col_length
        la   $t9, grid					# t9 = grid
        sub  $t6, $t0, $t9				# t6 = pos = string - grid
        div  $t7, $t6, $t3		        # t7 = row_num = pos / row_len
        rem  $t8, $t6, $t3				# t8 = col_num = pos % row_len
        lb	 $t2, newline				# $t2 = "\n"
        
        beq  $t1, $t2, return_1			# if *word == "\n" then return 1
        beq  $t0, $t2, return_0			# if *string == "\n" then return 0, else keeps going to \n's
        bne  $t8, $t4, char_comparision_ver # if col_num == col_length then return 0
        add  $a0, $t9, $t8				# a0 = t9 + t8 = grid + col_num
        j 	 containVerWrap				# loop back
        
char_comparision_ver:
		bne  $t0, $t1, return_0  		# if (*string != *word) then return 0
        add  $a0, $a0, $t3              # string+= row_length
        addi $a1, $a1, 1                # word++
        j    containVerWrap             # loop again

containDiagWrap:                                
#        lb   $t0, 0($a0)                # $t0 = string[0]
 #       lb   $t1, 0($a1)                # $t1 = word[0]
  #      lw   $t3, row_length			# t3 = row_length
   #     lw   $t4, col_length			# t4 = col_length
    #    la   $t9, grid					# t9 = grid
    #    sub  $t6, $t0, $t9				# t6 = pos = string - grid
    #    div  $t7, $t6, $t3		        # t7 = row_num = pos / row_len
    #    rem  $t8, $t6, $t3				# t8 = col_num = pos % row_len
    #    lb	 $t2, newline				# $t2 = "\n"
     #   
     #   beq  $t1, $t2, return_1			# if *word == "\n" then return 1
        
      #  sub  $t3, $t3, 1				# t3 = row_length -1
       # bne  $t3, $t8, char_comparision_diag # if col_num == row_length-1 go to char comp
       # bne  $t4, $t7, char_comparision_diag # if row_num == col_num go to char comp
        
       # addi $t3, $t3, 2				# t3 = row_length + 1 
	#	mul  $t3, $t7, $t3		
	##	sub  $a0, $t0, $t3         		# string -= (row_length+1)
      ##  beq  $t0, $t2, return_0			# if *string == "\n" return 0
        #j containDiagWrap
        lb   $t0, 0($a0)                # $t0 = string[0]
        lb   $t1, 0($a1)                # $t1 = word[0]
        lw   $t3, row_length			# t3 = row_length
        lw   $t4, col_length			# t4 = col_length
        la   $t9, grid					# t9 = grid
        sub  $t6, $t0, $t9				# t6 = pos = string - grid
        div  $t7, $t6, $t3		        # t7 = row_num = pos / row_len
        rem  $t8, $t6, $t3				# t8 = col_num = pos % row_len
        lb	 $t2, newline				# $t2 = "\n"
        
        beq  $t1, $t2, return_1			# if *word == "\n" then return 1
        beq  $t0, $t2, return_0			# if *string == "\n" then return 0
        beq  $t8, $t4, return_0			# if col_num == col_length then return 0
        bne  $t0, $t1, return_0  		# if (*string != *word) then return 0
        addi $t3, $t3, 1				# row_len += 1
        add  $a0, $a0, $t3              # string+= (row_length+1)
        addi $a1, $a1, 1                # word++
        j    containDiagWrap                 # loop again       
#char_comparision_diag:
#		bne  $t0, $t1, return_0			# if (*string != *word) then return 0
#		addi $t3, $t3, 1				# row_len += 1
 #       add  $a0, $a0, $t3              # string+= (row_length+1)
  #      addi $a1, $a1, 1                # word++
   #     j    containDiagWrap            # loop again

print_word:                             # while loop
        move $t0, $a0                   # $t0 = (char*[])word
        lb   $t1, newline               # $t1 = newline
        lb   $t2, 0($a0)                # $t2 = word[0]
        beq  $t2, $t1, finish       	# if (*word == '\n') exit loop
        beqz $t2, finish   				# if (*word == '\0') exit loop
        li   $v0, 11                    # print char $t0
        lb   $a0, 0($t0)
        syscall
        addi $a0, $t0, 1                # word++ | a0 = t0+1
        j    print_word                 # loop back

finish:
        jr $ra                          # back to $ra

#-----------------------------------------------------------------------------------------------#

strfind:
		lw   $s0, dict_num_words	 	 # s0 = dict_num_words
        li   $s2, 0                      # grid_idx = 0
        li	 $s4, 0						 # words_found = 0
        
        addi $sp, $sp, -4
        sw   $ra, 0($sp)
        jal  compute_dims				 # compute_dims()
        lw   $ra, 0($sp)
        addi $sp, $sp, 4
        
        lw   $s5, row_length			 # s5 = row_length	
        lw   $s6, col_length			 # s6 = col_length
        j    while_loop              	 # go to while loop

while_loop:
        lb   $t0, grid($s2)              # $t0 = grid[grid_idx]
        li   $s1, 0			 			 # idx = 0
        beq  $t0, $zero, while_end       # while(grid[grid_idx] =/= '\0')

for_loop:
        bge  $s1, $s0, for_end           # if (idx < dict_num_words)
        la   $t0, dictionary             # $t0 = dictionary
        sll  $t2, $s1, 2                 # $t2 = 4*idx
        lw   $t1, dictionary_idx($t2)    # $t1 = dictionary_idx[$t2]
        add  $s3, $t0, $t1               # word = dictionary + dictionary_idx[idx]
        la   $t0, grid					 # t0 = grid
        add  $a0, $t0, $s2               # string = grid + grid_idx

ifContainHorWrap:
        move $a1, $s3                    # $a1 = word
        addi $sp, $sp, -4
        sw   $ra, 0($sp)
        jal  containHorWrap                  # $v0 = containHor(grid + grid_idx, word)
        lw   $ra, 0($sp)
        addi $sp, $sp, 4
		div  $t4, $s2, $s5				 # t4 = row_num = grid_idx / row_len
        rem  $t5, $s2, $s5				 # t5 = col_num = grid_idx % row_len
#		if word contained Horizontally then
#		print else we check vertically and 
#		diagonally

        beq  $v0, $zero, ifContainVerWrap # if (!containHorWrap) check vertically
        addi $s4, $s4, 1                 # words_found += 1
        li   $v0, 1                      # set syscall for print int
        move $a0, $t4                    # print_int($t4) ; t4 = row_num
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, comma                  # print ","
        syscall
        
        li   $v0, 1                      # set syscall for print int
        move $a0, $t5                    # print_int($t5) ; t4 = col_num
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, space                  # print ","
        syscall
        
        li   $v0, 4                      # set syscall for print char
        la   $a0, H                      # print_char(H)
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, space                  # print ","
        syscall
        
        move $a0, $s3                    # $a0 = $s3
        addi $sp, $sp, -4				 # stack manipulation to store return address
        sw   $ra, 0($sp)
        jal print_word                   # print_word($a0 = $s3)
        lw   $ra, 0($sp)
        addi $sp, $sp, 4
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, newline                # print newline '\n'
        syscall
        
ifContainVerWrap:
#   	checking if word is contained 
#   	vertically if yes then print
#		else checkDiagonal
		la   $t0, grid					 # t0 = grid
        add  $a0, $t0, $s2               # string = grid + grid_idx
        move $a1, $s3					 # a1 = word
        addi $sp, $sp, -4
        sw   $ra, 0($sp)
        jal  containVerWrap              # $v0 = containVerWrap(grid + grid_idx, word)
        lw   $ra, 0($sp)
        addi $sp, $sp, 4
        
        div  $t4, $s2, $s5				 # t4 = row_num = grid_idx / row_len
        rem  $t5, $s2, $s5				 # t5 = col_num = grid_idx % row_len
        
        beq  $v0, $zero, ifContainDiagWrap   # if (!containVerWrap) check diagonally
        addi $s4, $s4, 1                 # words_found += 1
        li   $v0, 1                      # set syscall for print int
        move $a0, $t4                    # print_int($t4) ; t4 = row_num
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, comma                  # print ","
        syscall
        
        li   $v0, 1                      # set syscall for print int
        move $a0, $t5                    # print_int($t5) ; t4 = col_num
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, space                  # print ","
        syscall
        
        li   $v0, 4                      # set syscall for print char
        la   $a0, V                      # print_char(H)
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, space                  # print ","
        syscall
        
        move $a0, $s3                    # $a0 = $s3
        addi $sp, $sp, -4				 # stack manipulation to store return address
        sw   $ra, 0($sp)
        jal print_word                   # print_word($a0 = $s3)
        lw   $ra, 0($sp)
        addi $sp, $sp, 4
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, newline                # print newline '\n'
        syscall
		

ifContainDiagWrap:
#   	checking if word is contained 
#   	diagonally if yes then print
#		else increment while loop
		la   $t0, grid					 # t0 = grid
        add  $a0, $t0, $s2               # string = grid + grid_idx
        move $a1, $s3					 # a1 = word
        addi $sp, $sp, -4
        sw   $ra, 0($sp)
        jal  containDiagWrap             # $v0 = containVer(grid + grid_idx, word)
        lw   $ra, 0($sp)
        addi $sp, $sp, 4
        
        div  $t4, $s2, $s5				 # t4 = row_num = grid_idx / row_len
        rem  $t5, $s2, $s5				 # t5 = col_num = grid_idx % row_len
        
        beq  $v0, $zero, word_not_found  # if (!containDiag) loop
        addi $s4, $s4, 1                 # words_found += 1
        li   $v0, 1                      # set syscall for print int
        move $a0, $t4                    # print_int($t4) ; t4 = row_num
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, comma                  # print ","
        syscall
        
        li   $v0, 1                      # set syscall for print int
        move $a0, $t5                    # print_int($t5) ; t4 = col_num
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, space                  # print ","
        syscall
        
        li   $v0, 4                      # set syscall for print char
        la   $a0, D                      # print_char(H)
        syscall
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, space                  # print ","
        syscall
        
        move $a0, $s3                    # $a0 = $s3
        addi $sp, $sp, -4				 # stack manipulation to store return address
        sw   $ra, 0($sp)
        jal print_word                   # print_word($a0 = $s3)
        lw   $ra, 0($sp)
        addi $sp, $sp, 4
        
        li   $v0, 11                     # set syscall for print char
        lb   $a0, newline                # print newline '\n'
        syscall
        
word_not_found:
        addi $s1, $s1, 1                  # idx ++
        j for_loop

for_end:
        addi $s2, $s2, 1                  # grid_idx ++
        j while_loop

while_end:
        bgtz $s4, words_found
        la   $a0, no_match              # $a0 = "-1\n"
        addi $sp, $sp, -4
        sw   $ra, 0($sp)
        jal  print_word                 # print(word at $a0 = $s3)
        lw   $ra, 0($sp)
        addi $sp, $sp, 4

words_found:
		jr $ra
