
`include "cpu/define.v"

module wb_stage
 (

    input wire               clk,
    input wire               rst,

    // input wire [`RegAddrBus] rd_i,
    input wire [`DataBus   ] alu_i,
    input wire [`DataBus   ] d_mem_i,

    // output reg [`RegAddrBus] rd,
    output wire [`DataBus   ] reg_data,

    // control signals
    // input wire               wb_reg_wr_i, // 1 to write result into register file
    input wire               wb_mem_sel_i // 1 to select data to write from memory

);

wire [`DataBus] reg_data_mux = (wb_mem_sel_i) ? d_mem_i : alu_i;

assign reg_data = (rst) ? 32'b0 : reg_data_mux;

// always @(*) begin
    
// end

    
endmodule