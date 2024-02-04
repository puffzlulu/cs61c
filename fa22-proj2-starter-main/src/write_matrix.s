.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp,sp,-32
    sw ra,0(sp)
    sw s0,4(sp)
    sw s1,8(sp)
    sw s2,12(sp)
    sw s3,16(sp)
    sw s4,20(sp)
    sw s5,24(sp)
    sw s6,28(sp)
    mv s0,a0  #a pointer to the filename string
    mv s1,a1  #s1->a pointer to the matrix in memory
    mv s2,a2  #s2->row
    mv s3,a3  #s3->col

    li a1,1
    jal fopen
    mv s4,a0  #the file descriptor
    li t0,-1
    beq t0,a0,fopenError

    li a0,4
    jal malloc
    mv s5,a0  #the address malloced
    li t0,0
    beq t0,a0,mallocError
    sw s2,0(s5)

    li a0,4
    jal malloc
    mv s6,a0
    li t0,0
    beq t0,a0,mallocError
    sw s3,0(s6)

    mv a0,s4
    mv a1,s5
    li a2,1
    li a3,4
    jal fwrite
    li t0,1
    bne t0,a0,fwriteError

    mv a0,s4
    mv a1,s6
    li a2,1
    li a3,4
    jal fwrite
    li t0,1
    bne t0,a0,fwriteError

    mv a0,s4
    mv a1,s1
    mul a2,s2,s3
    li a3,4
    jal fwrite
    mul t0,s2,s3
    bne t0,a0,fwriteError

    mv a0,s4
    jal fclose
    li t0,-1
    beq t0,a0,fcloseError

    # Epilogue
    lw ra,0(sp)
    lw s0,4(sp)
    lw s1,8(sp)
    lw s2,12(sp)
    lw s3,16(sp)
    lw s4,20(sp)
    lw s5,24(sp)
    lw s6,28(sp)
    addi sp,sp,32

    jr ra


fopenError:
    li a0,27
    j exit

mallocError:
    li a0,26
    j exit

fwriteError:
    li a0,30
    j exit

fcloseError:
    li a0,28
    j exit