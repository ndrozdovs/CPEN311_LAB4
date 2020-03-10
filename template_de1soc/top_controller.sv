module top_controller (
    input clk,
    input rst,
    input start,
    input logic [23:0] starting_key,
    input logic [7:0] s_read_data,
    input logic [7:0] d_read_data, 
    input logic [7:0] e_read_data,

    output logic [7:0]address_s,
    output logic [7:0]address_d,
    output logic [7:0]address_e,
    output logic [7:0]data_s,
    output logic [7:0]data_d,
    output logic s_mem_wren,
    output logic d_mem_wren,
    output logic top_done,

    output logic [23:0] solved_key
);

    parameter [11:0] IDLE = 12'b0000_0000_0000;
    parameter [11:0] S_INIT = 12'b0000_0001_0000;
    parameter [11:0] S_SWAP = 12'b0000_0010_0000; 
    parameter [11:0] DECRYPTER = 12'b0000_0100_0000;
    parameter [11:0] DONE = 12'b1000_0000_0000;

    logic [11:0]state;

    // Instantiated state machine logic 
    logic s_init_start;
    logic s_init_done;
    logic s_init_wren;
    logic s_swap_start;
    logic s_swap_done;
    logic s_swap_wren;
    logic decr_start;
    logic decr_done;
    logic s_decr_wren;
    logic d_decr_wren;
    logic found_key;

    logic [7:0] s_decr_address;
    logic [7:0] s_decr_data;
    logic [7:0] e_decr_address;
    logic [7:0] d_decr_address;
    logic [7:0] d_decr_data;
    logic [7:0] s_init_address;
    logic [7:0] s_init_data;
    logic [7:0] s_swap_address;
    logic [7:0] s_swap_data;
	logic [23:0] secret_key = 24'b0;

    s_initializer init(clk, rst, s_init_start, s_read_data, s_init_address, s_init_data, s_init_wren, s_init_done);

	 s_swapper swap(clk, rst, s_swap_start, s_read_data, secret_key, s_swap_address, s_swap_data, s_swap_wren, s_swap_done);

    decrypter decr(clk, rst, decr_start, s_read_data, e_read_data, d_read_data, secret_key, s_decr_address, e_decr_address,
                   d_decr_address, s_decr_data, d_decr_data, s_decr_wren, d_decr_wren, found_key, decr_done);

    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) begin
            state <= IDLE;
        end

        else 
        begin
            case (state)
                IDLE :      begin
										state <= start ? S_INIT : IDLE; 
										secret_key <= starting_key;
									 end 
                S_INIT :    state <= s_init_done ? S_SWAP : S_INIT;
                S_SWAP :    state <= s_swap_done ? DECRYPTER : S_SWAP;
                DECRYPTER : begin 
                                if(decr_done && found_key) state <= DONE;
                                else if(decr_done && !found_key) 
                                begin
                                    if(secret_key == 24'b00111111_11111111_11111111) state <= DONE;
                                    else
                                    begin 
                                        secret_key <= secret_key + 1'b1;
                                        state <= S_INIT;
                                    end
                                end
                                else state <= DECRYPTER;
                            end
                DONE :      state <= DONE;  // STAY IN DONE FOR NOW, ONLY RUN ONCE
                default:    state <= IDLE;
            endcase
        end
    end

    always_comb 
    begin
        s_init_start = state[4];
        s_swap_start = state[5];
        decr_start = state[6];

        top_done = state[11];

        address_s <= state[4] ? s_init_address : (state[5] ? s_swap_address : (state[6] ? s_decr_address : 8'b0));
        data_s <= state[4] ? s_init_data : (state[5] ? s_swap_data : (state[6] ? s_decr_data : 8'b0));
        s_mem_wren <= state[4] ? s_init_wren : (state[5] ? s_swap_wren : (state[6] ? s_decr_wren : 1'b0));

        address_e <= state[6] ? e_decr_address : 8'b0;

        address_d <= state[6] ? d_decr_address : 8'b0;
        data_d <= state[6] ? d_decr_data : 8'b0;
        d_mem_wren <= state[6] ? d_decr_wren : 1'b0;

        solved_key = found_key ? secret_key : 23'b0;
    end
endmodule