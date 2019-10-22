
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
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

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
no_match: 		.asciiz  "-1\n"
space: 			.asciiz  " "
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dict_num_words:		.word 0
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
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
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
	addi $s1, $s3, 1		# start_idx ++
	
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

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
#================================================= 
#=================================================
#=================================================


#-------------------------------------------------


contain:                                
        lb   $t0, 0($a0)                # $t0 = char string[0]
        lb   $t1, 0($a1)                # $t1 = char word[0]
        bne  $t0, $t1, contain_return  	# if (*string != *word) check *word
        addi $a0, $a0, 1                # string++
        addi $a1, $a1, 1                # word++
        j    contain                    # back to while

contain_return:
        lb   $t0, 0($a1)                # $t0 = char word[0]
        lb   $t1, newline               # $t1 = newline
        seq  $v0, $t0, $t1             	# *word == '\n'? 1: 0
        jr   $ra                        # return $v0
        

print_word:                             # while loop
        move $t0, $a0                   # $t0 = (char*[])word
        lb   $t1, newline               # $t1 = newline
        lb   $t2, 0($a0)                # $t2 = word[0]
        beq  $t2, $t1, finish       	# if (*word == '\n') exit loop
        beqz $t2, finish   		# if (*word == '\0') exit loop
        li   $v0, 11                    # print char $t0
        lb   $a0, 0($t0)
        syscall
        addi $a0, $t0, 1                # word++ | a0 = t0+1
        j    print_word                 # loop back

finish:
        jr $ra                          # back to $ra

#-------------------------------------------------

strfind:
	lw   $s0, dict_num_words	 # s0 = dict_num_words
        li   $s2, 0                      # grid_idx = 0
        j    while_loop              	 # go to while loop

while_loop:
        lb   $t0, grid($s2)              # $t0 = grid[grid_idx]
        li   $s1, 0			 # idx = 0
        beq  $t0, $zero, while_end       # while(grid[grid_idx] =/= '\0')

for_loop:
        bge  $s1, $s0, for_end           # if (idx < dict_num_words)
        la   $t0, dictionary             # $t0 = dictionary
        sll  $t2, $s1, 2                 # $t2 = 4*idx
        lw   $t1, dictionary_idx($t2)    # $t1 = dictionary_idx[$t2]
        add  $s3, $t0, $t1               # word = dictionary + dictionary_idx[idx]
        la   $t0, grid
        add  $a0, $t0, $s2               # string = grid + grid_idx

        move $s6, $a0 
        move $a1, $s3                    # $a1 = word

        addi $sp, $sp, -4
        sw   $ra, 0($sp)
        jal  contain                     # $v0 = contain(grid + grid_idx, word)
        lw   $ra, 0($sp)
        addi $sp, $sp, 4

        beqz $v0, word_not_found         # if (!contain) go back to while loop
        li   $s4, 1                      # found = 1
        li   $v0, 1                      # set syscall for print int
        move $a0, $s2                    # print(grid_idx at $s2)
        syscall
        li   $v0, 11                     # set syscall for print char
        lb   $a0, space                  # print space
        syscall
        move $a0, $s3                    # $a0 = $s3

        addi $sp, $sp, -4
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
