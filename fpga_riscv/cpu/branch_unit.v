`include "cpu/define.v"

module branch_unit #(
    parameter SIZE=32
) (
    input wire rst,
    input wire [`Funct3Bus] br_f3_i, // operation select for alu
    input wire [SIZE-1:0  ] op1_i,
    input wire [SIZE-1:0  ] op2_i,

    output reg branch_taken
    // output wire c, // carry out
    // output wire z, // zero
    // output wire v_sub, // overflow of subtraction
    // output wire n // negative
);

wire [SIZE-1:0] op2_n = (~op2_i)+1;
wire [SIZE:0] alu_arithm = op1_i + op2_n;
wire [SIZE-1:0] sub_s = alu_arithm[SIZE-1:0];

// flags
assign c = alu_arithm[SIZE];
assign n = alu_arithm[SIZE-1];
assign z = (alu_arithm[SIZE-1:0]==0);
assign v_sub = (op1_i[SIZE-1] & op2_n[SIZE-1] & !sub_s[SIZE-1]) | (!op1_i[SIZE-1] & !op2_n[SIZE-1] & sub_s[SIZE-1]);


always @(*) begin
    if (rst) begin
        branch_taken <= 0;
    end else begin
        case (br_f3_i)
            `F3_BR_BEQ: branch_taken <= (z==1);
            `F3_BR_BNE: branch_taken <= (z==0);
            `F3_BR_BLT: branch_taken <= ((n^v_sub)&(op2_n!=op2_i));
            `F3_BR_BGE: branch_taken <= !((n^v_sub)&(op2_n!=op2_i));
            `F3_BR_BLTU: branch_taken <= (c==1);
            `F3_BR_BGEU: branch_taken <= (c==0);
            default: branch_taken <= 0;
        endcase
    end
end
// wire [4:0] flags = {c, n, z, v};

// wire beq = (z==1);
// wire bne = (z==0);
// wire blt = ((n^v_sub)&(op2_n!=op2_i));
// wire bge = (!blt);
// wire bltu = (c==1);
// wire bgeu = (c==0);

endmodule