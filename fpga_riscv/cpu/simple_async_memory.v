`include "cpu/define.v"

module simple_async_memory #(
    
    parameter MEM_SIZE=256,
    parameter MEM_FILE="ram.hex"

) (
    input wire               clk,
    input wire               rst,

    input wire               re, // read enable
    input wire               we, // write enable
    input wire [`InsAddrBus] addr,
    input wire [`DataBus   ] data_i,
    
    output reg [`DataBus   ] data
);

reg [`DataBus] mem [0:MEM_SIZE-1];

initial begin
    $readmemh(MEM_FILE, mem);   
end

always @ (negedge clk or addr) begin
    if (!rst && re) begin
        data = mem[addr>>2];
    end else begin
        data = 0;
    end
end

// assign data = (rst && re) ? 32'b0 : mem[add>>2];

always @ (posedge clk) begin
    if (!rst && we) begin
        mem[addr>>2] <= data_i;

    end
end

endmodule