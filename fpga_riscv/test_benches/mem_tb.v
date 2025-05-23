`timescale 1ns/100ps 

`include "cpu/define.v"

module mem_tb();

reg clk;
reg rst;

parameter CLOCK_PERIOD = 10;


initial begin 
    clk = 0;  // Initialize clock to 0
    forever begin
        #5;clk = ~clk;  // Toggle clock every 5 time units (10 time units period)
    end
end


reg mem_re;
reg mem_wr;
reg [2:0] mem_f3;
reg [31:0] addr;
reg [31:0] wdata;

simple_async_memory #(
    .MEM_SIZE(256),
    .MEM_FILE("memory/Dram.hex")
) d_mem (
    .clk(clk),
    .rst(rst),
    .addr(addr),
    .re(mem_re),
    .we(mem_wr)
);


mem_stage mem_stage_0(
    .clk(clk),
    .rst(rst),
    
    .alu_i(addr),
    .wdata_i(wdata),
    .d_mem_i(d_mem.data),

    .mem_re_i(mem_re),
    .mem_wr_i(mem_wr),
    .mem_f3_i(mem_f3)
);


initial begin
    // Initialize clock to 0
    $dumpfile("riscv_out.vcd");
    $dumpvars(0, mem_tb);

    mem_re = 0;
    mem_wr = 0;
    mem_f3 = 0;
    addr = 0;
    wdata = 0;
    
    rst = 1; #10; 
    rst = 0; #10;

    mem_re=1;
    #10;
    addr='h88;
    #10;
    addr='h89;
    #10;
    addr='h8a;
    #10;
    addr='h8b;
    #10;
    mem_re=0;

    #10;
    mem_wr=1;
    addr='h88;
    #10;
    addr='h89;
    #10;
    addr='h8a;
    #10;
    addr='h8b;
    #10;

    
    $finish; // End simulation
end

endmodule