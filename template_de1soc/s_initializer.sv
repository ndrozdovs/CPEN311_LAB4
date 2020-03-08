module s_initializer (
    input clk,
    input rst,
    input start,
    output logic [7:0]address,
    output logic [7:0]data,
    output logic s_mem_wren,
    output logic done
);

    parameter [4:0] INCREMENT = 5'b01_001; 
    parameter [4:0] INCREMENT_WAIT = 5'b01_011;
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
                IDLE :      state <= start ? INCREMENT : IDLE; 
                INCREMENT : begin
                                state = (count == 8'd255) ? DONE : INCREMENT_WAIT;
                                count = count + 8'd1;
                            end
                INCREMENT_WAIT : state = INCREMENT;
                DONE :      state <= IDLE;
                default:    state <= IDLE;
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