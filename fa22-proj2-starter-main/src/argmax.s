.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi sp,sp,-8
    sw s0,0(sp)
    sw s1,4(sp)
    addi t0,x0,1
    blt a1,t0,error
    add s0,a0,x0  #s0->first array address
    add s1,a1,x0  #s1->array size
    add t0,x0,x0  #t0->the index of largest value
    addi t1,x0,1  #judge whether the end of the array
    beq t1,s1,loop_end

loop_start:
    #let the first element be the largest
    slli t2,t0,2  #offset
    add t3,s0,t2  #the first address
    lw t4,0(t3)   #t4->the largest value

    #compare the second element and the first element
    slli t2,t1,2
    add t3,s0,t2
    lw t5,0(t3)
    blt t5,t4,loop_continue
    beq t5,t4,loop_continue
    add t4,t5,x0  #update the largest value
    add t0,t1,x0  #update the largest value's index

loop_continue:
    addi t1,t1,1
    beq t1,s1,loop_end
    slli t2,t1,2
    add t3,s0,t2
    lw t5,0(t3)
    blt t5,t4,loop_continue
    beq t5,t4,loop_continue
    add t4,t5,x0
    add t0,t1,x0
    j loop_continue

loop_end:
    # Epilogue
    lw s0,0(sp)
    lw s1,4(sp)
    addi sp,sp,8
    add a0,t0,x0
    jr ra

error:
    li a0,36
    j exit