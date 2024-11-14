module controls(q_imem, ALUop, ALUinB, wren, ctrl_writeEnable, Rwd, Rdst, jal, jp, jr, bne, blt, bex, setx);
	input [31:0] q_imem;
	output [4:0] ALUop;
	output ALUinB, wren, ctrl_writeEnable, Rwd, Rdst, jal, jp, jr, bne, blt, bex, setx;

	wire [4:0] opcode;
	assign opcode = q_imem[31:27];
	
	wire add_sop, addi_sop, sw_sop, lw_sop, j_sop, bne_sop, jal_sop, jr_sop, blt_sop, bex_sop, setx_sop;
	and(add_sop, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
	and(addi_sop, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
	and(sw_sop, ~opcode[4], ~opcode[3], opcode[2], opcode[1], opcode[0]);
	and(lw_sop, ~opcode[4], opcode[3], ~opcode[2], ~opcode[1], ~opcode[0]);
	and(j_sop, ~opcode[4], ~opcode[3], ~opcode[2], ~opcode[1], opcode[0]);
	and(bne_sop, ~opcode[4], ~opcode[3], ~opcode[2], opcode[1], ~opcode[0]);
	and(jal_sop, ~opcode[4], ~opcode[3], ~opcode[2], opcode[1], opcode[0]);
	and(jr_sop, ~opcode[4], ~opcode[3], opcode[2], ~opcode[1], ~opcode[0]);
	and(blt_sop, ~opcode[4], ~opcode[3], opcode[2], opcode[1], ~opcode[0]);
	and(bex_sop, opcode[4], ~opcode[3], opcode[2], opcode[1], ~opcode[0]);
	and(setx_sop, opcode[4], ~opcode[3], opcode[2], ~opcode[1], opcode[0]);
	
	or(ALUinB, addi_sop, sw_sop, lw_sop);
	assign wren = sw_sop;
	or(ctrl_writeEnable, add_sop, addi_sop, lw_sop, jal_sop, setx_sop);
	or(Rdst, addi_sop, sw_sop, lw_sop, bne_sop, jr_sop, blt_sop);
	assign Rwd = lw_sop;
	assign jal = jal_sop;
	or(jp, jal_sop, j_sop);
	assign jr = jr_sop;
	assign bne = bne_sop;
	assign blt = blt_sop;
	assign bex = bex_sop;
	assign setx = setx_sop;
	
	wire [4:0] ALUop_r;
	
	wire alu_ctrl; 
	or(alu_ctrl, bne, blt);
	
	assign ALUop_r = alu_ctrl ? 5'd1 : q_imem[6:2];
	assign ALUop = ALUinB ? 5'b0 : ALUop_r;
	
endmodule
	
	