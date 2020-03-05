module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input CLOCK_50;
	input [3:0] KEY;
	output [9:0] SW, LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic clk, reset_n;
	logic [7:0] address_s, data_s;
	integer i;
	
	assign clk = CLOCK_50;
   assign reset_n = KEY[3];
		
	SevenSegmentDisplayDecoder sevenSeg(ssOut, nIn);
	
	s_memory s_mem(address_s, clk, data_s, 1'b1, 8'b0);
	
	always @(posedge clk) begin
		if(i < 256) begin
			address_s = address_s + 1;
			data_s = data_s + 1;
			i = i + 1;
		end
	end

endmodule