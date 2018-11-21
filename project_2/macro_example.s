    .data
space: .asciiz " "

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
    
    .macro for(%reg,%from,%to,%body_)
    add %reg,$0,%from
    Loop:
    %body_ ()
    addi %reg,%reg,1
    ble %reg,%to,Loop
    .end_macro
    
    .macro body ()
    print_int($t0)
    print_str(space)
    .end_macro

    .text
    for($t0,1,10,body)
