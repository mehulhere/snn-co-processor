// NTR.v
// Neuron Type Register Module
// Indicates neuron type (excitatory or inhibitory).

module NTR (
    input wire clk,                     // Clock signal
    input wire reset,                   // Synchronous reset
    input wire write_enable,            // Write enable signal
    input wire [127:0]write_data,       // 128-bit data to write
    output reg [127:0]read_data        // 128-bit data output
);

    // Declare memory array for NTR
    reg [127:0] mem;
    integer i;

    // Synchronous read/write operations
    always @(*) begin
        if (reset) begin
            // Initialize all entries to zero on reset (default to inhibitory)
            for (i = 0; i < 128; i = i + 1) begin
                mem[i] = 1'b1;
            end
            read_data = 128'b0;
        end else begin
            if (write_enable) begin
                mem = write_data;  // Write operation
            end
            read_data = mem;      // Read operation
        end
    end

endmodule
