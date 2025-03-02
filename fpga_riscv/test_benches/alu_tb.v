`timescale 1ns/100ps 

`include "cpu/define.v"

module alu_tb();

reg clk;
reg rst;

parameter CLOCK_PERIOD = 10;


initial begin 
    clk = 0;  // Initialize clock to 0
    forever begin
        #5;clk = ~clk;  // Toggle clock every 5 time units (10 time units period)
    end
end

localparam s = 4; 
reg [`Funct3Bus] f3;
reg [`Funct7Bus] f7;
reg [s-1:0] op1;
reg [s-1:0] op2;

alu #(
    .SIZE(s)
) alu_0 (
    .rst(rst),
    .f3_i(f3), // operation select for alu
    .f7_i(f7), // operation select for alu
    .op1_i(op1),
    .op2_i(op2)
    
);

initial begin
    // Initialize clock to 0
    $dumpfile("riscv_out.vcd");
    $dumpvars(0, alu_tb);

    f3 = `F3_ADD_SUB;
    f7 = 7'b0100000;

    op1=0;
    op2=0;

    rst=1;
    #10; rst=0;


    #10;
    op1=4'b1111; // -1
    op2=4'b1000; // -8
    #10;
    op1=4'b1110; // -2
    op2=4'b1011; // -5
    #10;
    op1=4'b1000; // -8
    op2=4'b1111; // -1
    #10;
    op1=4'b1101; // -3
    op2=4'b0110; // 6
    #10;
    op1=4'b0111; // 7
    op2=4'b1101; // -3
    #10;
    op1=4'b0110; // 7
    op2=4'b0101; // 5
    #10;
    op1=4'b0001; // 1
    op2=4'b0100; // 4
    #10;
    op1=4'b0111; // 7
    op2=4'b0001; // 1
    #10;
    op1=4'b1011; // -5
    op2=4'b1011; // -5
    #10;
    op1=4'b0100; // 4
    op2=4'b0100; // 4
    #10;

    

    // op1=4'b1111; // -1
    // op2=4'b0000; // 0
    // #10;
    // op1=4'b0111; // 7
    // op2=4'b1000; // -8
    // #10;
    // op1=4'b1100; // -4
    // op2=4'b1111; // -1
    // #10;
    // op1=4'b0001; // 1
    // op2=4'b0011; // 2
    // #10;
    // op1=4'b0110; // 6
    // op2=4'b0110; // 6
    // #10;
    
    $finish; // End simulation
end

endmodule