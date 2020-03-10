// module writeToMem ( input logic clk, 			// SM clock
//                     input logic reset, 			// reset bit
//                     input logic start,			// start signal for control 
//                     input logic [7:0] q, 		// data output from memory, used to verify successful write
//                     output logic [7:0] address, // address to write data to 
//                     output logic [7:0] data,	// data to address, for task one this will be equal to address 
//                     output logic write,			// write flag
//                     output logic done			// done flag
//                   );          
// 	// State variable 
// 	logic [1:0] state; 						

// 	// Possible states
// 	parameter 	START = 2'b00,	
// 			    ASSERT_WRITE = 2'b01, 
// 				VALIDATE = 2'b10;
	
// 	assign write = state[0];
	
//     always_ff @(posedge clk or posedge reset) begin 
//         if (reset) begin 
//                         state <= START; 
//                         address <= 8'b0;
//                         done <= 1'b0;	
//                    end
//         else 
//         case (state) 
//             START: 			if (start & ~done) state <= ASSERT_WRITE; 
//                             else state <= START; 
                                
//             ASSERT_WRITE: 	begin			
//                                 state <= VALIDATE; 
//                                 data <= address; 
//                             end 
//             VALIDATE: 		if (q == data) begin
//                                 state <= START; 
//                                 address ++; 
//                                 if (address == 8'b0)
//                                     done <= 1'b1; 
//                                 else 
//                                     done <= 1'b0; 
//                             end
//                             else 
//                                 state <= ASSERT_WRITE; 
//             default: state <= START; 
//         endcase
//     end 

// endmodule 

module s_initializer (
    input clk,
    input rst,
    input start,
    input logic [7:0] s_read_data,
    output logic [7:0]address,
    output logic [7:0]data,
    output logic s_mem_wren,
    output logic done
);

    parameter [4:0] INCREMENT = 5'b00_001; 
    parameter [4:0] WRITE_DATA = 5'b01_011;
    parameter [4:0] CONFIRM_DATA = 5'b00_100;
    parameter [4:0] IDLE = 5'b00_010;  
    parameter [4:0] DONE = 5'b10_011;

    logic [7:0]count = 8'b0;
    logic [4:0]state;

    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) begin
            count <= 8'b0;
            state <= IDLE;
        end

        else 
        begin
            case (state)
                IDLE :         begin
                                   state <= start ? WRITE_DATA : IDLE; 
                                   count <= 8'b0;
                               end 
                WRITE_DATA :   state <= CONFIRM_DATA;
                CONFIRM_DATA : begin
                                    if (s_read_data == count) state <= INCREMENT;
                                    else state <= WRITE_DATA;
                                 end
                INCREMENT :    begin 
                                   count <= count + 1'b1;
                                   state <= (count == 8'd255) ? DONE : WRITE_DATA;
                               end
                DONE :         state <= IDLE;
                default:       state <= IDLE;
            endcase
        end
    end

    always_comb 
    begin
         address = count;
         data = count;   
         done = state[4];
         s_mem_wren = state[3];
    end
endmodule