/*
*		TITLE: CPM testbench
*		AUTHOR: Baron Young @UCSB'W24
*		DESCRIPTION: Testbench for command processor module (CPM) final project
*   which reads from rom (written with tcl) and 2 gpio ports, and execute the command given by opcode
*   then writes output to 1 of the 2 gpio ports
*
*/

`timescale 1ns / 1ps

module cpm_tb; 

// Testbench uses reg for inputs to the master and wire for connections between master and slave
logic   clk_tb;
logic   clk_fst;
logic   rst_n_tb;

logic	[31:0]    rom_rd_addr;
logic   [31:0]    rom_rd_data;
logic   [7:0]	  op_code_tb;
logic   [7:0]	  gpio_add_tb;
logic   [7:0]	  gpio_mult_tb;
logic   [31:0]	  gpio_rd_tb;
logic   en_w;


bram bram_i(
	.clk_sm (clk_tb),
	.rst_n	(rst_n_tb),
	.en			(en_w),
	.bram_rd_addr (rom_rd_addr),
	.bram_rd_data	(rom_rd_data)
	);
	
CPM cpm(
    .sys_clk_i(clk_tb),
    .clk_i (clk_fst),
    .reset_ni  (rst_n_tb),
	.instr_reg_i (op_code_tb),
	.gpio_mult_i (gpio_mult_tb),
	.gpio_offset_i (gpio_add_tb),
	.gpio_data_o (gpio_rd_tb),
	.bram_address_o (rom_rd_addr),
	.bram_data_i (rom_rd_data),
	.rd_enb_o(en_w)
);
// Clock generation
initial begin
    clk_tb = 0;
    clk_fst = 0;
end
    //clock ratio 4:3 (actual 100Hz to 75Hz)
    //testing with 12:9 = 4:3
    initial forever #12 clk_tb = ~clk_tb; // Generate a clock with a period of 10 ns
    initial forever #9 clk_fst = ~clk_fst; // Generate a clock with a period of 10 ns


// Test stimulus
initial begin
    rst_n_tb = 0;
    gpio_mult_tb = 8'd42;
    gpio_add_tb = 8'd73;
    op_code_tb = 8'b00000000;
    // Reset the system
    #200;
    rst_n_tb = 1;

    // Testing READ
    // read at addr 0, expected output is ITEM_1, in this case 0x1
    #150;
    op_code_tb = 8'b00000000;
    
    #150;
    op_code_tb = 8'b00000001;
    
    // Testing complement
    // read at addr 0, expected output is complement of 0x1, 32'[1111..11110]
    #150;
    op_code_tb = 8'b01000000;
    
    #150;
    op_code_tb = 8'b01000001;
    
    // Testing add
    // read at addr rom[2] or loc. 3, 3 + 73 = 76
    #150;
    op_code_tb = 8'b10010000;
    
    #150;
    op_code_tb = 8'b10010001;
    
    // Testing multiply
    // read at addr rom[1] or loc 2, 2 * 42 = 84
    #150;
    op_code_tb = 8'b11001000;
    
    #150;
    op_code_tb = 8'b11001001;
    
    #500; // Run the simulation for a set time
    rst_n_tb = 0;
    #50
    rst_n_tb = 1;
    $finish; // End the simulation
end

endmodule
