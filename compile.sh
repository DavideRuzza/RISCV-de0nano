offset=0
while getopts "o:" opt; do
  case "$opt" in
    o) 
      offset="$OPTARG"  # Store the provided value
      ;;
    \?) 
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :) 
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

cd riscv_program_tests
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o test.o test.S
riscv64-unknown-elf-ld -melf32lriscv -T custom.ld -o test test.o
rm test.o
riscv64-unknown-elf-objdump -d test > test.dump
riscv64-unknown-elf-objcopy -O verilog test test.hex
cd ..
# if [ "$1" == "-o" ]; then
python gen_memory.py -o $offset
