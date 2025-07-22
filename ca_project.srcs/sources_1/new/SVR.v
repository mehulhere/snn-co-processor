// SVR.v
// Spike Vector Register Module

module SVR (
    input wire reset,
    input wire write,                    // Write signal (1 = write, 0 = read)
    input wire [3:0] rd_addr,           // 4-bit address to select starting SVR (0-15)
    input wire [1:0] load_type,         // Load type (00 = smallest, 01 = medium, 10 = largest)
    input wire [511:0] Input_Data,      // 512-bit input data for writing
    output reg [511:0] Output_Data,     // 512-bit output data for reading (wire type)
    output wire write_success           // 1 = write was successful (wire type)
);

    // Define 16 Scalar Vector Registers, each 32 bits wide
    reg [31:0] SVR_reg [0:15];
    reg write_success_reg;              // Internal reg to hold the write success signal

    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            SVR_reg[i] = 32'b11111111111111111111111111111111;  // Set all bits to 1
        end
    end

    // Combinational logic for read/write operations
    always @(*) begin
        if (reset) begin
            // On reset, set all registers to zero
            for (i = 0; i < 16; i = i + 1) begin
                SVR_reg[i] = 32'b11111111111111111111111111111111;  // Blocking assignment for reset
            end
            write_success_reg = 0;
        end 
        else if (write) begin
            // Write based on load type
            case (load_type)
                2'b00: begin
                    // Load 32 bits (write to 1 SVR)
                    SVR_reg[rd_addr] = Input_Data[31:0]; // Assign 32 bits to the selected register
                    write_success_reg = 1;
                end
                2'b01: begin
                    // Load 128 bits (write to 4 SVRs)
                    for (i = 0; i < 4; i = i + 1) begin
                        SVR_reg[(rd_addr + i) % 16] = Input_Data[(i*32) +: 32]; // Assign 32 bits to each of the 4 registers
                    end
                    write_success_reg = 1;
                end
                2'b10: begin
                    // Load 512 bits (write to 16 SVRs)
                    for (i = 0; i < 16; i = i + 1) begin
                        SVR_reg[(rd_addr + i) % 16] = Input_Data[(i*32) +: 32]; // Assign 32 bits to each of the 16 registers
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
            Output_Data[i * 32 +: 32] = SVR_reg[i]; // Assign each 32-bit element of SVR_reg to the corresponding position in Output_Data
        end
    end
    assign write_success = write_success_reg; // Continuous assignment to wire

endmodule