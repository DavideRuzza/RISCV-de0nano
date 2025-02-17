`ifndef DEFINES_V
`define DEFINED_V

`define RegAddrBus 4:0
`define RegNum 32


`define DataBus 31:0
`define InsAddrBus 31:0

`define OpBus 6:0
`define Funct7Bus 6:0
`define Funct3Bus 2:0
`define StallBus 4:0



`define OP_INVALID  7'b0000000
`define OP_LUI      7'b0110111
`define OP_LOAD     7'b0000011
`define OP_STORE    7'b0100011
`define OP_AUIPC    7'b0010111
`define OP_BRANCH   7'b1100011
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_OP       7'b0110011
`define OP_OP_IMM   7'b0010011
`define OP_MISC_MEM 7'b0001111   
`define OP_SYSTEM   7'b1110011


`define F3_ADD_SUB  3'b000
`define F3_SLL      3'b001
`define F3_SLT      3'b010 
`define F3_SLTU     3'b011
`define F3_XOR      3'b100
`define F3_SRX      3'b101
`define F3_OR       3'b110 
`define F3_AND      3'b111

`define F3_LB       3'b000
`define F3_LH       3'b001
`define F3_LW       3'b010
`define F3_LBU      3'b100
`define F3_LHU      3'b101

`define F3_SB       3'b000
`define F3_SH       3'b001
`define F3_SW       3'b010


// forwarding
`define NO_FORW     2'b00
`define EXMEM_FORW  2'b01
`define MEMWB_FORW  2'b10


`endif