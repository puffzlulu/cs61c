.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    addi t0,x0,1
    blt a1,t0,error
    blt a2,t0,error
    blt a4,t0,error
    blt a5,t0,error
    bne a2,a4,error

    # Prologue
    addi sp,sp,-32
    sw s0,0(sp)
    sw s1,4(sp)
    sw s2,8(sp)
    sw s3,12(sp)
    sw s4,16(sp)
    sw ra,20(sp)
    sw s5,24(sp)
    sw s6,28(sp)
    add s0,a0,x0  #s0->arr1's address
    add s1,a1,x0  #s1->arr1's rows
    add s2,a2,x0  #s2->arr1's columns
    add s3,a3,x0  #s3->arr2's address
    add s4,a4,x0  #s4->arr2's rows
    add s5,a5,x0  #s5->arr2's columns
    add s6,a6,x0  #s6->the pointer to the start of d
    add t0,x0,x0  #t0->the row of arr1
    add t1,x0,x0  #t1->the col of arr2


outer_loop_start:
    beq t0,s1,outer_loop_end


inner_loop_start:
    mul t3,t0,s2
    slli t3,t3,2
    add a0,s0,t3  #the pointer to the start of arr1
    slli t4,t1,2
    add a1,s3,t4  #the pointer to the start of arr2
    add a2,s2,x0  #the number of element to use
    addi a3,x0,1  #the stride of arr1
    add a4,x0,s5  #the stride of arr2
    addi sp,sp,-8
    sw t0,0(sp)
    sw t1,4(sp)
    jal dot
    lw t0,0(sp)
    lw t1,4(sp)
    addi sp,sp,8
    mul t3,t0,s5
    slli t3,t3,2
    slli t4,t1,2
    add t3,t3,t4  #offset
    add t3,s6,t3  #c's address
    sw a0,0(t3)
    addi t1,t1,1
    beq t1,s5,inner_loop_end
    j inner_loop_start


inner_loop_end:
    add t1,x0,x0
    addi t0,t0,1
    j outer_loop_start

outer_loop_end:


    # Epilogue
    lw s0,0(sp)
    lw s1,4(sp)
    lw s2,8(sp)
    lw s3,12(sp)
    lw s4,16(sp)
    lw ra,20(sp)
    lw s5,24(sp)
    lw s6,28(sp)
    addi sp,sp,32

    jr ra

error:
    li a0,38
    j exit