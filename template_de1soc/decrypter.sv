module decrypter (
    input clk,
    input rst,
    input start,
    input [7:0]s_read_data,
    input [7:0]e_read_data,
    input [7:0]d_read_data,
    input [23:0] secret_key,
    output logic [7:0]address_s,
    output logic [7:0]address_e,
    output logic [7:0]address_d,
    output logic [7:0]data_s,
    output logic [7:0]data_d,
    output logic s_mem_wren,
    output logic d_mem_wren,
    output logic done
);

    parameter [11:0] IDLE = 12'b0000_0000_0010;  
    
    parameter [11:0] SI_RETRIEVE = 12'b0000_0000_0100;
    parameter [11:0] BULLSHIT_WAIT = 12'b0000_0000_1010;
    parameter [11:0] SI_RETRIEVE_WAIT = 12'b0000_0000_0101;
    parameter [11:0] GET_J = 12'b0000_0000_1001;
    parameter [11:0] SJ_RETRIEVE = 12'b0000_0000_0110;
    parameter [11:0] SJ_RETRIEVE_WAIT = 12'b0000_0000_0111;
    
    parameter [11:0] SI_STORE_NEW = 12'b0000_0001_1000;
    parameter [11:0] SI_STORE_NEW_CONFIRM = 12'b0000_0001_1001;
    parameter [11:0] SJ_STORE_NEW = 12'b0000_0001_1100;
    parameter [11:0] SJ_STORE_NEW_CONFIRM = 12'b0000_0001_1101;

    parameter [11:0] GET_F_ADDRESS = 12'b0010_0000_1010;
    parameter [11:0] BULLSHIT_WAIT_NEW = 12'b0000_0000_1011;
    parameter [11:0] F_RETRIEVE = 12'b0000_0000_1100;
    parameter [11:0] ENC_RETRIEVE = 12'b0000_0000_1101;
    parameter [11:0] BULLSHIT_WAIT_K = 12'b0000_0000_1110;
    parameter [11:0] ENC_RETRIEVE_WAIT = 12'b0000_0000_1111;
    parameter [11:0] D_STORE = 12'b0000_0010_0000;
    parameter [11:0] D_STORE_CONFIRM = 12'b0000_0010_0001;
    
    parameter [11:0] INCREMENT = 12'b0000_0000_1000;
    parameter [11:0] DONE = 12'b1000_0000_1011;
    

    logic [7:0] count;
    logic [11:0] state;
    logic [7:0] key_value;

    logic [7:0] index_i = 8'b0000_0001;
    logic [7:0] index_j = 8'b0;
    logic [7:0] index_k = 8'b0;
    logic [7:0] index_f = 8'b0;

    logic [7:0] si_data;
    logic [7:0] sj_data;
    logic [7:0] sf_data;
    logic [7:0] ek_data;
    
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) begin
            count <= 8'b0;
            state <= IDLE;
        end

        else 
        begin
            case (state)
                IDLE :                 state <= (start) ? SI_RETRIEVE : IDLE;
                SI_RETRIEVE :          begin 
                                           state <= BULLSHIT_WAIT;
                                           address_s <= index_i;
                                       end
                BULLSHIT_WAIT :        state <= SI_RETRIEVE_WAIT;
                SI_RETRIEVE_WAIT :     begin 
                                         state <= GET_J;
                                         address_s <= index_i;
                                         si_data <= s_read_data;
                                       end
                GET_J :                begin
                                         index_j = index_j + si_data;
                                         address_s = index_j;
                                         state = SJ_RETRIEVE;
                                       end
                SJ_RETRIEVE :          state <= SJ_RETRIEVE_WAIT;
                SJ_RETRIEVE_WAIT :     begin
                                         state <= SI_STORE_NEW;
                                         sj_data <= s_read_data;
                                       end
                SI_STORE_NEW :         begin
                                           state <= SI_STORE_NEW_CONFIRM;
                                           address_s <= index_i;
                                           data_s <= sj_data;
                                       end
                SI_STORE_NEW_CONFIRM : state <= (s_read_data == sj_data) ? SJ_STORE_NEW : SI_STORE_NEW;   
                SJ_STORE_NEW :         begin
                                           state <= SJ_STORE_NEW_CONFIRM;
                                           address_s <= index_j;
                                           data_s <= si_data;
                                       end
                SJ_STORE_NEW_CONFIRM : state <= (s_read_data == si_data) ? GET_F_ADDRESS : SJ_STORE_NEW;
                GET_F_ADDRESS :        begin
                                           index_f = si_data + sj_data;
                                           address_s = index_f;
                                           state <= BULLSHIT_WAIT_NEW;
                                       end
                BULLSHIT_WAIT_NEW :    state <= F_RETRIEVE;
                F_RETRIEVE :           begin 
                                           sf_data <= s_read_data;
                                           state <= ENC_RETRIEVE;
                                       end
                ENC_RETRIEVE :         begin
                                           address_e <= index_k;
                                           state <= BULLSHIT_WAIT_K;
                                       end
                BULLSHIT_WAIT_K :      state <= ENC_RETRIEVE_WAIT;
                ENC_RETRIEVE_WAIT :    begin
                                           ek_data <= e_read_data;
                                           state <= D_STORE;
                                       end 
                D_STORE :              begin
                                           state <= D_STORE_CONFIRM;
                                           address_d <= index_k;
                                           data_d <= sf_data ^ ek_data;
                                       end
                D_STORE_CONFIRM :          state <= (d_read_data == data_d) ? INCREMENT : D_STORE;
                INCREMENT :            begin
                                           index_i <= index_i + 1'b1;
                                           index_k <= index_k + 1'b1;
                                           state <= (index_k == 8'd31) ? DONE : SI_RETRIEVE;
                                       end
                DONE :                 state <= IDLE;
                default :              state <= IDLE;       
            endcase
        end
    end

    always_comb 
    begin
        done = state[11];
        s_mem_wren = state[4];
        d_mem_wren = state[5];
    end

endmodule