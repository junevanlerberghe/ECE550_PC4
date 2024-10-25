module clk_div4(clk_in, reset, clk_out);
	input clk_in, reset;
	output clk_out;
	
	wire [1:0] d;
	wire clk_half;
	dffe_ref dff0(clk_half, d[0], clk_in, 1'b1, reset);
	dffe_ref dff1(clk_out, d[1], clk_half, 1'b1, reset);

	assign d[0] = ~clk_half;
	assign d[1] = ~clk_out;
endmodule 
