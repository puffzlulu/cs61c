.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    addi sp,sp,-20
    sw s0,0(sp)
    sw s1,4(sp)
    sw s2,8(sp)
    sw s3,12(sp)
    sw s4,16(sp)
    addi t0,x0,1
    blt a2,t0,error1
    blt a3,t0,error2
    blt a4,t0,error2
    add s0,a0,x0  #s0->the first array's address
    add s1,a1,x0  #s1->the second array's address
    add s2,a2,x0  #s2->loop num
    add s3,a3,x0  #s3->stride of first array
    add s4,a4,x0  #s4->stride of second array
    add t0,x0,x0  #result
    add t1,x0,x0  #the ith element of array1
    add t2,x0,x0  #the ith element of array2
    add t5,x0,x0  #over flag

loop_start:
    lw t3,0(s0)   #the first value
    lw t4,0(s1)   #the second value
    mul t3,t3,t4  #reuse t3 to store the mul
    add t0,t0,t3
    addi t5,t5,1

loop_continue:
    beq t5,s2,loop_end
    add t1,t1,s3
    add t2,t2,s4
    slli t3,t1,2  #offset1
    add t3,s0,t3  #ith address
    lw t3,0(t3)   #ith value
    slli t4,t2,2  #offset2
    add t4,s1,t4
    lw t4,0(t4)
    mul t3,t3,t4
    add t0,t0,t3
    addi t5,t5,1
    j loop_continue

loop_end:
    # Epilogue
    lw s0,0(sp)
    lw s1,4(sp)
    lw s2,8(sp)
    lw s3,12(sp)
    lw s4,16(sp)
    addi sp,sp,20
    add a0,t0,x0

    jr ra

error1:
    li a0,36
    j exit

error2:
    li a0,37
    j exit