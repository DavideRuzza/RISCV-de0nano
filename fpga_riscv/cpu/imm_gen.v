`include "cpu/define.v"

module imm_gen(
    input wire               rst,
    input wire [`OpBus     ] op,
    input wire [`InsAddrBus] ins_i, // ins_itruction

    output wire [`DataBus  ] imm_out

);


wire [`DataBus] I_imm;
wire [`DataBus] S_imm;
wire [`DataBus] B_imm;
wire [`DataBus] U_imm;
wire [`DataBus] J_imm;

assign I_imm = { {20{ins_i[31]}}, ins_i[31:20]}; // signextended
assign S_imm = { {20{ins_i[31]}}, ins_i[31:25], ins_i[11:7]};
assign B_imm = { {19{ins_i[31]}}, ins_i[31], ins_i[7], ins_i[30:25], ins_i[11:8], 1'b0};
assign U_imm = { ins_i[31:12], 12'b0};
assign J_imm = { {12{ins_i[31]}}, ins_i[31], ins_i[19:12], ins_i[20], ins_i[30:21], 1'b0};

wire I_type;
wire S_type;
wire B_type;
wire U_type;
wire J_type;

assign I_type = (op==`OP_OP_IMM || op==`OP_LOAD);
assign J_type = (op==`OP_JAL);
assign S_type = (op==`OP_STORE);
assign B_type = (op==`OP_BRANCH);
assign U_type = (op==`OP_AUIPC || op==`OP_LUI); 

assign imm_out = 
        (I_type) ? I_imm : 
        (J_type) ? J_imm :
        (S_type) ? S_imm :
        (B_type) ? B_imm :
        (U_type) ? U_imm :
        32'b0;

endmodule