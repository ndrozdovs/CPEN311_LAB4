`timescale 1 ps / 1 ps
module ksa_tb();

    logic CLOCK_50; 
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [9:0] LEDR;
	logic [6:0] HEX0;
	logic [6:0] HEX1;
	logic [6:0] HEX2;
	logic [6:0] HEX3;
	logic [6:0] HEX4;
	logic [6:0] HEX5;

    ksa DUT(
	CLOCK_50, 
	KEY,
	SW,
	LEDR,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5
    );

    // Clock
    initial forever begin
        CLOCK_50 = 0; #5;
        CLOCK_50 = 1; #5;
    end


    initial begin
        // Wait to observe clock
        #11000;

	    $stop;
    end

    

endmodule