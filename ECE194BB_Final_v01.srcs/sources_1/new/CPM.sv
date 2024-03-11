`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// UCSB ECE198BB 
// 
// Create Date: 03/04/2024 11:15:53 PM
// Design Name: FSM and Datapath Integration
// Module Name: DataPathFsm
// Project Name: ECE198BB Final Project
// Target Devices: 
// Tool Versions: 
// Description: Implements an FSM that decodes commands for various operations
//              and controls a datapath to execute these operations.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Updated with FSM and Datapath Logic
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//struct for instruction 
typedef struct packed {
    bit  [1:0] opcode;       // CMDREG[7:6]: OPCODE
    bit  [2:0] mem_address;  // CMDREG[5:3]: Memory address 
    bit  [1:0] reserved;     // CMDREG[2:1]: Reserved bits
    bit        execute;      // CMDREG[0]: Execute bit
} command_reg_t;


module CPM #(
    parameter DATA_WIDTH = 32,  
    parameter BRAM_BASE_ADDR = 32'hC000_0000
)(
    input logic sys_clk_i,                    // Clock input 100Hz
    input logic clk_i,                        // Clock input 75Hz
    input logic reset_ni,                     
    input command_reg_t instr_reg_i,               
    input logic [7:0] gpio_offset_i,               
    input logic [7:0] gpio_mult_i,           
    output logic [DATA_WIDTH-1:0] gpio_data_o, 
    
    //BRAM IO  
    input logic  [DATA_WIDTH-1:0] bram_data_i,  
    output logic [DATA_WIDTH-1:0] bram_address_o, 
    output logic rd_enb_o
    
    ,output logic [31:0] test
    ,output logic [31:0] test2
);


// Temp storage for operations
logic [DATA_WIDTH-1:0] fetched_bram_data_d;
logic [DATA_WIDTH-1:0] temp_result_q;
//Synchronizer buffers
command_reg_t cmd_reg_sync1, cmd_reg_sync2;
logic [7:0] gpio_offset_sync1, gpio_offset_sync2;
logic [7:0] gpio_mult_sync1, gpio_mult_sync2;
logic [DATA_WIDTH-1:0] gpio_data_sync1, gpio_data_sync2;

 //input synchronizer logic
always_ff @(posedge clk_i or negedge reset_ni) begin
    if (!reset_ni) begin
        cmd_reg_sync1 <= 0;
        cmd_reg_sync2 <= 0;
        gpio_offset_sync1 <= 0;
        gpio_offset_sync2 <= 0;
        gpio_mult_sync1 <= 0;
        gpio_mult_sync2 <= 0;
    end else begin
        cmd_reg_sync1 <= instr_reg_i; 
        cmd_reg_sync2 <= cmd_reg_sync1; 
        
        gpio_offset_sync1 <= gpio_offset_i;     
        gpio_offset_sync2 <= gpio_offset_sync1; 
        
        gpio_mult_sync1 <= gpio_mult_i;
        gpio_mult_sync2 <= gpio_mult_sync1;
        
    end
end
 
//FIFO output synchronizer (100 MHz)
always_ff @(posedge sys_clk_i or negedge reset_ni) begin 
    if (!reset_ni) begin
        gpio_data_sync1 <= 0;
        gpio_data_sync2 <= 0;
    end 
        gpio_data_sync1 <= temp_result_q;
        gpio_data_sync2 <= gpio_data_sync1;

end

assign gpio_data_o = gpio_data_sync2;

// State encoding
enum logic [2:0] {
    S_IDLE = 3'd0,
    S_DECODE = 3'd1,    
    S_EXECUTE = 3'd2,
    S_WRITEBACK = 3'd3,
    S_WAIT = 3'd4
} currentState, nextState;

// Operation encoding
enum logic [1:0] {
    OP_READ = 2'b00,
    OP_COMPLEMENT = 2'b01,
    OP_ADD = 2'b10,
    OP_MULT = 2'b11 
} operation;



// Decode the operation and address
always_ff @(posedge clk_i or negedge reset_ni) begin
    if (!reset_ni) begin
        currentState <= S_IDLE;
    end
    else begin
        currentState <= nextState;
        
        if (currentState == S_DECODE) begin
            
            // Decode operation using a case statement
            case (cmd_reg_sync2.opcode)
                2'b00: operation <= OP_READ;
                2'b01: operation <= OP_COMPLEMENT;
                2'b10: operation <= OP_ADD;
                2'b11: operation <= OP_MULT;
                default: operation <= OP_READ; // Default case to handle unexpected values
            endcase     
        end 
    end
end

assign bram_address_o = (currentState == S_DECODE) ? (BRAM_BASE_ADDR + ({cmd_reg_sync2.mem_address} << 2)) : 32'h0;
assign rd_enb_o = (currentState == S_DECODE) ? 1 : 0;
assign test = gpio_data_sync2;
assign test2 = temp_result_q;

// Execute operation
always_ff @(posedge clk_i) begin
    if (!reset_ni) begin
        fetched_bram_data_d <= 0;
        temp_result_q <= 0;
    end 
     
    fetched_bram_data_d <= bram_data_i;

    if (currentState == S_EXECUTE) begin
        case (operation)
            OP_READ: temp_result_q <= fetched_bram_data_d; 
            OP_COMPLEMENT: temp_result_q <= ~fetched_bram_data_d;
            OP_ADD: temp_result_q <= fetched_bram_data_d + gpio_offset_sync2;
            OP_MULT: temp_result_q <= fetched_bram_data_d * gpio_mult_sync2;
            default: temp_result_q <= fetched_bram_data_d;
        endcase
    end
end

// Combinational logic for next state logic
always_comb begin
    nextState = currentState; // Default is to stay in the current state
    case (currentState)
        S_IDLE: if (cmd_reg_sync2.execute) nextState = S_DECODE;
        S_DECODE: nextState = S_EXECUTE;
        S_EXECUTE: nextState = S_WRITEBACK;
        S_WRITEBACK: nextState = S_WAIT;
        S_WAIT: if (!cmd_reg_sync2.execute) nextState = S_IDLE;
        default: nextState = S_IDLE;
    endcase
end

endmodule
