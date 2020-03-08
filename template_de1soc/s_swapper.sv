module s_swapper (
    input clk,
    input rst,
    input start,
    input [7:0]s_data,
    input [23:0] secret_key,
    output logic [7:0]address,
    output logic [7:0]data,
    output logic s_mem_wren,
    output logic done
);

    parameter [7:0] IDLE = 8'b0000_0010;  
    parameter [7:0] SI_RETRIEVE = 8'b0000_0100;
    parameter [7:0] SI_RETRIEVE_WAIT = 8'b0000_0101;
    parameter [7:0] SJ_RETRIEVE = 8'b0000_0110;
    parameter [7:0] SJ_RETRIEVE_WAIT = 8'b0000_0111;
    
    parameter [7:0] SI_STORE_NEW = 8'b0001_1000;
    parameter [7:0] SI_STORE_NEW_WAIT = 8'b0001_1001;
    parameter [7:0] SJ_STORE_NEW = 8'b0001_1100;
    parameter [7:0] SJ_STORE_NEW_WAIT = 8'b0001_1101;
    
    parameter [7:0] DONE = 8'b1000_1011;

    logic [7:0] count;
    logic [7:0] state;
    logic [7:0] key_value;

    logic [7:0] index_i = 8'b0;
    logic [7:0] index_j = 8'b0;

    logic [7:0] si_data;
    logic [7:0] sj_data;
    
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) begin
            count <= 8'b0;
            state <= IDLE;
        end

        else 
        begin
            case (state)
                IDLE :              state = (start) ? SI_RETRIEVE : IDLE;
                SI_RETRIEVE :       begin
                                      index_i = index_i + 8'd1;
                                      if (index_i == 8'd256) state = IDLE;
                                      else state = SI_RETRIEVE_WAIT;
                                    end
                SI_RETRIEVE_WAIT :  begin 
                                      state = SJ_RETRIEVE;
                                      si_data = s_data;
                                    end
                SJ_RETRIEVE :       begin
                                      state = SJ_RETRIEVE_WAIT;
                                      if ((index_i % 8'd3) == 8'd0) key_value = secret_key[23:16];
                                      else if ((index_i % 8'd3) == 8'd1) key_value = secret_key[15:8];
                                      else if ((index_i % 8'd3) == 8'd2) key_value = secret_key[7:0];
                                      index_j = index_j + si_data + key_value;
                                    end
                SJ_RETRIEVE_WAIT :  begin
                                      state = SI_STORE_NEW;
                                      sj_data = s_data;
                                    end
                SI_STORE_NEW :      begin
                                      state = SI_STORE_NEW_WAIT;
                                    end
                SI_STORE_NEW_WAIT : state <= SJ_STORE_NEW;   
                SJ_STORE_NEW :      state <= SJ_STORE_NEW_WAIT;
                SJ_STORE_NEW_WAIT : state <= SI_RETRIEVE;                             
                default :           state <= IDLE;       
            endcase
        end
    end

    always_comb 
    begin
        done = state[7];
        s_mem_wren = state[4];
    end

    // address and data assignment logic
    always_ff @(posedge clk)
    begin
        if ((state == SI_RETRIEVE) || (state == SI_RETRIEVE_WAIT))   address <= index_i;        // If retrieving SI, look in index i
        else if ((state == SJ_RETRIEVE) || (state == SJ_RETRIEVE_WAIT))  address <= index_j;    // If retrieving SJ, look in index j
        else if ((state == SI_STORE_NEW) || (state == SI_STORE_NEW_WAIT))                       // If storing new value into SI, look in index i and use data from SJ
        begin 
            address <= index_i;
            data <= sj_data;
        end
        else if ((state == SJ_STORE_NEW) || (state == SJ_STORE_NEW))                            // If storing new value into SJ, look in index j and use data from SI
        begin 
            address <= index_j;
            data <= si_data;
        end
    end

endmodule