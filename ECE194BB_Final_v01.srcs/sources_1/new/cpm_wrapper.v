`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2024 09:12:41 PM
// Design Name: 
// Module Name: cpm_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpm_wrapper(
    input wire sys_clk_i,
    input wire clk_sm_i,
    input wire reset_ni,
    input wire [7:0] cmd_reg_i,
    input wire [7:0] gpio_offset_i,
    input wire [7:0] gpio_mult_i,
    output wire [31:0] gpio_data_o,
    input wire [31:0] bram_data_i,
    output wire [31:0] bram_address_o,
    output wire rd_enb_o,
    
    output wire [31:0] test,
    output wire [31:0] test2
    );


CPM cpm(
    .sys_clk_i(sys_clk_i),
    .clk_i (clk_sm_i),
    .reset_ni  (reset_ni),
	.instr_reg_i (cmd_reg_i),
	.gpio_mult_i (gpio_mult_i),
	.gpio_offset_i (gpio_offset_i),
	.gpio_data_o (gpio_data_o),
	.bram_address_o (bram_address_o),
	.bram_data_i (bram_data_i),
	.rd_enb_o (rd_enb_o)
	
	, .test(test)
	, .test2(test2)
);

endmodule