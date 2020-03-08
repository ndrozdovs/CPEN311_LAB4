module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

	input CLOCK_50;
	input [3:0] KEY;
	output [9:0] SW, LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	logic clk, reset_n, write_en, s_init_rst, top_done;
	logic [7:0] address_s, data_s, s_read_data;
	
	assign clk = CLOCK_50;
    assign reset_n = KEY[3];
		
	SevenSegmentDisplayDecoder sevenSeg(ssOut, nIn);
	
	s_memory s_mem(address_s, clk, data_s, write_en, s_read_data);
	
	top_controller top_c(clk, s_init_rst, 1'b1, s_read_data, address_s, data_s, write_en, top_done);

endmodule