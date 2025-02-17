
`include "cpu/define.v"

module ex_mem_reg (

    input wire               clk,
    input wire               rst,

    input wire [`StallBus  ] stall_i,

    input wire [`RegAddrBus] rd_i,
    input wire [`DataBus   ] alu_i,
    input wire [`DataBus   ] wdata_i,

    output reg [`RegAddrBus] rd,
    output reg [`DataBus   ] alu,
    output reg [`DataBus   ] wdata,

    // control signals
    input wire               mem_re_i,
    input wire               mem_wr_i,
    input wire [`Funct3Bus ] mem_f3_i,
    input wire               wb_reg_wr_i, // 1 to write result into register file
    input wire               wb_mem_sel_i, // 1 to select data to write from memory

    output reg               mem_re,
    output reg               mem_wr,
    output reg [`Funct3Bus ] mem_f3,
    output reg               wb_reg_wr, // reg write signal
    output reg               wb_mem_sel

);


always @(posedge clk) begin

    if (rst) begin
        rd <= 0;
        alu <= 0;
        wdata <= 0;

        mem_re <= 0;
        mem_wr <= 0;
        mem_f3 <= 0;
        wb_reg_wr <= 0;
        wb_mem_sel <= 0;    

    end else if (!stall_i[3]) begin
        rd <= rd_i; 
        alu <= alu_i; 
        wdata <= wdata_i; 

        mem_re <= mem_re_i;
        mem_wr <= mem_wr_i;
        mem_f3 <= mem_f3_i;
        wb_reg_wr <= wb_reg_wr_i;
        wb_mem_sel <= wb_mem_sel_i;  
    end
end
    
endmodule