// VTR.v
// Threshold Voltage Register Module
// Stores the threshold voltage for each neuron to spike.

module VTR (
    input wire clk,                     // Clock signal
    input wire reset,                   // Synchronous reset
    input wire write_enable,            // Write enable signal
    input wire [1023:0] write_data,       // 16-bit data to write
    output reg [1023:0] read_data         // 16-bit data output
);

    // Declare memory array for VTR
    reg [7:0] mem [0:127];

    integer i;

    // Synchronous read/write operations
        always @(*) begin
        if (reset) begin
            // Initialize all entries to zero on reset
            for (i = 0; i < 128; i = i + 1) begin
                mem[i] = 8'b0;
            end
            read_data = 1024'b0;
        end else begin
            if (write_enable) begin
                for (i = 0; i < 128; i = i + 1) begin
                    mem[i] = write_data[(i*8) +: 8];
                end 
            end
            for (i = 0; i < 128; i = i + 1) begin
                read_data[(i*8) +: 8] = mem[i];
            end
        end
    end

endmodule
