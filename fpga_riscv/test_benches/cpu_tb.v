`timescale 1ns/100ps 

`include "cpu/define.v"

module cpu_tb();

reg clk;
reg rst;

parameter CLOCK_PERIOD = 10;


initial begin 
    clk = 0;  // Initialize clock to 0
    forever begin
        #5;clk = ~clk;  // Toggle clock every 5 time units (10 time units period)
    end
end

// ------------
reg [`StallBus] stall;

pc_reg pc_reg_0(
    .clk(clk),
    .rst(rst),
    .stall_i(stall),
    .br_addr(32'b0),
    .br_en(1'b0)
);

simple_async_memory #(
    .MEM_SIZE(256),
    .MEM_FILE("memory/Iram.hex")

) i_mem (
    .clk(clk),
    .rst(rst),
    .addr(pc_reg_0.pc),

    .re(1'b1),
    .we(1'b0)
);

if_id_reg if_id_reg_0(
    .clk(clk),
    .rst(rst),
    .stall_i(stall),
    .pc_i(pc_reg_0.pc),
    .ins_i(i_mem.data)
);

id_stage id_stage_0(
    .clk(clk),
    .rst(rst),
    .ins_i(if_id_reg_0.ins) 
);

id_ex_reg id_ex_reg_0(
    .clk(clk),
    .rst(rst),
    .stall_i(stall),

    .pc_i(if_id_reg_0.pc),

    .r1_i(id_stage_0.r1),
    .r2_i(id_stage_0.r2),
    .rd_i(id_stage_0.rd),
    .d1_i(id_stage_0.d1),
    .d2_i(id_stage_0.d2),
    .imm_i(id_stage_0.imm),

    .ex_f3_i(id_stage_0.ex_f3),
    .ex_f7_i(id_stage_0.ex_f7),
    .ex_imm_sel_i(id_stage_0.ex_imm_sel),
    .ex_pc_sel_i(id_stage_0.ex_pc_sel),
    .mem_re_i(id_stage_0.mem_re),
    .mem_wr_i(id_stage_0.mem_wr),
    .mem_f3_i(id_stage_0.mem_f3),
    .wb_reg_wr_i(id_stage_0.wb_reg_wr),
    .wb_mem_sel_i(id_stage_0.wb_mem_sel)
);

wire [`RegAddrBus] exmem_rd;
wire [`DataBus   ] exmem_alu;
wire               exmem_wb_reg_wr;

wire [`RegAddrBus] memwb_rd;
wire [`DataBus   ] memwb_wdata;
wire               memwb_wb_reg_wr;

ex_stage ex_stage_0(
    // .clk(clk),
    .rst(rst),
    .pc_i(id_ex_reg_0.pc),
    .r1_i(id_ex_reg_0.r1),
    .r2_i(id_ex_reg_0.r2),
    .rd_i(id_ex_reg_0.rd),
    .d1_i(id_ex_reg_0.d1),
    .d2_i(id_ex_reg_0.d2),
    .imm_i(id_ex_reg_0.imm),
    .ex_f3_i(id_ex_reg_0.ex_f3),
    .ex_f7_i(id_ex_reg_0.ex_f7),
    .ex_imm_sel_i(id_ex_reg_0.ex_imm_sel),
    .ex_pc_sel_i(id_ex_reg_0.ex_pc_sel),


    .exmem_rd_i(exmem_rd),
    .exmem_alu_i(exmem_alu),
    .exmem_wb_reg_wr_i(exmem_wb_reg_wr),
    .memwb_rd_i(memwb_rd),
    .memwb_wdata_i(memwb_wdata),
    .memwb_wb_reg_wr_i(memwb_wb_reg_wr)
);

ex_mem_reg ex_mem_reg_0(
    .clk(clk),
    .rst(rst),
    .stall_i(stall),

    .rd_i(id_ex_reg_0.rd),
    .alu_i(ex_stage_0.alu),
    .wdata_i(ex_stage_0.wdata),

    .mem_re_i(id_ex_reg_0.mem_re),
    .mem_wr_i(id_ex_reg_0.mem_wr),
    .mem_f3_i(id_ex_reg_0.mem_f3),
    .wb_reg_wr_i(id_ex_reg_0.wb_reg_wr),
    .wb_mem_sel_i(id_ex_reg_0.wb_mem_sel),

    .rd(exmem_rd),
    .alu(exmem_alu),
    .wb_reg_wr(exmem_wb_reg_wr)
);


simple_async_memory_v2 #(
    .MEM_SIZE(256),
    .MEM_FILE("memory/Dram.hex")

) d_mem (
    .clk(clk),
    .rst(rst),

    .addr({1'b0, ex_mem_reg_0.alu[30:0]}),
    .wdata_i(ex_mem_reg_0.wdata),
    .mem_re_i(ex_mem_reg_0.mem_re),
    .mem_wr_i(ex_mem_reg_0.mem_wr),
    .mem_f3_i(ex_mem_reg_0.mem_f3)
);


mem_wb_reg mem_wb_reg_0(
    .clk(clk),
    .rst(rst),
    .stall_i(stall),
    
    .rd_i(ex_mem_reg_0.rd),
    .alu_i(ex_mem_reg_0.alu),
    .d_mem_i(d_mem.data),
    .wb_reg_wr_i(ex_mem_reg_0.wb_reg_wr),
    .wb_mem_sel_i(ex_mem_reg_0.wb_mem_sel),

    // output
    .rd(memwb_rd),
    .wb_reg_wr(memwb_wb_reg_wr)
    // .wdata(memwb_wdata)
);

assign id_stage_0.reg_file_we_i = memwb_wb_reg_wr;
assign id_stage_0.reg_file_waddr_i = memwb_rd;

wb_stage wb_stage_0(
    .clk(clk),
    .rst(rst),
    .alu_i(mem_wb_reg_0.alu),
    .d_mem_i(mem_wb_reg_0.d_mem),
    .wb_mem_sel_i(mem_wb_reg_0.wb_mem_sel_i),
    .reg_data(memwb_wdata)
);

assign id_stage_0.reg_file_wdata_i = memwb_wdata;


initial begin
    // Initialize clock to 0
    $dumpfile("riscv_out.vcd");
    $dumpvars(0, cpu_tb);

    stall = 4'b0;
    
    rst = 1; #10; 
    rst = 0; #10;
    #350;


    
    $finish; // End simulation
end

endmodule