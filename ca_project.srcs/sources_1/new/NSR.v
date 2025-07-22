// NSR.v
// Neuron State Register Module
// Stores neuron states, such as membrane potential or current.

module NSR (
    input wire clk,                     // Clock signal
    input wire reset,                   // Synchronous reset
    input wire write_enable,            // Write enable signal
    input wire [4095:0] write_data,       // 4095-bit data to write
    output reg [4095:0] read_data         // 4095-bit data output
);

    // Declare memory array for NSR
    reg [31:0] mem [0:127];
    integer i;

    // Synchronous read/write operations
     always @(*) begin
        if (reset) begin
            // Initialize all entries to zero on reset
            for (i = 0; i < 128; i = i + 1) begin
                mem[i] = 32'b0;
            end
            read_data = 4096'b0;
        end else begin
            if (write_enable == 1'b1) begin
                for (i = 0; i < 128; i = i + 1) begin
                    mem[i] = write_data[i * 32 +: 32];
                end
            end
            else begin
                for (i = 0; i < 128; i = i + 1) begin
                    read_data[i * 32 +: 32] = mem[i];
                end
            end
        end
    end

endmodule
