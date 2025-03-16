
`include "cpu/define.v"

module pc_reg #(
    parameter PC_RST = 32'h80000000
) 
(

    input wire               clk,
    input wire               rst,

    input wire [`StallBus  ] stall_i,

    // input wire [`InsAddrBus] pc_i,
    input wire [`InsAddrBus] br_addr,   // branch address
    input wire               br_en,     // branch enable

    output reg [`InsAddrBus] pc

);


always @(posedge clk) begin

    if (rst) begin
        pc <= PC_RST;
    end else if (!stall_i[0]) begin
        if (br_en) begin
            pc <= br_addr;
        end else begin
            pc <= pc+4;
        end
    end
end
    
endmodule