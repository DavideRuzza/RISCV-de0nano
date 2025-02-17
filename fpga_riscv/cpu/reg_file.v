`timescale 1ns/100ps 

`include "cpu/define.v"

module reg_file (
    input wire clk,
    input wire rst,

    input wire we,  // write enable
    input wire [`RegAddrBus] waddr,
    input wire [`DataBus   ] wdata,

    input wire re1, // read enable register 1
    input wire [`RegAddrBus] r1,
    output reg [`DataBus   ] d1,

    input wire re2, // read enable register 1
    input wire [`RegAddrBus] r2,
    output reg [`DataBus   ] d2

);

reg [`DataBus] reg_file [`RegNum-1:0];

integer i;
initial begin
	for(i=0; i<`RegNum; i=i+1) begin
        reg_file[i] = 0;
    end
end

always @(posedge clk) begin
    if (!rst) begin

        if (we && waddr!=0) begin
            reg_file[waddr] <= wdata;
        end
    end
end

// read register 1
always @(*) begin
    if (rst || r1==0) begin
        d1 <= 0;
    end else if (we && r1 == waddr) begin
        d1 <= wdata;
    end else begin
        d1 <= reg_file[r1];
    end
end

// read register 2
always @(*) begin
    if (rst || r2==0) begin
        d2 <= 0;
    end else if (we && r2 == waddr) begin
        d2 <= wdata;
    end else begin
        d2 <= reg_file[r2];
    end
end
endmodule