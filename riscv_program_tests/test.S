.section .data
msg:    .asciz "Hello, RISC-V!\n"

.section .text
.global start


# start:
#     li x1, 2
#     # li x2, 4
#     # nop
#     # nop
#     # nop
#     # nop
#     # nop
#     # nop
#     # add x3, x1, x2

start:
    lui x8, 0x12345
    la x4, loop
    li x3, 2 
    li x2, 0
    li x1, 1
    j loop

loop:
   
    blt x3, x2, is_lt # if x1 < x2 then main
    add x2, x2, x1
    jalr x7, 0(x4)

is_lt:
    li x5, 5

    
# start:

#     li x1, 0x88
#     la a0, msg
#     nop
#     nop
#     nop
#     nop
#     nop
#     lw a1, 0(a0)
#     lb a1, 0(a0)
#     lb a1, 1(a0)
#     lb a1, 2(a0)
#     lb a1, 3(a0)
#     nop
#     nop
#     nop
#     nop
#     nop

