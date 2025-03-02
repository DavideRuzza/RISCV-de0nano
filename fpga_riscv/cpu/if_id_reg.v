
`include "cpu/define.v"

module if_id_reg (

    input wire               clk,
    input wire               rst,

    input wire [`StallBus  ] stall_i,
    input wire [`FlushBus  ] flush_i,

    input wire [`InsAddrBus] pc_i,
    input wire [`DataBus   ] ins_i,

    output reg [`InsAddrBus] pc,
    output reg [`DataBus   ] ins

);


always @(posedge clk) begin

    if (rst) begin
        pc <= 0;
        ins <= 0;    
    end else if (flush_i[1]) begin
        ins <= 32'h00000013;
    end else begin
        if (!stall_i[1]) begin
            pc <= pc_i;
            ins <= ins_i;
        end
    end 
end
    
endmodule