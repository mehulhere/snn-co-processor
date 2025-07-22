`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2024 12:07:05
// Design Name: 
// Module Name: tb
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

`timescale 1ns / 1ps

module tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg debug_mode;
    reg [31:0] instruction_in;
    
    // Instantiate the MainCPU module
//    MainCPU uut (
//        .clk(clk),
//        .reset(reset),
//        .debug_mode(debug_mode),
//        .instruction_in(instruction_in)
//    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Reset and initial stimulus
    initial begin
        // Initialize signals
        reset = 1;
        debug_mode = 0;
        instruction_in = 32'b0;
        
        // Hold reset for a few clock cycles
        #20;
        reset = 0;

        // Provide instructions manually based on the PC value
        #10; instruction_in = 32'b00000000000100001000000010000000; // Instruction 1
        #10; instruction_in = 32'b00000000001100011000000110000000; // Instruction 2
        #10; instruction_in = 32'b00000000001000010000000100000000; // Instruction 3
        #10; instruction_in = 32'b00000000000100001001000010000000; // Instruction 4
        #10; instruction_in = 32'b00000000001100011001000110000000; // Instruction 5
        #10; instruction_in = 32'b00000000001000010001000100000000; // Instruction 6
        #10; instruction_in = 32'b00000000000100001010000010000000; // Instruction 7
        #10; instruction_in = 32'b00000000001100011010000110000000; // Instruction 8
        #10; instruction_in = 32'b00000000001000010010000100000000; // Instruction 9
        
        // Wait and observe behavior for some time
        #100;

        // Finish simulation
        $finish;
    end

    // Monitor signals for debugging
    initial begin
        // You can add $monitor here to track signals
        $monitor("Time = %0t, Reset = %b, Debug Mode = %b, PC = %h, IF/ID Instr = %h",
                 $time, reset, debug_mode, uut.pc_out, uut.IF_ID_instr);
    end

    // Connect the instruction input to the fetch stage within the CPU
    

endmodule


