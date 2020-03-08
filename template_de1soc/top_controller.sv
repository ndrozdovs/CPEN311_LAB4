module top_controller (
    input clk,
    input rst,
    input start,
    input logic [7:0] s_read_data,

    output logic [7:0]address,
    output logic [7:0]data,
    output logic s_mem_wren,
    output logic done
);

    parameter [11:0] IDLE = 12'b0000_0000_0000;
    parameter [11:0] S_INIT = 12'b0000_0001_0000;
    parameter [11:0] S_SWAP = 12'b0000_0010_0000; 
    parameter [11:0] DONE = 12'b1000_0000_0000;

    logic [11:0]state;

    // Instantiated state machine logic 
    logic s_init_start;
    logic s_init_done;
    logic s_init_wren;
    logic s_swap_start;
    logic s_swap_done;
    logic s_swap_wren;
    logic [7:0] s_init_address;
    logic [7:0] s_init_data;
    logic [7:0] s_swap_address;
    logic [7:0] s_swap_data;

    s_initializer init(clk, rst, s_init_start, s_read_data, s_init_address, s_init_data, s_init_wren, s_init_done);

	s_swapper swap(clk, rst, s_swap_start, s_read_data, 24'b00000000_00000010_01001001, s_swap_address, s_swap_data, s_swap_wren, s_swap_done);

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
                S_SWAP :    state <= s_swap_done ? DONE : S_SWAP;
                DONE :      state <= DONE;  // STAY IN DONE FOR NOW, ONLY RUN ONCE
                default:    state <= IDLE;
            endcase
        end
    end

    always_comb 
    begin
        s_init_start = state[4];
        s_swap_start = state[5];
        done = state[11];

        address <= state[4] ? s_init_address : (state[5] ? s_swap_address : 8'b0);
        data <= state[4] ? s_init_data : (state[5] ? s_swap_data : 8'b0);
        s_mem_wren <= state[4] ? s_init_wren : (state[5] ? s_swap_wren : 1'b0);
    end
endmodule