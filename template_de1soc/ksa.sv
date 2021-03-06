module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

	input CLOCK_50;
	input [3:0] KEY;
	output [9:0] SW, LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	logic clk, reset_n, write_en_s, write_en_d, s_init_rst, top_done;
	logic [7:0] address_s, data_s, s_read_data, address_d, data_d, d_read_data, address_e, e_read_data;
	logic [9:0] LED;
	logic [7:0] Seven_Seg_Val[5:0];
	
	assign clk = CLOCK_50;
    assign reset_n = KEY[3];
		
	SevenSegmentDisplayDecoder sevenSeg(ssOut, nIn);
	
	s_memory s_mem(address_s, clk, data_s, write_en_s, s_read_data);

	d_memory d_mem(address_d, clk, data_d, write_en_d, d_read_data);

	e_rom rom(address_e, clk, e_read_data);
	
	top_controller top_c(clk, s_init_rst, 1'b1, s_read_data, d_read_data, e_read_data, address_s, address_d, address_e,
						 data_s, data_d, LED, write_en_s, write_en_d, top_done, Seven_Seg_Val);

	assign LEDR = LED;

	assign HEX0 = Seven_Seg_Val[0];
    assign HEX1 = Seven_Seg_Val[1];
    assign HEX2 = Seven_Seg_Val[2];
    assign HEX3 = Seven_Seg_Val[3];
    assign HEX4 = Seven_Seg_Val[4];
    assign HEX5 = Seven_Seg_Val[5];

endmodule