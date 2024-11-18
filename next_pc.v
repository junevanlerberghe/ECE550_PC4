module next_pc(input_pc, q_imem, isNotEqual, isLessThan, blt, bex, bne, jp, jr, data_readRegA, data_readRegB, output_pc);
	input [31:0] input_pc, data_readRegA, data_readRegB, q_imem;
	input blt, bne, jp, jr, isNotEqual, isLessThan, bex;
	
	output [31:0] output_pc;
	
	wire [31:0] immed, target;
	assign immed = { {15{q_imem[16]}}, q_imem[16:0]};
	assign target = { {5{1'b0}}, q_imem[26:0]};
	
	wire [31:0] pc_plus_1_N;
	wire isNotEqual_pc, isLessThan_pc, overflow_pc, isNotEqual_pc2, isLessThan_pc2, overflow_pc2;
	wire bex_or_result, bne_result, blt_result, branch_control, bex_control, isLessThan_result;
	wire [31:0] jp_result, jr_result, branch_pc_out;
	
	// adding pc + 1 + N
	alu alu_pc_one_N(input_pc, immed, 5'b0, 5'b0, pc_plus_1_N, isNotEqual_pc2, isLessThan_pc2, overflow_pc2);
	
	// bne and blt 
	not (isLessThan_result, isLessThan);
	and(bne_result, bne, isNotEqual);
	and(blt_result, blt, isLessThan_result, isNotEqual);
	or(branch_control, bne_result, blt_result);
	
	assign branch_pc_out = branch_control ? pc_plus_1_N : input_pc;
	
	// jump and jr
	
	assign jp_result = jp ? target : branch_pc_out;
	assign jr_result = jr ? data_readRegB : jp_result;
	
	// bex
	assign bex_or_result = | data_readRegA; 
	and(bex_control, bex, bex_or_result);
	assign output_pc = bex_control ? target : jr_result;
	
endmodule 