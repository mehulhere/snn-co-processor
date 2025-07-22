`timescale 1ns / 1ps

module tb_IX_stage;
    // Define the inputs
    reg clk;
    reg reset;
    reg [6:0] ID_EXE_opcode;
    reg [4:0] ID_EXE_rs1;
    reg [4:0] ID_EXE_rs2;
    reg [11:0] ID_EXE_imm;
    reg [3:0] ID_EXE_rd;
    reg [4:0] ID_EXE_rd_N;
    reg ID_EXE_hint;
    reg [2:0] ID_EXE_reg_type;
    reg [1:0] ID_EXE_load_type;

    // Define the outputs
    wire [3:0] ex_rd;
    wire ex_hint;
    wire [2:0] ex_reg_type;
    wire [1:0] ex_load_type;
    wire [6:0] ex_opcode;
    wire [31:0] EXE_WB_addr;

    // Instantiate the IX_stage module
    IX_stage uut (
        .clk(clk),
        .reset(reset),
        .ID_EXE_opcode(ID_EXE_opcode),
        .ID_EXE_rs1(ID_EXE_rs1),
        .ID_EXE_rs2(ID_EXE_rs2),
        .ID_EXE_imm(ID_EXE_imm),
        .ID_EXE_rd(ID_EXE_rd),
        .ID_EXE_rd_N(ID_EXE_rd_N),
        .ID_EXE_hint(ID_EXE_hint),
        .ID_EXE_reg_type(ID_EXE_reg_type),
        .ID_EXE_load_type(ID_EXE_load_type),
        .ex_rd(ex_rd),
        .ex_hint(ex_hint),
        .ex_reg_type(ex_reg_type),
        .ex_load_type(ex_load_type),
        .ex_opcode(ex_opcode),
        .EXE_WB_addr(EXE_WB_addr)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 time units clock period

    // Initialize the testbench signals
    initial begin
        // Initialize clock and reset
        clk = 0;
        reset = 0;

        // Apply the first set of inputs at the positive edge of the clock
        @(posedge clk);
        ID_EXE_opcode = 7'b0000000;
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_imm = 12'b0000_0000_0001;
        ID_EXE_rd = 4'b0001;
        ID_EXE_hint = 0;
        ID_EXE_reg_type = 2'b00;
        ID_EXE_load_type = 2'b00;

        // Wait for a clock edge and display the first result
        
        $display("Test 1 - Opcode: %b, rs1: %d, imm: %b, EXE_WB_addr: %h", 
                 ID_EXE_opcode, ID_EXE_rs1, ID_EXE_imm, EXE_WB_addr);

        // Apply the second set of inputs at the positive edge of the clock
        @(posedge clk);
        ID_EXE_opcode = 7'b0000000;
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_imm = 12'b0000_0000_0101;
        ID_EXE_rd = 4'b0001;
        ID_EXE_hint = 0;
        ID_EXE_reg_type = 2'b00;
        ID_EXE_load_type = 2'b00;

        // Wait for a clock edge and display the second result
        
        $display("Test 2 - Opcode: %b, rs1: %d, imm: %b, EXE_WB_addr: %h", 
                 ID_EXE_opcode, ID_EXE_rs1, ID_EXE_imm, EXE_WB_addr);

        // Apply the third set of inputs at the positive edge of the clock
        @(posedge clk);
        ID_EXE_opcode = 7'b0000001;
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_imm = 12'b0000_0001_0001;
        ID_EXE_rd = 4'b0001;
        ID_EXE_hint = 0;
        ID_EXE_reg_type = 2'b00;
        ID_EXE_load_type = 2'b00;
        
        @(posedge clk);
        ID_EXE_opcode = 7'b0000010;         // Opcode for load operation
        ID_EXE_rs1 = 5'b00001;              // Base register
        ID_EXE_rs2 = 5'b00010;              // Offset register
        ID_EXE_rd = 5'b00100;               // Destination register for threshold voltage
        ID_EXE_hint = 0;
        ID_EXE_reg_type = 2'b10;
        ID_EXE_load_type = 2'b00;
        
        
        @(posedge clk);
        ID_EXE_opcode = 7'b0000010;         // Opcode for load operation
        ID_EXE_rs1 = 5'b00001;              // Base register
        ID_EXE_rs2 = 5'b00010;              // Offset register
        ID_EXE_rd = 5'b00101;               // Destination register for neuron type
        ID_EXE_hint = 0;
        ID_EXE_reg_type = 2'b11;
        ID_EXE_load_type = 2'b00;
        
        @(posedge clk);
        ID_EXE_opcode = 7'b0000010;         // Opcode for load operation
        ID_EXE_rs1 = 5'b00001;              // Base register
        ID_EXE_rs2 = 5'b00010;              // Offset register
        ID_EXE_rd = 5'b00110;               // Destination register for neuron state
        ID_EXE_hint = 0;
        ID_EXE_reg_type = 3'b100;
        ID_EXE_load_type = 2'b00;

        // Wait for a clock edge and display the third result
        
        $display("Test 3 - Opcode: %b, rs1: %d, imm: %b, EXE_WB_addr: %h", 
                 ID_EXE_opcode, ID_EXE_rs1, ID_EXE_imm, EXE_WB_addr);

        // End simulation
        @(posedge clk);
        $finish;
    end

    // Monitor changes for debugging
    initial begin
        $monitor("Time: %0t | EXE_WB_addr: %h", $time, EXE_WB_addr);
    end

endmodule
