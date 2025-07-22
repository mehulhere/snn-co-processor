`timescale 1ns / 1ps

module Memory (
    input wire [31:0] address,       
    input wire [15:0] num_bytes,      
    output reg [1023:0] data_out     
);

    reg [7:0] mem_array [0:65535];   

    integer i;

    // Initialize memory with values for simulation
    initial begin
        for (i = 0; i < 65536; i = i + 1) begin
            mem_array[i] = 8'hbc;  // Example: Store some pattern values in memory
            if (i < 10) $display("Memory[%0d] = %h", i, mem_array[i]); // Debug first few entries
        end
    end

    always @(*) begin
        data_out = 0;
        for (i = 0; i < num_bytes; i = i + 1) begin
            data_out[(i*8) +: 8] = mem_array[address + i]; 
        end
        
    end
endmodule

