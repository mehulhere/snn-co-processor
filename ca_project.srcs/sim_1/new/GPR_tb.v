`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2024 18:11:20
// Design Name: 
// Module Name: GPR_tb
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


module GPR_tb;

    reg reset;
    reg [4:0] rd_addr;
    wire [31:0] rd_data;

    // Instantiate the GPR module
    GPR uut (
        .reset(reset),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    initial begin
        // Initialize signals
        reset = 0;
        rd_addr = 5'b00001; // Address of r1 (register 1)
        
        // Apply reset to initialize the registers with 1 to 32
        #5 reset = 1;
        #5 reset = 0;

        // Read the value of r1
        #10;
        $display("Initial value of r1: %d", rd_data);

        // Change the value of r1 to 2
        uut.reg_file[1] = 2;

        // Read the value of r1 again
        #10;
        $display("Value of r1 after changing to 2: %d", rd_data);

        // End simulation
        #10;
        $finish;
        
    end

    // Monitor changes to rd_data for debugging
    initial begin
        $monitor("At time %t, rd_data = %d", $time, rd_data);
    end

endmodule

