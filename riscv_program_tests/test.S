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
    li x1, 1
    li x2, 2
    li x3, 3
    li x4, 4
    add x1, x1, x2
    add x1, x1, x3
    add x1, x1, x4
    nop
    nop
    nop
    nop
    
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

