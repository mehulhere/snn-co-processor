// WVR.v
// Weight Vector Register Module

module WVR (
    input wire reset,
    input wire write,                     // Write signal (1 = write, 0 = read)
    input wire [3:0] rd_addr,            // 4-bit address to select starting WVR (0-15)
    input wire [1:0] load_type,          // Load type (00 = smallest, 01 = medium, 10 = largest)
    input wire [1023:0] Input_Data,      // 1024-bit input data for writing
    output reg [1023:0] Output_Data,     // 1024-bit output data for reading (wire type)
    output wire write_success            // 1 = write was successful (wire type)
);

    // Define 16 Weight Vector Registers, each 64 bits wide
    reg [63:0] WVR_reg [0:15];
    reg write_success_reg = 0;               // Internal reg to hold the write success signal

    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            WVR_reg[i] = 64'h0101010101010101;  // Assign random 64-bit values to each register
        end
    end

    // Combinational logic for read/write operations
    always @(*) begin
        if (reset) begin
            // On reset, set all registers to zero
            for (i = 0; i < 16; i = i + 1) begin
                WVR_reg[i] = 64'h0101010101010101;  // Blocking assignment for reset
            end
            write_success_reg = 0;
        end 
        else if (write) begin
            // Write based on load type
            case (load_type)
                2'b00: begin
                    // Load 64 bits (write to 1 WVR)
                    WVR_reg[rd_addr] = Input_Data[63:0]; // Assign 64 bits to the selected register
                    write_success_reg = 1;

                end
                2'b01: begin
                    // Load 256 bits (write to 4 WVRs)
                    for (i = 0; i < 4; i = i + 1) begin
                        WVR_reg[(rd_addr + i) % 16] = Input_Data[(i*64) +: 64]; // Assign 64 bits to each of the 4 registers
                    end
                    write_success_reg = 1;

                end
                2'b10: begin
                    // Load 1024 bits (write to 16 WVRs)
                    for (i = 0; i < 16; i = i + 1) begin
                        WVR_reg[(rd_addr + i) % 16] = Input_Data[(i*64) +: 64]; // Assign 64 bits to each of the 16 registers
                    end
                    write_success_reg = 1;

                end
            endcase
             // Indicate successful write
        end 
        else begin
            write_success_reg = 0; // Indicate read operation, no write
        end
    end

    // Assign the wire outputs based on the internal logic
    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin
            Output_Data[i * 64 +: 64] = WVR_reg[i];
        end
    end

    assign write_success = write_success_reg; // Continuous assignment to wire

endmodule