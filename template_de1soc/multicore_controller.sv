module multicore_controller(
    input clk,
    input reset_n,

    output logic [9:0]LED,
    output logic [23:0] solved_selected_secret_key
    );

    // Number of cores to instantiate
    //parameter num_cores = 4;

    logic cores_start;

    //logic [23:0] starting_secret_key [num_cores:0];
    
    //logic [23:0] num = 24'b00111111_11111111_11111111;
    //logic [23:0] some;

    logic [3:0]core_rst;

    //assign some = num / num_cores;

    logic [23:0] solved_secret_key [3:0] ;

    logic [23:0]starting_secret_key[3:0] ;
				
    

    assign starting_secret_key[0] = 24'b0;
    assign starting_secret_key[1] = 24'hfffff;
    assign starting_secret_key[2] = 24'h1ffffe;
    assign starting_secret_key[3] = 24'h2ffffd;


    // Stop peripheral cores when one solves the key
    always_comb
	 begin
        core_rst[0] = (top_done_2 | top_done_3 | top_done_4); //(top_done_1 || top_done_2 || top_done_3 || top_done_4) ? ~{top_done_1, top_done_2, top_done_3, top_done_4} : 4'b0;
        core_rst[1] = (top_done_1 | top_done_3 | top_done_4);
        core_rst[2] = (top_done_1 | top_done_2 | top_done_4);
        core_rst[3] = (top_done_1 | top_done_2 | top_done_3);
        cores_start = (top_done_1 || top_done_2 || top_done_3 || top_done_4) ? 1'b0 : 1'b1;
	 end

    // Assign apropriate solved key to output
    always_comb
    begin
        case({top_done_1, top_done_2, top_done_3, top_done_4})
            4'b1000 : solved_selected_secret_key <= solved_secret_key[0];
            4'b0100 : solved_selected_secret_key <= solved_secret_key[1];
            4'b0010 : solved_selected_secret_key <= solved_secret_key[2];
            4'b0001 : solved_selected_secret_key <= solved_secret_key[3];
            default : solved_selected_secret_key <= 24'b0;
		endcase
    end


    
    // ------------- CORE 1 ----------------
    logic write_en_s_1, write_en_d_1, top_done_1;
    logic [7:0] address_s_1, data_s_1, s_read_data_1, address_d_1, data_d_1, d_read_data_1, address_e_1, e_read_data_1;

    s_memory s_mem_1(address_s_1, clk, data_s_1, write_en_s_1, s_read_data_1);

    d_memory d_mem_1(address_d_1, clk, data_d_1, write_en_d_1, d_read_data_1);
        
    e_rom rom_1(address_e_1, clk, e_read_data_1);
    
    top_controller core_1(clk, core_rst[0], cores_start, starting_secret_key[0], s_read_data_1, d_read_data_1, e_read_data_1, address_s_1, address_d_1, address_e_1,
                        data_s_1, data_d_1, write_en_s_1, write_en_d_1, top_done_1, solved_secret_key[0]);

    // ------------- CORE 2 ----------------
    logic write_en_s_2, write_en_d_2, top_done_2;
    logic [7:0] address_s_2, data_s_2, s_read_data_2, address_d_2, data_d_2, d_read_data_2, address_e_2, e_read_data_2;

    s_memory s_mem_2(address_s_2, clk, data_s_2, write_en_s_2, s_read_data_2);

    d_memory d_mem_2(address_d_2, clk, data_d_2, write_en_d_2, d_read_data_2);
        
    e_rom rom_2(address_e_2, clk, e_read_data_2);
    
    top_controller core_2(clk, core_rst[1], cores_start, starting_secret_key[1], s_read_data_2, d_read_data_2, e_read_data_2, address_s_2, address_d_2, address_e_2,
                        data_s_2, data_d_2, write_en_s_2, write_en_d_2, top_done_2, solved_secret_key[1]);

    // ------------- CORE 3 ----------------
    logic write_en_s_3, write_en_d_3, top_done_3;
    logic [7:0] address_s_3, data_s_3, s_read_data_3, address_d_3, data_d_3, d_read_data_3, address_e_3, e_read_data_3;

    s_memory s_mem_3(address_s_3, clk, data_s_3, write_en_s_3, s_read_data_3);

    d_memory d_mem_3(address_d_3, clk, data_d_3, write_en_d_3, d_read_data_3);
        
    e_rom rom_3(address_e_3, clk, e_read_data_3);
    
    top_controller core_3(clk, core_rst[2], cores_start, starting_secret_key[2], s_read_data_3, d_read_data_3, e_read_data_3, address_s_3, address_d_3, address_e_3,
                        data_s_3, data_d_3, write_en_s_3, write_en_d_3, top_done_3, solved_secret_key[2]);

    // ------------- CORE 4 ----------------
    logic write_en_s_4, write_en_d_4, top_done_4;
    logic [7:0] address_s_4, data_s_4, s_read_data_4, address_d_4, data_d_4, d_read_data_4, address_e_4, e_read_data_4;

    s_memory s_mem_4(address_s_4, clk, data_s_4, write_en_s_4, s_read_data_4);

    d_memory d_mem_4(address_d_4, clk, data_d_4, write_en_d_4, d_read_data_4);
        
    e_rom rom_4(address_e_4, clk, e_read_data_4);
    
    top_controller core_4(clk, core_rst[3], cores_start, starting_secret_key[3], s_read_data_4, d_read_data_4, e_read_data_4, address_s_4, address_d_4, address_e_4,
                        data_s_4, data_d_4, write_en_s_4, write_en_d_4, top_done_4, solved_secret_key[3]);


    // LED output logic
    assign LED[9] = (top_done_1 || top_done_2 || top_done_3 || top_done_4) ? 1'b1 : 1'b0;



    //------------CORE MEMORY AND CONTROLLER GENERATION-------------
    // genvar i;
    // generate
    //     for (i = 0; i < num_cores; i = i + 1) begin : core_generator   
	// 			logic [23:0]starting_secret_key_[i];
				
	// 			if (i == 0)
	// 				assign starting_secret_key_[i] = 24'b0;
	// 			else
	// 				assign starting_secret_key_[i] = starting_secret_key_[i-1] + some;
		  
    //         logic write_en_s_[i], write_en_d_[i], core_rst_[i], top_done_[i];
	//          logic [7:0] address_s_[i], data_s_[i], s_read_data_[i], address_d_[i], data_d_[i], d_read_data_[i], address_e_[i], e_read_data_[i];
	// 			logic [23:0] solved_secret_key_[i];

    //         s_memory s_mem_[i](address_s_[i], clk, data_s_[i], write_en_s_[i], s_read_data_[i]);

    //         d_memory d_mem_[i](address_d_[i], clk, data_d_[i], write_en_d_[i], d_read_data_[i]);
				
	// 			e_rom rom(address_e_[i], clk, e_read_data_[i]);
            
    //         top_controller core_[i](clk, s_init_rst_[i], cores_start, starting_secret_key_[i], s_read_data_[i], d_read_data_[i], e_read_data_[i], address_s_[i], address_d_[i], address_e_[i],
    //                             data_s_[i], data_d_[i], write_en_s_[i], write_en_d_[i], top_done_[i], solved_secret_key_[i]);
    //     end
    // endgenerate


endmodule