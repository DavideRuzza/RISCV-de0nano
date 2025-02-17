
`include "cpu/define.v"

module mem_wb_reg (

    input wire               clk,
    input wire               rst,

    input wire [`StallBus  ] stall_i,

    input wire [`RegAddrBus] rd_i,
    input wire [`DataBus   ] alu_i,
    input wire [`DataBus   ] d_mem_i,

    output reg [`RegAddrBus] rd,
    output reg [`DataBus   ] alu,
    output reg [`DataBus   ] d_mem,

    // control signals
    input wire               wb_reg_wr_i, // 1 to write result into register file
    input wire               wb_mem_sel_i, // 1 to select data to write from memory

    output reg               wb_reg_wr, // reg write signal
    output reg               wb_mem_sel

);


always @(posedge clk) begin

    if (rst) begin
        rd <= 0;
        d_mem <= 0;
        alu <= 0;
        wb_reg_wr <= 0;
        wb_mem_sel <= 0;        
    end else if (!stall_i[4]) begin
        rd <= rd_i; 
        alu <= alu_i; 
        d_mem <= d_mem_i; 
        wb_reg_wr <= wb_reg_wr_i;
        wb_mem_sel <= wb_mem_sel_i;  
    end
end
    
endmodule