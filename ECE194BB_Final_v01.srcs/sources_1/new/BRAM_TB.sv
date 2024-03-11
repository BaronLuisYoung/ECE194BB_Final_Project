`timescale 1ns / 1ps

module bram #(
    localparam ITEM_1 = 32'h1,
    localparam ITEM_2 = 32'h2,
    localparam ITEM_3 = 32'h3,
    localparam ITEM_4 = 32'h4,
    localparam ITEM_5 = 32'h5,
    localparam ITEM_6 = 32'h6,
    localparam ITEM_7 = 32'h7,
    localparam ITEM_8 = 32'h8,
    localparam BASE_ADDR = 32'hC000_0000  // Base address for the BRAM
)(
    input clk_sm,
    input rst_n,
    input en,
    input logic [31:0] bram_rd_addr,
    output logic [31:0] bram_rd_data
);
    
    logic [7:0] rom [7:0]; // Adjusted to reflect an 8-word memory

    // Calculate the address offset based on the base address
    logic [2:0] addr_offset; // Can address up to 8 words

    always_comb begin
        addr_offset = (bram_rd_addr - BASE_ADDR) >> 2; // Calculate offset from base and divide by 4
    end

    always_ff @(posedge clk_sm or negedge rst_n) begin
        if(!rst_n) begin
            rom[0] <= ITEM_1;
            rom[1] <= ITEM_2;
            rom[2] <= ITEM_3;
            rom[3] <= ITEM_4;
            rom[4] <= ITEM_5;
            rom[5] <= ITEM_6;
            rom[6] <= ITEM_7;
            rom[7] <= ITEM_8;
        end
    end
    
    // Additional signal declaration
    logic [31:0] bram_rd_data_next;
    logic [31:0] bram_rd_data_reg; // Register to hold the data for one clock cycle
    

    // Sequential logic to introduce one clock cycle latency
    always_ff @(posedge clk_sm) begin
        bram_rd_data <=  (en && addr_offset < 8) ? rom[addr_offset] : 32'h0; // Capture the value on each clock edge
    end
   

endmodule
