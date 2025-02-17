
`include "cpu/define.v"

module pc_reg (

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
        pc <= 0;
    end else if (!stall_i[0]) begin
        if (br_en) begin
            pc <= br_addr;
        end else begin
            pc <= pc+4;
        end
    end
end
    
endmodule