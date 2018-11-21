        .data
vis:    .word 0:7
res:    .word 0:7
space:  .asciiz " "
newlline:.asciiz "\n"
        .text
main:   
        li $v0,5
        syscall
        move $s7,$v0
        la $s5,vis
        la $s6,res

        move $a1,$0
        addi $sp,$sp,-4
        sw $a1,0($sp)
        jal dfs
        j fin
dfs:
        # $t0=i
        lw $a1,0($sp)
        addi $sp,$sp,-4
        sw $ra,0($sp)
        bge $a1,$s7,print

        move $t0,$0
loop:   
        sll $t1,$t0,2
        add $t1,$s5,$t1
        lw $t2,0($t1)   # symbol[i]
        bne $t2,$0,loop_end
        sll $t3,$a1,2
        add $t3,$s6,$t3
        addi $t4,$t0,1
        sw $t4,0($t3)
        li $t4,1
        sw $t4,0($t1)
        addi $sp,$sp,-16
        sw $a1,12($sp)
        sw $t1,8($sp)
        sw $t0,4($sp)
        addi $a2,$a1,1
        sw $a2,0($sp)
        jal dfs
        lw $t0,4($sp)
        lw $t1,8($sp)
        lw $a1,12($sp)
        addi $sp,$sp,16
        sw $0,0($t1)
loop_end:
        addi $t0,$t0,1
        bne $t0,$s7,loop

        lw $ra,0($sp)
        addi $sp,$sp,4
        jr $ra
print:
        move $t0,$0
print_loop:
        sll $t1,$t0,2
        add $t1,$s6,$t1
        lw $a0,0($t1)
        li $v0,1
        syscall
        li $v0,4
        la $a0,space
        syscall

        addi $t0,$t0,1
        bne $t0,$s7,print_loop

        li $v0,4
        la $a0,newlline
        syscall

        lw $ra,0($sp)
        addi $sp,$sp,4
        jr $ra
fin:
        li $v0,10
        syscall