from elftools.elf.elffile import ELFFile
from enum import Enum
# from math import ceil, log2
from logic_utils import *
from binascii import hexlify
from struct import pack, unpack


x = "riscv_program_tests/test"
Dram = MainMemory(1, 0x00000000)
Iram = MainMemory(1, 0x00000000)
with open(x, "rb") as f:
    e = ELFFile(f)
    
    text = e.get_section_by_name(".text")
    data = e.get_section_by_name(".data")
    # print(data.header.sh_addr, data.data())
    Iram.write_block(text.header.sh_addr, text.data())
    Dram.write_block(data.header.sh_addr, data.data())
    # for s in e.iter_segments():
    #     if s.header.p_paddr < ram.offset:
    #         continue
    #     # print(s.header)
    #     ram.write_block(s.header.p_paddr, s.data())
# Iram.hexdump()
# # print()
# Dram.hexdump()


# ram.hexdump()
# # 16 bit addresses
# with open("ram.hex", "w") as f:
    
#     for i in range(int(ram.size_byte/2)):
#         f.write(hexlify(ram.mem[(i*2):(i*2)+2]).decode())
#         if (i+1)%16==0 and i!=0:
#             f.write('\n')
#         else:
#             f.write(" ")
#     print(i)

# print(ram.mem[(0*4):(0*4)+4])


# # 32 bit addresses
# with open("fpga_riscv/memory/Dram.hex", "w") as f:
#     print("Writing Dram")
#     for i in range(int(Dram.size_byte/4)):
#         data = pack(">I", unpack("<I", Dram.mem[(i*4):(i*4)+4])[0])
#         f.write(hexlify(data).decode())
#         if (i+1)%16==0 and i!=0:
#             f.write('\n')
#         else:
#             f.write(" ")
            
# 8 bit addresses
with open("fpga_riscv/memory/Dram.hex", "w") as f:
    print("Writing Dram")
    for i in range(int(Dram.size_byte)):
        data = pack(">B", unpack("<B", Dram.mem[i:i+1])[0])
        f.write(hexlify(data).decode())
        if (i+1)%16*4==0 and i!=0:
            f.write('\n')
        else:
            f.write(" ")


with open("fpga_riscv/memory/Iram.hex", "w") as f:
    print("Writing Iram")
    for i in range(int(Iram.size_byte/4)):
        data = pack(">I", unpack("<I", Iram.mem[(i*4):(i*4)+4])[0])
        f.write(hexlify(data).decode())
        if (i+1)%16==0 and i!=0:
            f.write('\n')
        else:
            f.write(" ")