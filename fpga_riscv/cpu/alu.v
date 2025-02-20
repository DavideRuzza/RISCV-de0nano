`include "cpu/define.v"


module alu #(
    parameter SIZE=32
) (
    input wire rst,
    input wire [`Funct3Bus ] f3_i, // operation select for alu
    input wire [`Funct7Bus ] f7_i, // operation select for alu
    input wire [SIZE-1:0   ] op1_i,
    input wire [SIZE-1:0   ] op2_i,

    output wire [SIZE-1:0  ] alu,

    output wire c, // carry out
    output wire z, // zero
    output wire v, // overflow
    output wire n // negative
    
);
    
reg [SIZE:0] alu_arithm;
wire [SIZE-1:0] op2_n = (~op2_i)+4'b0001;

assign alu = alu_arithm[SIZE-1:0];
assign c = alu_arithm[SIZE];
assign n = alu_arithm[SIZE-1];
assign z = (alu==0);

wire [SIZE-1:0] sub_s = op1_i+op2_n;

assign v = (op1_i[SIZE-1] & op2_i[SIZE-1] & !alu[SIZE-1]) | (!op1_i[SIZE-1] & !op2_i[SIZE-1] & alu[SIZE-1]);
assign v_s = (op1_i[SIZE-1] & op2_n[SIZE-1] & !sub_s[SIZE-1]) | (!op1_i[SIZE-1] & !op2_n[SIZE-1] & sub_s[SIZE-1]);


wire [4:0] flags = {c, n, z, v};
wire beq = (z==1);
wire bne = (z==0);
wire blt = (n!=v_s && c==v_s);
wire bge = (z==0);
wire bltu = (c==1);
wire bgeu = (c==0);

wire v_0 = !(v^v_s);

// ALU
always @(*) begin
    if (rst) begin
        alu_arithm <= 0;
    end else begin
        case (f3_i)
            `F3_ADD_SUB: begin
                if (f7_i == 7'b0100000) begin
                    alu_arithm <= op1_i-op2_i;
                end else begin
                    alu_arithm <= op1_i+op2_i;
                end
            end
            `F3_AND: begin
                alu_arithm <= op1_i&op2_i;
            end
            `F3_OR: begin
                alu_arithm <= op1_i|op2_i;
            end
            `F3_XOR: begin
                alu_arithm <= op1_i^op2_i;
            end
            default: alu_arithm <= 32'bx;
        endcase
    end
end

endmodule