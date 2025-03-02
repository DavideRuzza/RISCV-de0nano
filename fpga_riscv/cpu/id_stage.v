
`include "cpu/define.v"

module id_stage (

    input wire                clk,
    input wire                rst,

    input wire [`DataBus    ] ins_i,

    input wire                reg_file_we_i, // reg file write enable
    input wire [`RegAddrBus ] reg_file_waddr_i,
    input wire [`DataBus    ] reg_file_wdata_i,

    output wire [`RegAddrBus] r1,
    output wire [`RegAddrBus] r2,
    output wire [`RegAddrBus] rd,
    output wire [`DataBus   ] d1,
    output wire [`DataBus   ] d2,
    output wire [`DataBus   ] imm,

    output reg [`Funct3Bus ] ex_f3,         // operation select for alu
    output reg [`Funct7Bus ] ex_f7,         // operation select for alu
    output reg               ex_imm_sel,    // 1 to select immediate as op2 for alu
    output reg               ex_pc_sel,     // 1 to select pc as op1 for alu
    output reg               ex_jmp,        // 1 if the instruction is a branch instruction for comparison
    output reg               ex_br,         // 1 if the instruction is a jump instruction for comparison
    output reg               mem_re,        // D-mem read
    output reg               mem_wr,        // D-mem write
    output reg [`Funct3Bus ] mem_f3,        // D-mem size select
    output reg               wb_reg_wr,     // reg write signal
    output reg               wb_mem_sel     // 1 to select data to write from memory

);

`define SET_CTRL(ex_f3_s, ex_f7_s, ex_imm_sel_s, ex_pc_sel_s, ex_jmp_s, ex_br_s, mem_re_s, mem_wr_s, mem_f3_s, wb_reg_wr_s, wb_mem_sel_s) \
    ex_f3 = ex_f3_s; \
    ex_f7 = ex_f7_s; \
    ex_imm_sel = ex_imm_sel_s; \
    ex_pc_sel = ex_pc_sel_s; \
    ex_jmp = ex_jmp_s; \
    ex_br = ex_br_s; \
    mem_re = mem_re_s; \
    mem_wr = mem_wr_s; \
    mem_f3 = mem_f3_s; \
    wb_reg_wr = wb_reg_wr_s; \
    wb_mem_sel = wb_mem_sel_s; \

wire [`OpBus] op = ins_i[6:0];
assign r1 = ins_i[19:15];
assign r2 = ins_i[24:20];
assign rd = ins_i[11:7];
wire [`Funct3Bus ] f3 = ins_i[14:12];
wire [`Funct7Bus ] f7 = ins_i[31:25];

wire [9:0] unique_f3 = {op, f3};

reg_file reg_file_0(
    .clk(clk),
    .rst(rst),

    .we(reg_file_we_i),
    .waddr(reg_file_waddr_i),
    .wdata(reg_file_wdata_i),
    .r1(r1),
    .r2(r2),
    .d1(d1),
    .d2(d2)

);


wire [31:0] x0 = reg_file_0.reg_file[0];
wire [31:0] x1 = reg_file_0.reg_file[1];
wire [31:0] x2 = reg_file_0.reg_file[2];
wire [31:0] x3 = reg_file_0.reg_file[3];
wire [31:0] x4 = reg_file_0.reg_file[4];
wire [31:0] x5 = reg_file_0.reg_file[5];
wire [31:0] x6 = reg_file_0.reg_file[6];
wire [31:0] x7 = reg_file_0.reg_file[7];
wire [31:0] x8 = reg_file_0.reg_file[8];
wire [31:0] x9 = reg_file_0.reg_file[9];
wire [31:0] x10 = reg_file_0.reg_file[10];
wire [31:0] x11 = reg_file_0.reg_file[011];
wire [31:0] x12 = reg_file_0.reg_file[012];

imm_gen imm_gen_0(
    .rst(rst),
    .op(op),
    .ins_i(ins_i), // instruction
    .imm_out(imm)
);

// CONTROL UNIT

always @(*) begin
    if (rst) begin
        `SET_CTRL(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    end else begin
        case (op)
            `OP_INVALID: begin
                `SET_CTRL(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            end
            `OP_OP_IMM: begin
                case (f3)
                    `F3_ADD_SUB: begin
                        `SET_CTRL(f3, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0);
                    end
                    `F3_AND: begin
                        `SET_CTRL(f3, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0);
                    end
                    `F3_OR: begin
                        `SET_CTRL(f3, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0);
                    end
                    `F3_XOR: begin
                        `SET_CTRL(f3, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0);
                    end
                    default: begin
                        `SET_CTRL(3'bx, 7'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx);  
                    end
                endcase
            end
            `OP_AUIPC: begin
                `SET_CTRL(f3, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0);
            end
            `OP_OP: begin
                case (f3)
                    `F3_ADD_SUB: begin
                        `SET_CTRL(f3, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
                    end
                    default: begin
                        `SET_CTRL(3'bx, 7'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx);  
                    end
                endcase
            end
            `OP_LOAD: begin
                `SET_CTRL(0, 0, 1, 0, 0, 0, 1, 0, f3, 1, 1);
            end
            `OP_STORE: begin
                `SET_CTRL(0, 0, 1, 0, 0, 0, 0, 1, f3, 0, 0);
            end
            `OP_BRANCH: begin
// ex_f3_s, ex_f7_s, ex_imm_sel_s, ex_pc_sel_s, ex_jmp_s, ex_br_s, mem_re_s, mem_wr_s, mem_f3_s, wb_reg_wr_s, wb_mem_sel_s
                `SET_CTRL(f3, f7, 1, 1, 0, 1, 0, 0, 0, 0, 0);
            end
            `OP_JAL: begin
// ex_f3_s, ex_f7_s, ex_imm_sel_s, ex_pc_sel_s, ex_jmp_s, ex_br_s, mem_re_s, mem_wr_s, mem_f3_s, wb_reg_wr_s, wb_mem_sel_s
                `SET_CTRL(0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0);
            end
            `OP_SYSTEM: begin
                `SET_CTRL(f3, f7, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            end
            default: begin 
                `SET_CTRL(3'bx, 7'bxx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx, 1'bx);
            end
        endcase
    end
end





    
endmodule