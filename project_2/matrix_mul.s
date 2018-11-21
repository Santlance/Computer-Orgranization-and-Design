        .data
size:       .word   0
matrix_1:   .word   0:64
matrix_2:   .word   0:64
space:      .asciiz " "
newline:    .asciiz "\n"

        .text
main:   
        li $v0,5
        syscall
        la $t0,size
        sw $v0,0($t0)

        move $s0,$v0    # $s0=size

matrix_1_read:
        la $s3,matrix_1
        move $t1,$0    # row
matrix_1_read_out:
        mult $s0,$t1
        mflo $s1
        move $t2,$0    #col
matrix_1_read_in:

        add $s2,$s1,$t2
        sll $s2,$s2,2
        add $s2,$s2,$s3
        li $v0,5
        syscall
        sw $v0,0($s2)

        addi $t2,$t2,1
        bne $t2,$s0,matrix_1_read_in
matrix_1_read_in_end:
        addi $t1,$t1,1
        bne $t1,$s0,matrix_1_read_out
matrix_1_read_out_end:

matrix_2_read:
        la $s3,matrix_2
        move $t1,$0    # row
matrix_2_read_out:
        mult $s0,$t1
        mflo $s1
        move $t2,$0    #col
matrix_2_read_in:

        add $s2,$s1,$t2
        sll $s2,$s2,2
        add $s2,$s2,$s3
        li $v0,5
        syscall
        sw $v0,0($s2)

        addi $t2,$t2,1
        bne $t2,$s0,matrix_2_read_in
matrix_2_read_in_end:
        addi $t1,$t1,1
        bne $t1,$s0,matrix_2_read_out
matrix_2_read_out_end:
        la $s1,matrix_1
        la $s2,matrix_2
        move $t0,$0         # row
loop_out:
        move $t1,$0         # col
loop_in:
        move $t4,$0
        move $t3,$0         # result
cac:    
        mult $t0,$s0        # (t0*s0+t4)<<2
        mflo $t5
        add $t5,$t5,$t4
        sll $t5,$t5,2
        add $t5,$s1,$t5
        lw $t5,0($t5)

        mult $t4,$s0        # (t4*s0+t1)<<2
        mflo $t6
        add $t6,$t6,$t1
        sll $t6,$t6,2
        add $t6,$s2,$t6
        lw $t6,0($t6)

        mult $t5,$t6
        mflo $t5
        add $t3,$t3,$t5
        
        addi $t4,$t4,1
        bne $t4,$s0,cac
cac_end:
        move $a0,$t3
        li $v0,1
        syscall
        la $a0,space
        li $v0,4
        syscall

        addi $t1,$t1,1
        bne $t1,$s0,loop_in
loop_in_end:
        la $a0,newline
        li $v0,4
        syscall
        addi $t0,$t0,1
        bne $t0,$s0,loop_out
loop_out_end:
        li $v0,10
        syscall