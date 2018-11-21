        .data
matrix: .word 0:121
kernal: .word 0:121
space:  .asciiz " "
newline:.asciiz "\n"
m1:     .word 0
n1:     .word 0
m2:     .word 0
n2:     .word 0
        .text       

        .macro print_int(%x)
            li $v0,1
            add $a0,$0,%x
            syscall
        .end_macro

        .macro print_str(%x)
            li $v0,4
            la $a0,%x
            syscall
        .end_macro
main:
size_input:
        la $t0,m1
        li $v0,5
        syscall
        sw $v0,0($t0)

        la $t0,n1
        li $v0,5
        syscall
        sw $v0,0($t0)

        la $t0,m2
        li $v0,5
        syscall
        sw $v0,0($t0)
        
        la $t0,n2
        li $v0,5
        syscall
        sw $v0,0($t0)
size_input_end:
        la $s0,matrix
        la $s1,m1
        lw $s1,0($s1)
        la $s2,n1
        lw $s2,0($s2)
        move $t0,$0
matrix_input_out:
        move $t1,$0
        # (t0*s2+t1)<<2+s0
matrix_input_in:

        mult $t0,$s2
        mflo $t5
        add $t5,$t5,$t1
        sll $t5,$t5,2
        add $t5,$s0,$t5

        li $v0,5
        syscall
        sw $v0,0($t5)

        addi $t1,$t1,1
        bne $t1,$s2,matrix_input_in
matrix_input_in_end:
        addi $t0,$t0,1
        bne $t0,$s1,matrix_input_out
matrix_input_out_end:

        la $s0,kernal
        la $s1,m2
        lw $s1,0($s1)
        la $s2,n2
        lw $s2,0($s2)
        move $t0,$0
kernal_input_out:
        move $t1,$0
        # (t0*s2+t1)<<2+s0
kernal_input_in:

        mult $t0,$s2
        mflo $t5
        add $t5,$t5,$t1
        sll $t5,$t5,2
        add $t5,$s0,$t5

        li $v0,5
        syscall
        sw $v0,0($t5)

        addi $t1,$t1,1
        bne $t1,$s2,kernal_input_in
kernal_input_in_end:
        addi $t0,$t0,1
        bne $t0,$s1,kernal_input_out
kernal_input_out_end:
        # m1-m2+1 n1-n2+1
        la $t1,m1
        lw $t1,0($t1)
        la $t2,n1
        lw $t2,0($t2)

        la $s1,m2
        lw $s1,0($s1)
        la $s2,n2
        lw $s2,0($s2)

        sub $s5,$t1,$s1
        addi $s5,$s5,1

        sub $s6,$t2,$s2
        addi $s6,$s6,1

        move $s3,$0
cac_loop_out:
        move $s4,$0
cac_loop_in:
        mul $t3,$s3,$t2
        add $t3,$t3,$s4
        sll $t3,$t3,2
        la $t4,matrix
        add $t3,$t4,$t3
        
        move $s0,$0     # row
        mult $0,$0      # clear hi,lo
loop_out:
        move $t0,$0     # col
loop_in:
        # t3+(s0*t2+t0)<<2
        mfhi $a1
        mflo $a2
        mul $t4,$s0,$t2
        add $t4,$t4,$t0
        sll $t4,$t4,2
        add $t4,$t3,$t4
        
        lw $t4,0($t4)

        la $t5,kernal
        # t5+(s0*s2+t0)<<2
        mul $t6,$s0,$s2
        add $t6,$t0,$t6
        sll $t6,$t6,2
        add $t6,$t6,$t5
        
        lw $t6,0($t6)
        mthi $a1
        mtlo $a2
        madd $t4,$t6
        mflo $a0
        
        addi $t0,$t0,1
        bne $t0,$s2,loop_in
loop_in_end:

        addi $s0,$s0,1
        bne $s0,$s1,loop_out
loop_out_end:
        mfhi $a0
        li $v0,35
        syscall

        mflo $a0
        li $v0,35
        syscall

        la $a0,space
        li $v0,4
        syscall

        addi $s4,$s4,1
        bne $s6,$s4,cac_loop_in
cac_loop_in_end:
        la $a0,newline
        li $v0,4
        syscall

        addi $s3,$s3,1
        bne $s5,$s3,cac_loop_out
cac_loop_out_end:

fin:
        li $v0,10
        syscall
