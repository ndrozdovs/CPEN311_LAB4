module s_swapper (
    input clk,
    input rst,
    input start,
    input [7:0] s_data,
    input logic [23:0] secret_key,
    output logic [7:0]address,
    output logic [7:0]data,
    output logic s_mem_wren,
    output logic done
);

    parameter [7:0] IDLE = 8'b0000_0010;  
    
    parameter [7:0] SI_RETRIEVE = 8'b0000_0100;
    parameter [7:0] SI_RETRIEVE_WAIT = 8'b0000_0101;
    parameter [7:0] GET_J = 8'b0000_1001;
    parameter [7:0] SJ_RETRIEVE = 8'b0000_0110;
    parameter [7:0] SJ_RETRIEVE_WAIT = 8'b0000_0111;
    
    parameter [7:0] SI_STORE_NEW = 8'b0001_1000;
    parameter [7:0] SI_STORE_NEW_CONFIRM = 8'b0001_1001;
    parameter [7:0] SJ_STORE_NEW = 8'b0001_1100;
    parameter [7:0] SJ_STORE_NEW_CONFIRM = 8'b0001_1101;
    
    parameter [7:0] INCREMENT_I = 8'b0000_1000;
    parameter [7:0] DONE = 8'b1000_1011;
    
    parameter [7:0] BULLSHIT = 8'b0000_1010;

    logic [7:0] state;
    logic [7:0] key_value;

    logic [7:0] index_i = 8'b0;
    logic [7:0] index_j = 8'b0;

    logic [7:0] si_data;
    logic [7:0] sj_data;
    
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) begin
            index_i = 8'b0;
            index_j = 8'b0;
            state <= IDLE;
        end

        else 
        begin
            case (state)
                IDLE :                 begin 
                                           state <= (start) ? SI_RETRIEVE : IDLE;
                                           index_i <= 8'b0;
                                           index_j <= 8'b0;
                                       end
                SI_RETRIEVE :          begin 
                                           state <= BULLSHIT;
                                           address <= index_i;
                                       end
                BULLSHIT :        state <= SI_RETRIEVE_WAIT;
                SI_RETRIEVE_WAIT :     begin 
                                         state <= GET_J;
                                         address <= index_i;
                                         si_data <= s_data;
                                       end
                GET_J :                begin
                                         if ((index_i % 8'd3) == 8'd0) key_value = secret_key[23:16];
                                         else if ((index_i % 8'd3) == 8'd1) key_value = secret_key[15:8];
                                         else if ((index_i % 8'd3) == 8'd2) key_value = secret_key[7:0];
                                         index_j = index_j + si_data + key_value;
                                         address = index_j;
                                         state = SJ_RETRIEVE;
                                       end
                SJ_RETRIEVE :          state <= SJ_RETRIEVE_WAIT;
                SJ_RETRIEVE_WAIT :     begin
                                         state <= SI_STORE_NEW;
                                         sj_data <= s_data;
                                       end
                SI_STORE_NEW :         begin
                                           state <= SI_STORE_NEW_CONFIRM;
                                           address <= index_i;
                                           data <= sj_data;
                                       end
                SI_STORE_NEW_CONFIRM : state <= (s_data == sj_data) ? SJ_STORE_NEW : SI_STORE_NEW;   
                SJ_STORE_NEW :         begin
                                           state <= SJ_STORE_NEW_CONFIRM;
                                           address <= index_j;
                                           data <= si_data;
                                       end
                SJ_STORE_NEW_CONFIRM : state <= (s_data == si_data) ? INCREMENT_I : SJ_STORE_NEW;
                INCREMENT_I :          begin
                                           index_i <= index_i + 1'b1;
                                           state <= (index_i == 8'd255) ? DONE : SI_RETRIEVE;
                                       end
                DONE :                 state <= IDLE;
                default :              state <= IDLE;       
            endcase
        end
    end

    always_comb 
    begin
        done = state[7];
        s_mem_wren = state[4];
    end

endmodule