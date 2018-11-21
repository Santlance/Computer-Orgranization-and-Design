        .data
input:  .space 50
size:   .word 0
        .text
main:
        li $v0,5
        syscall
        la $t0,size
        sw $v0,0($t0)
        move $s0,$v0
        la $s1,input
        move $t0,$0
read_loop:
        add $t1,$s1,$t0
        li $v0,12
        syscall
        sb $v0,0($t1)

        addi $t0,$t0,1
        bne $t0,$s0,read_loop
read_loop_end:
        move $s2,$t1        # s1:head s2:tail
        move $t0,$0
judge_loop:
        add $t1,$s1,$t0
        lb $t1,0($t1)
        sub $t2,$s2,$t0
        lb $t2,0($t2)
        bne $t1,$t2,false

        addi $t0,$t0,1
        bne $t0,$s0,judge_loop
judge_loop_end:

true:
        li $a0,1
        li $v0,1
        syscall
        j fin
false:
        li $a0,0
        li $v0,1
        syscall
        j fin

fin:
        li $v0,10
        syscall