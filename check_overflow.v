module check_overflow(opcode, ALUop, check_ovf, rstatus);
	input [4:0] ALUop, opcode;
	output check_ovf;
	output [1:0] rstatus;

	wire [1:0] rstatus, add_sub;
	assign add_sub = ALUop[0] ? 2'b11 : 2'b01;
	assign rstatus = opcode[0] ? 2'b10 : add_sub;
	 
	wire check_ovf, check_ovf1, check_ovf2, check_ovf3, check_ovf4, check_ovf5;
	nor(check_ovf1, opcode[4], opcode[3], opcode[2], opcode[1], opcode[0], ALUop[4], ALUop[3], ALUop[2], ALUop[1], ALUop[0]);
	and(check_ovf2, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
	nor(check_ovf3, opcode[4], opcode[3], opcode[2], opcode[1], opcode[0]);
	and(check_ovf4, ~ALUop[4], ~ALUop[3], ~ALUop[2], ~ALUop[1], ALUop[0]);
	and(check_ovf5, check_ovf3, check_ovf4);
	or(check_ovf, check_ovf1, check_ovf2, check_ovf5);
endmodule
