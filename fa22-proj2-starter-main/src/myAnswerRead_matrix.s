.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp,sp,-24
    sw ra,0(sp)
    sw s0,4(sp)
    sw s1,8(sp)
    sw s2,12(sp)
    sw s3,16(sp)  #s3->the file descriptor
    sw s4,20(sp)  #s4->the address to store matrix
    mv s0,a0      #s0->filename
    mv s1,a1      #s1->a pointer to the row integer
    mv s2,a2      #s2->a pointer to the col integer
    li a1,0
    jal fopen
    li t0,-1
    beq a0,t0,fopenError
    mv s3,a0

    mv a1,s1
    li a2,4
    jal fread
    li t0,4
    bne t0,a0,eofError

    mv a0,s3
    mv a1,s2
    li a2,4
    jal fread
    li t0,4
    bne a0,t0,eofError

    mul a0,s1,s2
    slli a0,a0,2
    jal malloc
    li t0,0
    beq a0,t0,mallocError
    mv s4,a0  #t0->the address to store matrix

    mv a0,s3
    mv a1,s4
    mul a2,s1,s2
    slli a2,a2,2
    jal fread
    mul t0,s1,s2
    slli t0,t0,2
    bne a0,t0,eofError

    mv a0,s3
    jal fclose
    li t0,-1
    beq a0,t0,fcloseError

    mv a0,a1
    lw ra,0(sp)
    lw s0,4(sp)
    lw s1,8(sp)
    lw s2,12(sp)
    lw s3,16(sp)
    lw s4,20(sp)
    addi sp,sp,24
    # Epilogue


    jr ra

fopenError:
    li a0,27
    j exit

eofError:
    li a0,29
    j exit

mallocError:
    li a0,26
    j exit

fcloseError:
    li a0,28
    j exit
