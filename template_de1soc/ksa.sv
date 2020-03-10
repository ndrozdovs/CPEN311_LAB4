module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

	input CLOCK_50;
	input [3:0] KEY;
	output [9:0] SW, LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	logic clk, reset_n, write_en_s, write_en_d, s_init_rst, top_done;
	logic [7:0] address_s, data_s, s_read_data, address_d, data_d, d_read_data, address_e, e_read_data;
	logic [9:0] LED;
	logic [7:0] Seven_Seg_Val[5:0];
	logic [23:0] solved_secret_key;
	
	assign clk = CLOCK_50;
    assign reset_n = KEY[3];

	multicore_controller multicore_c(
		clk,
		reset_n,
		LED,
		solved_secret_key
	);	

	assign LEDR = LED;


	SevenSegmentDisplayDecoder sevenSeg0(Seven_Seg_Val[0], solved_secret_key[3:0]);
    SevenSegmentDisplayDecoder sevenSeg1(Seven_Seg_Val[1], solved_secret_key[7:4]);
    SevenSegmentDisplayDecoder sevenSeg2(Seven_Seg_Val[2], solved_secret_key[11:8]);
    SevenSegmentDisplayDecoder sevenSeg3(Seven_Seg_Val[3], solved_secret_key[15:12]);
    SevenSegmentDisplayDecoder sevenSeg4(Seven_Seg_Val[4], solved_secret_key[19:16]);
    SevenSegmentDisplayDecoder sevenSeg5(Seven_Seg_Val[5], solved_secret_key[23:20]);

	assign HEX0 = Seven_Seg_Val[0];
    assign HEX1 = Seven_Seg_Val[1];
    assign HEX2 = Seven_Seg_Val[2];
    assign HEX3 = Seven_Seg_Val[3];
    assign HEX4 = Seven_Seg_Val[4];
    assign HEX5 = Seven_Seg_Val[5];

endmodule