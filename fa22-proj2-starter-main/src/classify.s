.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    addi sp,sp,-52
    sw ra,0(sp)
    sw s0,4(sp)   #s0->store o's address
    sw s1,8(sp)
    sw s2,12(sp)
    sw s3,16(sp)  #s3->store the number of m0'rows 
    sw s4,20(sp)  #s4->store the number of m0'cols
    sw s5,24(sp)  #s5->store m0 address  or h's address
    sw s6,28(sp)  #s6->store m1 address
    sw s7,32(sp)  #s7->store input address
    sw s8,36(sp)  #s8->store m1's row
    sw s9,40(sp)  #s9->store m1's col
    sw s10,44(sp)  #s10->store input's row
    sw s11,48(sp)  #s11->store input's col
    mv s0,a0
    mv s1,a1
    mv s2,a2
    li t0,5
    bne t0,a0,error

    # Read pretrained m0
    li a0,4
    jal malloc
    mv s3,a0
    beq a0,x0,mallocError
    li a0,4
    jal malloc
    mv s4,a0
    beq a0,x0,mallocError
    lw a0,4(s1)
    mv a1,s3
    mv a2,s4
    jal read_matrix
    mv s5,a0

    # Read pretrained m1
    li a0,4
    jal malloc
    mv s8,a0
    beq a0,x0,mallocError
    li a0,4
    jal malloc
    mv s9,a0
    beq a0,x0,mallocError
    lw a0,8(s1)
    mv a1,s8
    mv a2,s9
    jal read_matrix
    mv s6,a0

    # Read input matrix
    li a0,4
    jal malloc
    mv s10,a0
    beq a0,x0,mallocError
    li a0,4
    jal malloc
    mv s11,a0
    beq a0,x0,mallocError
    lw a0,12(s1)
    mv a1,s10
    mv a2,s11
    jal read_matrix
    mv s7,a0

    # Compute h = matmul(m0, input)
    lw t0,0(s3)
    lw t1,0(s11)
    mul a0,t0,t1
    slli a0,a0,2
    jal malloc
    beq a0,x0,mallocError
    mv t0,a0  #t0->h's address
    mv a0,s5
    lw a1,0(s3)
    lw a2,0(s4)
    mv a3,s7
    lw a4,0(s10)
    lw a5,0(s11)
    mv a6,t0
    addi sp,sp,-4
    sw t0,0(sp)
    jal matmul
    mv a0,s5
    jal free
    lw t0,0(sp)
    addi sp,sp,4
    mv s5,t0

    # Compute h = relu(h)
    mv a0,s5
    lw t0,0(s3)
    lw t1,0(s11)
    mul a1,t0,t1
    jal relu

    # Compute o = matmul(m1, h)
    lw t0,0(s8)
    lw t1,0(s11)
    mul a0,t0,t1
    slli a0,a0,2
    jal malloc
    beq a0,x0,mallocError
    mv s0,a0  #s0->o's address
    mv a0,s6
    lw a1,0(s8)
    lw a2,0(s9)
    mv a3,s5
    lw a4,0(s3)
    lw a5,0(s11)
    mv a6,s0
    jal matmul

    # Write output matrix o
    lw a0,16(s1)
    mv a1,s0
    lw a2,0(s8)
    lw a3,0(s11)
    jal write_matrix

    # Compute and return argmax(o)
    mv a0,s0
    lw t0,0(s8)
    lw t1,0(s11)
    mul a1,t0,t1
    jal argmax
    mv t0,a0
    addi sp,sp,-4
    sw t0,0(sp)
    bne s2,x0,myfree

    # If enabled, print argmax(o) and newline
    jal print_int
    li a0,'\n'
    jal print_char

myfree:
    mv a0,s0
    jal free
    mv a0,s3
    jal free
    mv a0,s4
    jal free
    mv a0,s5
    jal free
    mv a0,s6
    jal free
    mv a0,s7
    jal free
    mv a0,s8
    jal free
    mv a0,s9
    jal free
    mv a0,s10
    jal free
    mv a0,s11
    jal free
    lw t0,0(sp)
    addi sp,sp,4
    lw ra,0(sp)
    lw s0,4(sp)   
    lw s1,8(sp)
    lw s2,12(sp)
    lw s3,16(sp)  
    lw s4,20(sp)  
    lw s5,24(sp)  
    lw s6,28(sp)  
    lw s7,32(sp)  
    lw s8,36(sp)  
    lw s9,40(sp)  
    lw s10,44(sp)  
    lw s11,48(sp)  
    addi sp,sp,52
    mv a0,t0
    jr ra

error:
    li a0,31
    j exit

mallocError:
    li a0,26
    j exit