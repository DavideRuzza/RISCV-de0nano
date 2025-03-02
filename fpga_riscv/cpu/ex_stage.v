
`include "cpu/define.v"

module ex_stage (

    // input wire               clk,
    input wire               rst,

    // stage input
    input wire [`InsAddrBus] pc_i,
    input wire [`RegAddrBus] r1_i,
    input wire [`RegAddrBus] r2_i,
    input wire [`RegAddrBus] rd_i,
    input wire [`DataBus   ] d1_i,
    input wire [`DataBus   ] d2_i,
    input wire [`DataBus   ] imm_i,

    // control signals
    input wire [`Funct3Bus ] ex_f3_i, // operation select for alu
    input wire [`Funct7Bus ] ex_f7_i, // operation select for alu
    input wire               ex_imm_sel_i, // 1 to select immediate as op2 for alu
    input wire               ex_pc_sel_i, // 1 to select pc as op1 for alu
    input wire               ex_jmp_i, // 1 if the instruction is a branch/jump instruction for comparison
    input wire               ex_br_i, // 1 if the instruction is a branch/jump instruction for comparison

    // forward unit
    input wire  [`RegAddrBus] exmem_rd_i,
    input wire  [`DataBus   ] exmem_alu_i,
    input wire                exmem_wb_reg_wr_i,

    input wire  [`RegAddrBus] memwb_rd_i,
    input wire  [`DataBus   ] memwb_wdata_i,
    input wire                memwb_wb_reg_wr_i, 
    ////


    output wire [`DataBus   ] alu,
    //debug
    output wire [`DataBus   ] wdata,
    output wire               br_jmp_en // branch / jump enable to signal pc_reg to change address

);

wire [`DataBus] r1_forw_mux;
wire [`DataBus] r2_forw_mux;

wire [`DataBus] pc_mux;
wire [`DataBus] imm_mux;

// FOREWARDING
reg [1:0] r1_forw_sel;
reg [1:0] r2_forw_sel;



assign r1_forw_mux = 
                (r1_forw_sel==`NO_FORW) ? d1_i:
                (r1_forw_sel==`EXMEM_FORW) ? exmem_alu_i:
                (r1_forw_sel==`MEMWB_FORW) ? memwb_wdata_i:
                d1_i;

assign r2_forw_mux =  
                (r2_forw_sel==`NO_FORW) ? d2_i:
                (r2_forw_sel==`EXMEM_FORW) ? exmem_alu_i:
                (r2_forw_sel==`MEMWB_FORW) ? memwb_wdata_i:
                d2_i;

always @(*) begin
    r1_forw_sel <= `NO_FORW;
    r2_forw_sel <= `NO_FORW;
    if (exmem_wb_reg_wr_i) begin
        if (exmem_rd_i!=0 && exmem_rd_i==r1_i) begin
            r1_forw_sel <= `EXMEM_FORW;
        end else if (exmem_rd_i!=0 && exmem_rd_i==r2_i) begin
            r2_forw_sel <= `EXMEM_FORW;
        end
    end

    if (memwb_wb_reg_wr_i) begin
        if (memwb_rd_i!=0 && memwb_rd_i==r1_i) begin
            if (!(exmem_wb_reg_wr_i & exmem_rd_i!=0 && exmem_rd_i==r1_i)) begin
                r1_forw_sel <= `MEMWB_FORW;
            end

        end else if (memwb_rd_i!=0 && memwb_rd_i==r2_i) begin
            if (!(exmem_wb_reg_wr_i & exmem_rd_i!=0 && exmem_rd_i==r2_i)) begin
                r2_forw_sel <= `MEMWB_FORW;
            end
        end
    end
    
    
end


/////////////

assign pc_mux = (ex_pc_sel_i) ? pc_i : r1_forw_mux;
assign imm_mux = (ex_imm_sel_i) ? imm_i : r2_forw_mux;

assign wdata = imm_mux;

wire [`DataBus] op1 = pc_mux; // debug
wire [`DataBus] op2 = imm_mux; // debug


// if a branch or jump owerwrite alu to calculate the address

wire [`Funct3Bus] ex_f3_mux = (ex_jmp_i || ex_br_i) ? `F3_ADD_SUB : ex_f3_i;
wire [`Funct7Bus] ex_f7_mux = (ex_jmp_i || ex_br_i) ? 7'b0 : ex_f7_i;



alu #(.SIZE(32)) alu_0(
    .rst(rst),
    .f3_i(ex_f3_mux), // operation select for alu
    .f7_i(ex_f7_mux), // operation select for alu
    .op1_i(op1),
    .op2_i(op2),

    .alu(alu)

    // output wire c, // carry out
    // output wire z, // zero
    // output wire v_sub, // overflow of subtraction
    // output wire n // negative
);

branch_unit #(.SIZE(32)) br_unit_0(
    .rst(rst),
    .br_f3_i(ex_f3_i),
    .op1_i(r1_forw_mux),
    .op2_i(r2_forw_mux)

);

assign br_jmp_en = (ex_br_i & br_unit_0.branch_taken) | ex_jmp_i;






// reg [32:0] alu_arithm;
// wire c_out = alu_arithm[32];
// assign alu = alu_arithm[`DataBus];
// wire z = (alu==32'b0);  // zero
// wire n = alu[31];       // negative
// wire o = (op1[31] & op2[31] & !alu[31]) | (!op1[31] & !op2[31] & alu[31]);
// ALU
// always @(*) begin
//     if (rst) begin
//         alu_arithm <= 0;
//     end else begin
//         case (ex_f3_i)
//             `F3_ADD_SUB: begin
//                 if (ex_f3_i == 7'b0100000) begin
//                     alu_arithm <= op1+op2;
//                 end else begin
//                     alu_arithm <= op1+op2;
//                 end
//             end
//             `F3_AND: begin
//                 alu_arithm <= op1&op2;
//             end
//             `F3_OR: begin
//                 alu_arithm <= op1|op2;
//             end
//             `F3_XOR: begin
//                 alu_arithm <= op1^op2;
//             end
//             default: alu_arithm <= 32'bx;
//         endcase
//     end
// end
endmodule