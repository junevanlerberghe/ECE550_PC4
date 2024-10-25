/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                   // I: Data from port B of regfile
);
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;

    /* YOUR CODE STARTS HERE */
	 
	 // Control Circuit
	 wire [4:0] opcode;
	 assign opcode = q_imem[31:27];
	 
	 wire ALUinB, Rdst, Rwd;
	 or(ALUinB, opcode[4], opcode[3], opcode[2], opcode[1], opcode[0]);
	 nor(Rdst, opcode[4], opcode[3], opcode[2], opcode[1], opcode[0]);
	 assign Rwd = opcode[1];
	 assign wren = opcode[3];
	 
	 //Imem
	 wire  isNotEqual_pc, isLessThan_pc, overflow_pc;
	 wire [11:0] adr_out;
	 wire [31:0] adr_out_32, imem_32;
	 
	 pc pc1(address_imem, clock, reset, adr_out);
	 assign adr_out_32 = { {20'b0}, adr_out};
	 alu alu_p4(adr_out_32, 32'd1, 5'b0, 5'b0, imem_32, isNotEqual_pc, isLessThan_pc, overflow_pc);
	 assign address_imem = imem_32[11:0];
		
	 //Regfile
	 wire [4:0] writeReg_normal;
	 assign ctrl_readRegA = q_imem[21:17];
	 assign ctrl_readRegB = q_imem[16:12];
	 or(ctrl_writeEnable, Rdst, opcode[0]);
	 //assign writeReg_normal = Rdst ? q_imem[26:22] : ctrl_readRegB; // Rdst ? rd : rt
	 assign writeReg_normal = q_imem[26:22];
	 
	 // ALU
	 wire [31:0] immed;
	 assign immed = { {15{q_imem[16]}}, q_imem[16:0]};
	 
	 wire [4:0] shamt, ALUop_r, ALUop;
	 wire [31:0] alu_input;
	 assign ALUop_r = q_imem[6:2];
	 assign shamt = q_imem[11:7];
	 
	 assign ALUop = ALUinB ? 5'b0 : ALUop_r;
	 assign alu_input = ALUinB ? immed : data_readRegB;
	 
	 wire isNotEqual, isLessThan, overflow;
	 wire [31:0] data_result;
	 alu alu1(data_readRegA, alu_input, ALUop,
			shamt, data_result, isNotEqual, isLessThan, overflow);
		
	 
	 // DMem
	 wire [31:0] data_writeReg_normal;
	 assign address_dmem = data_result[11:0];
	 assign data = data_readRegB;
			
	 assign data_writeReg_normal = Rwd ? q_dmem : data_result;
	 
	 // Overflow Check
	 wire [1:0] rstatus;
	 wire check_ovf;
	 check_overflow ovf(opcode, ALUop, check_ovf, rstatus);
	
	 assign data_writeReg = check_ovf ? (overflow ? rstatus : data_writeReg_normal) : data_writeReg_normal;
	 assign ctrl_writeReg = check_ovf ? (overflow ? 5'd30 : writeReg_normal) : writeReg_normal;

endmodule