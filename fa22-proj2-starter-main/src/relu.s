.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi sp,sp,-8
    sw s0,0(sp)
    sw s1,4(sp)
    add t0,x0,x0
    addi t0,t0,1
    blt a1,t0,error
    add s0,a0,x0  #s0->first array address
    addi s1,a1,0  #s1->array size
    addi t0,x0,0  #judge whether the end of the array

loop_start:
    beq t0,s1,loop_end
    slli t1,t0,2  #t1->offset
    add t2,s0,t1  #the value address which should be judged
    lw t3,0(t2)   #the value which should be judged
    bge t3,x0,loop_continue
    sw x0,0(t2)

loop_continue:
    addi t0,t0,1
    beq t0,s1,loop_end
    slli t1,t0,2
    add t2,s0,t1
    lw t3,0(t2)
    bge t3,x0,loop_continue
    sw x0,0(t2)
    j loop_continue

loop_end:


    # Epilogue
    lw s0,0(sp)
    lw s1,4(sp)
    addi sp,sp,8
    jr ra

error:
    li a0,36
    j exit