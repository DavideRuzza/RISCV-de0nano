#!/usr/bin/bash
for file in riscv riscv_out.vcd; do
    [ -f "$file" ] && rm "$file"
done

iverilog -o riscv cpu/* test_benches/mem_tb.v
vvp riscv

if [ "$1" == "-s" ]; then
    if [ "$2" == "-d" ]; then
        gtkwave riscv_out.vcd test_benches/mem_config.gtkw -d --rcfile gtkwaverc
    else
        gtkwave riscv_out.vcd test_benches/mem_config.gtkw
    fi
fi