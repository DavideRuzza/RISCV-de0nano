`include "cpu/define.v"

module simple_async_memory_v2 #(
    
    parameter MEM_SIZE=256,
    parameter MEM_FILE="ram.hex"

) (
    input wire               clk,
    input wire               rst,

    input wire               mem_re_i, // read enable
    input wire               mem_wr_i, // write enable
    input wire [`InsAddrBus] addr,
    input wire [`DataBus   ] wdata_i,

    output reg [`DataBus   ] data,

    input wire [`Funct3Bus ] mem_f3_i
);

reg [7:0] mem [0:MEM_SIZE*4-1];


wire [3:0] unique_f3 = {mem_wr_i, mem_f3_i};

initial begin
    $readmemh(MEM_FILE, mem);
end

always @(*) begin
    if (rst) begin
        data = 32'b0;
    end else if (mem_re_i) begin
        case (mem_f3_i)  // Lettura allineata su 4 byte
            `F3_LW: data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]}; // Word intera
            `F3_LH: data = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};  // Halfword allineata
            `F3_LB: data = {{24{mem[addr][7]}}, mem[addr]};  // Byte singolo
            `F3_LBU: data = {24'b0, mem[addr]};
            `F3_LHU: data = {16'b0, mem[addr+1], mem[addr]};
            default: data = 32'bx; // Caso non valido (mai raggiunto con indirizzi validi)
        endcase
    end else begin
        data = 32'b0;  // Se read è basso, restituisco 0
    end
end

always @(posedge clk) begin
    if (!rst && mem_wr_i) begin
        case (mem_f3_i)
            `F3_SB: mem[addr]   <= wdata_i[7:0];  // Scrittura di 1 byte
            `F3_SH: begin  // Scrittura di 1 halfword
                mem[addr]   <= wdata_i[7:0];
                mem[addr+1] <= wdata_i[15:8];
            end
            `F3_SW: begin  // Scrittura di 1 word intera
                mem[addr]   <= wdata_i[7:0];
                mem[addr+1] <= wdata_i[15:8];
                mem[addr+2] <= wdata_i[23:16];
                mem[addr+3] <= wdata_i[31:24];
            end
        endcase
    end
end

endmodule