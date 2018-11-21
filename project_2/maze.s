        .data
maze:   .word 0:49
cnt:    .word 0
m:      .word 0
n:      .word 0
# debug
space:  .asciiz " "
newline:.asciiz "\n"
left:   .asciiz "left\n"
right:  .asciiz "right\n"
up:     .asciiz "up\n"
down:   .asciiz "down\n"

        .macro print_int(%x)
        li $v0,1
        move $a0,%x
        syscall
        .end_macro

        .macro print_str(%x)
        li $v0,4
        la $a0,%x
        syscall
        .end_macro

        .text
main:
        la $s5,maze
        la $s4,cnt
        li $v0,5
        syscall
        la $t0,m
        move $s6,$v0
        sw $v0,0($t0)

        li $v0,5
        syscall
        move $s7,$v0
        la $t0,n
        sw $v0,0($t0)

        move $t0,$0
read_out:
        move $t1,$0
read_in:
        mult $t0,$s7
        mflo $t3
        add $t3,$t3,$t1
        sll $t3,$t3,2
        add $t3,$s5,$t3

        li $v0,5
        syscall
        sw $v0,0($t3)

        addi $t1,$t1,1
        bne $t1,$s7,read_in

        addi $t0,$t0,1
        bne $t0,$s6,read_out

        li $v0,5
        syscall
        addi $s3,$v0,-1     # begin row
        li $v0,5
        syscall
        addi $s2,$v0,-1     # begin col

        li $v0,5
        syscall
        addi $s1,$v0,-1     # end row
        li $v0,5
        syscall
        addi $s0,$v0,-1     # end col

        mult $s3,$s7
        mflo $t0
        add $t0,$t0,$s2
        sll $t0,$t0,2
        add $t0,$t0,$s5

        # move $a1,$s2
        # move $a2,$s3
        addi $sp,$sp,-12
        sw $s3,0($sp)
        sw $s2,4($sp)
        sw $t0,8($sp)
        jal dfs
        j fin
dfs:
        lw $a3,8($sp)   # current pointer
        lw $a1,4($sp)   # x
        lw $a2,0($sp)   # y

        # debug
        # print_int($a1)
        # print_str(space)
        # print_int($a2)
        # print_str(newline)

        addi $sp,$sp,-4
        sw $ra,0($sp)
vic_judge_first:
        bne $a1,$s0,vic_judge_end
vic_judge_second:
        bne $a2,$s1,vic_judge_end
        j vic
vic_judge_end:

        # left
left_judge_first:
        # debug
        # print_str(left)

        ble $a1,$0,left_judge_end
left_judge_second:
        addi $t0,$a3,-4
        lw $t1,0($t0)
        bne $t1,$0, left_judge_end
        li $t1,1
        sw $t1,0($a3)
        addi $t1,$a1,-1
        addi $sp,$sp,-24
        sw $a2,12($sp)
        sw $a1,16($sp)
        sw $a3,20($sp)
        sw $t0,8($sp)
        sw $t1,4($sp)
        sw $a2,0($sp)
        jal dfs
        lw $a2,12($sp)
        lw $a1,16($sp)
        lw $a3,20($sp)
        addi $sp,$sp,24
        li $t1,0
        sw $t1,0($a3)
left_judge_end:
        # right
right_judge_first:
        # debug
        # print_str(right)
        
        addi $t0,$s7,-1
        bge $a1,$t0,right_judge_end
right_judge_second:
        addi $t0,$a3,4
        lw $t1,0($t0)
        bne $t1,$0, right_judge_end
        li $t1,1
        sw $t1,0($a3)
        addi $t1,$a1,1
        addi $sp,$sp,-24
        sw $a2,12($sp)
        sw $a1,16($sp)
        sw $a3,20($sp)
        sw $t0,8($sp)
        sw $t1,4($sp)
        sw $a2,0($sp)
        jal dfs
        lw $a2,12($sp)
        lw $a1,16($sp)
        lw $a3,20($sp)
        addi $sp,$sp,24
        li $t1,0
        sw $t1,0($a3)
right_judge_end:
        # up
up_judge_first:
        # debug
        # print_str(up)

        ble $a2,$0,up_judge_end
up_judge_second:
        move $t0,$s7        # -n
        sll $t0,$t0,2
        sub $t0,$a3,$t0
        lw $t1,0($t0)
        bne $t1,$0,up_judge_end
        li $t1,1
        sw $t1,0($a3)
        addi $t1,$a2,-1
        addi $sp,$sp,-24
        sw $a2,12($sp)
        sw $a1,16($sp)
        sw $a3,20($sp)
        sw $t0,8($sp)
        sw $a1,4($sp) # false
        sw $t1,0($sp)
        jal dfs
        lw $a2,12($sp)
        lw $a1,16($sp)
        lw $a3,20($sp)
        addi $sp,$sp,24
        li $t1,0
        sw $t1,0($a3)
up_judge_end:
        # down
down_judge_first:
        # debug
        # print_str(down)

        addi $t0,$s6,-1
        bge $a2,$t0,down_judge_end
down_judge_second:
        move $t0,$s7        # +n
        sll $t0,$t0,2
        add $t0,$a3,$t0
        lw $t1,0($t0)
        bne $t1,$0,down_judge_end
        li $t1,1
        sw $t1,0($a3)
        addi $t1,$a2,1
        addi $sp,$sp,-24
        sw $a2,12($sp)
        sw $a1,16($sp)
        sw $a3,20($sp)
        sw $t0,8($sp)
        sw $a1,4($sp)
        sw $t1,0($sp)
        jal dfs
        lw $a2,12($sp)
        lw $a1,16($sp)
        lw $a3,20($sp)
        addi $sp,$sp,24
        li $t1,0
        sw $t1,0($a3)
down_judge_end:
        lw $ra,0($sp)
        addi $sp,$sp,4
        jr $ra
vic:
        lw $t0,0($s4)
        addi $t0,$t0,1
        sw $t0,0($s4)
        lw $ra,0($sp)
        addi $sp,$sp,4
        jr $ra
fin:
        lw $a0,0($s4)
        li $v0,1
        syscall
        li $v0,10
        syscall