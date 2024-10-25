module pc(data, clk, clr, result);
	input clk, clr;
	wire clr;
	input [11:0] data;
	
	output [11:0] result;
	
	genvar i;

	generate 
		for (i = 0; i < 12; i = i + 1) begin: dffe_loop
			dffe_ref dffe1(result[i], data[i], clk, 1'b1, clr);
		end
	endgenerate
	
endmodule
