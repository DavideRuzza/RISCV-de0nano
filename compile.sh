
cd riscv_program_tests
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o test.o test.S
riscv64-unknown-elf-ld -melf32lriscv -T custom.ld -o test test.o
rm test.o
riscv64-unknown-elf-objdump -d test > test.dump
riscv64-unknown-elf-objcopy -O verilog test test.hex
cd ..
python gen_memory.py
