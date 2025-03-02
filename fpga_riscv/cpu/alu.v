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
    output wire v_sub, // overflow of subtraction
    output wire n // negative
    
);
    
reg [SIZE:0] alu_arithm;
assign alu = alu_arithm[SIZE-1:0];





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