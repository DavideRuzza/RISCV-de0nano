from logic_utils import *


# with open("design_logic/riscv/enums/ops_enum.ttable", "w") as f:
#     for op in Ops:
#         f.write(f'{op.value:02x} {op.name}\n')


# with open("design_logic/riscv/enums/ops_f3.ttable", "w") as f:
#     for f3 in OP_F3:
#         f.write(f'{f3.value:1x} {f3.name}\n')
        
with open("fpga_riscv/enums/load_f3.ttable", "w") as f:
    for f3 in LOAD_F3:
        f.write(f'{f3.value:1x} {f3.name}\n')

# with open("design_logic/riscv/enums/store_f3.ttable", "w") as f:
#     for f3 in STORE_F3:
#         f.write(f'{f3.value:1x} {f3.name}\n')

# with open("design_logic/riscv/enums/branch_f3.ttable", "w") as f:
#     for f3 in STORE_F3:
#         f.write(f'{f3.value:1x} {f3.name}\n')
        

with open("fpga_riscv/enums/unique_f3.ttable", "w") as f:
    for f3 in STORE_F3:
        f.write(f'{(Ops.STORE.value<<3)+f3.value:03x} {f3.name}\n')
    for f3 in LOAD_F3:
        f.write(f'{(Ops.LOAD.value<<3)+f3.value:03x} {f3.name}\n')
    for f3 in OP_F3:
        f.write(f'{(Ops.OP.value<<3)+f3.value:03x} {f3.name}\n')
        f.write(f'{(Ops.OP_IMM.value<<3)+f3.value:03x} {f3.name}\n')
    for f3 in LOAD_F3:
        f.write(f'{(Ops.LOAD.value<<3)+f3.value:03x} {f3.name}\n')
 
with open("fpga_riscv/enums/branch_f3.ttable", "w") as f:       
    for f3 in BR_F3:
        f.write(f'{f3.value:1x} {f3.name}\n')
    