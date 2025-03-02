
`include "cpu/define.v"

module id_ex_reg (

    input wire               clk,
    input wire               rst,

    input wire [`StallBus  ] stall_i,
    input wire [`FlushBus  ] flush_i,

    input wire [`InsAddrBus] pc_i,
    input wire [`RegAddrBus] r1_i,
    input wire [`RegAddrBus] r2_i,
    input wire [`RegAddrBus] rd_i,
    input wire [`DataBus   ] d1_i,
    input wire [`DataBus   ] d2_i,
    input wire [`DataBus   ] imm_i,

    output reg [`InsAddrBus] pc,
    output reg [`RegAddrBus] r1,
    output reg [`RegAddrBus] r2,
    output reg [`RegAddrBus] rd,
    output reg [`DataBus   ] d1,
    output reg [`DataBus   ] d2,
    output reg [`DataBus   ] imm,


    // control signals
    input wire [`Funct3Bus ] ex_f3_i,       // operation select for alu
    input wire [`Funct7Bus ] ex_f7_i,       // operation select for alu
    input wire               ex_imm_sel_i,  // 1 to select immediate as op2 for alu
    input wire               ex_pc_sel_i,   // 1 to select pc as op1 for alu
    input wire               ex_jmp_i,      // 1 if the instruction is a branch instruction for comparison
    input wire               ex_br_i,       // 1 if the instruction is a jump instruction for comparison
    
    input wire               mem_re_i,
    input wire               mem_wr_i,
    input wire [`Funct3Bus ] mem_f3_i,
    input wire               wb_reg_wr_i,   // 1 to write result into register file
    input wire               wb_mem_sel_i,  // 1 to select data to write from memory


    output reg [`Funct3Bus ] ex_f3,
    output reg [`Funct7Bus ] ex_f7,
    output reg               ex_imm_sel,
    output reg               ex_pc_sel,
    output reg               ex_jmp,        // 1 if the instruction is a branch instruction for comparison
    output reg               ex_br,         // 1 if the instruction is a jump instruction for comparison
    output reg               mem_re,        // D-mem read
    output reg               mem_wr,        // d-mem write
    output reg [`Funct3Bus ] mem_f3,        // d-mem size select
    output reg               wb_reg_wr,     // reg write signal
    output reg               wb_mem_sel

);


always @(posedge clk) begin

    if (rst) begin
        pc <= 0;
        r1 <= 0;
        r2 <= 0;
        rd <= 0;
        d1 <= 0;
        d2 <= 0;
        imm <= 0;

        ex_f3 <= 0;
        ex_f7 <= 0;
        ex_imm_sel <= 0;
        ex_pc_sel <= 0;
        ex_jmp <= 0;
        ex_br <= 0;
        mem_re <= 0;
        mem_wr <= 0;
        mem_f3 <= 0;
        wb_reg_wr <= 0;
        wb_mem_sel <= 0;    
    end else if (flush_i[2]) begin
        pc <= pc_i;
        r1 <= 0;
        r2 <= 0;
        rd <= 0;
        d1 <= 0;
        d2 <= 0;
        imm <= 0;

        ex_f3 <= 0;
        ex_f7 <= 0;
        ex_imm_sel <= 0;
        ex_pc_sel <= 0;
        ex_jmp <= 0;
        ex_br <= 0;
        mem_re <= 0;
        mem_wr <= 0;
        mem_f3 <= 0;
        wb_reg_wr <= 0;
        wb_mem_sel <= 0; 

    end else if (!stall_i[2]) begin

        pc <= pc_i;
        r1 <= r1_i;
        r2 <= r2_i;
        rd <= rd_i;
        d1 <= d1_i;
        d2 <= d2_i;
        imm <= imm_i;


        ex_f3 <= ex_f3_i;
        ex_f7 <= ex_f7_i;
        ex_imm_sel <= ex_imm_sel_i;
        ex_pc_sel <= ex_pc_sel_i;
        ex_jmp <= ex_jmp_i;
        ex_br <= ex_br_i;
        mem_re <= mem_re_i;
        mem_wr <= mem_wr_i;
        mem_f3 <= mem_f3_i;
        wb_reg_wr <= wb_reg_wr_i;
        wb_mem_sel <= wb_mem_sel_i;  
    end
end
    
endmodule