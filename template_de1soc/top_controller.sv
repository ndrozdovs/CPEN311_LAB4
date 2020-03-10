module top_controller (
    input clk,
    input rst,
    input start,
    input logic [7:0] s_read_data,
    input logic [7:0] d_read_data, 
    input logic [7:0] e_read_data,

    output logic [7:0]address_s,
    output logic [7:0]address_d,
    output logic [7:0]address_e,
    output logic [7:0]data_s,
    output logic [7:0]data_d,
    output logic [9:0]LED,
    output logic s_mem_wren,
    output logic d_mem_wren,
    output logic top_done,

    output [7:0] Seven_Seg_Val[5:0]
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
	logic [23:0] secret_key = 24'b00000000_00000000_00000000;

    SevenSegmentDisplayDecoder sevenSeg0(Seven_Seg_Val[0], secret_key[3:0]);
    SevenSegmentDisplayDecoder sevenSeg1(Seven_Seg_Val[1], secret_key[7:4]);
    SevenSegmentDisplayDecoder sevenSeg2(Seven_Seg_Val[2], secret_key[11:8]);
    SevenSegmentDisplayDecoder sevenSeg3(Seven_Seg_Val[3], secret_key[15:12]);
    SevenSegmentDisplayDecoder sevenSeg4(Seven_Seg_Val[4], secret_key[19:16]);
    SevenSegmentDisplayDecoder sevenSeg5(Seven_Seg_Val[5], secret_key[23:20]);

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
                IDLE :      state <= start ? S_INIT : IDLE; 
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

        LED[9:8] <= (found_key && state[11]) ? 2'b10 : ((!found_key && state[11]) ? 2'b01 : 2'b00);
        LED[7] <= (top_done && found_key); 
        LED[6] <= top_done;
        LED[5] <= found_key;
    end
endmodule