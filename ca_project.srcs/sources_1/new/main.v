//`timescale 1ns / 1ps

//module tb_MainCPU;

//    // Testbench signals
//    reg clk;
//    reg reset;
//    reg debug_mode;
//    reg [31:0] IF_instruction_in; // Manual input to pass instructions

//    // Instantiate MainCPU module
//    MainCPU uut (
//        .clk(clk),
//        .reset(reset),
//        .debug_mode(debug_mode),
//        .IF_instruction_in(IF_instruction_in)
//    );

//    // Clock generation
//    always #5 clk = ~clk; // 10ns period clock

//    // Initialize testbench
//    initial begin
//        clk = 0;
//        reset = 1;
//        debug_mode = 0;
//        IF_instruction_in = 32'd0;

//        // Wait a couple of clock cycles with reset
//        @(posedge clk);
//        @(posedge clk);

//        // Release reset
//        reset = 0;

//        // Apply the first instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000000100001000000010000000; // Example instruction 1

//        // Apply the second instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000001100011000000110000000; // Example instruction 2

//        // Apply the third instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000001000010000000100000000; // Example instruction 3

//        // Apply the fourth instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000000100001001000010000000; // Example instruction 4

//        // Apply the fifth instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000001100011001000110000000; // Example instruction 5

//        // Apply the sixth instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000001000010001000100000000; // Example instruction 6

//        // Apply the seventh instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000000100001010000010000000; // Example instruction 7

//        // Apply the eighth instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000001100011010000110000000; // Example instruction 8

//        // Apply the ninth instruction
//        @(posedge clk);
//        IF_instruction_in = 32'b00000000001000010010000100000000; // Example instruction 9

//        // Let the pipeline run for a few more clock cycles to observe results
//        repeat (5) @(posedge clk);

//        // End simulation
//        $finish;
//    end

//    // Monitor outputs
//    initial begin
//        $monitor("Time = %0d, Reset = %b, IF_instruction_in = %h", $time, reset, IF_instruction_in);
//    end

//endmodule
`timescale 1ns / 1ps

module tb_MainCPU;

    // Testbench signals
    reg clk;
    reg reset;
    reg debug_mode;
    reg [31:0] IF_instruction_in; // Manual input to pass instructions
    wire [31:0] IF_instruction_out;
    wire [4:0] ID_IX_rs1_out;
      wire [3:0] ID_IX_rd_out;
      wire [11:0] ID_IX_imm_out;
      wire ID_IX_hint_out;
      wire [1:0] ID_IX_reg_type_out;
      wire [1:0] ID_IX_load_type_out;
      wire [6:0] ID_IX_opcode_out;
      wire [31:0] IX_IM_addr_out;
      wire [4095:0] IM_IW_data_out;

    // Instantiate MainCPU module
    MainCPU uut (
        .clk(clk),
        .reset(reset),
        .debug_mode(debug_mode),
        .IF_instruction_in(IF_instruction_in),
        .IF_ID_instruction_out(IF_instruction_out),
        .ID_IX_rs1_out(ID_IX_rs1_out),
    .ID_IX_rd_out(ID_IX_rd_out),
    .ID_IX_imm_out(ID_IX_imm_out),
    .ID_IX_hint_out(ID_IX_hint_out),
    .ID_IX_reg_type_out(ID_IX_reg_type_out),
    .ID_IX_load_type_out(ID_IX_load_type_out),
    .ID_IX_opcode_out(ID_IX_opcode_out),
    .EXE_MEM_addr_out(IX_IM_addr_out),
    .MEM_data_out(IM_IW_data_out)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns period clock

    // Initialize testbench
    initial begin
        clk = 0;
        reset = 1;
        debug_mode = 0;
        IF_instruction_in = 32'd0;

        // Wait a couple of clock cycles with reset
        @(posedge clk);
        @(posedge clk);

        // Release reset
        reset = 0;

        // Apply the first instruction
        @(posedge clk);
        IF_instruction_in = 32'b00000000000100001000000010000000; // Example instruction 1

        // Apply the second instruction
        @(posedge clk);
        IF_instruction_in = 32'b00000000000100001000000010000001; // Example instruction 2

        // Apply the third instruction
        @(posedge clk);
        IF_instruction_in = 32'b00000000000100001001000010000000; // Example instruction 3

        // Apply the fourth instruction
        @(posedge clk);
        IF_instruction_in = 32'b00000000000100001001000010000001; // Example instruction 4

        // Apply the fifth instruction
        @(posedge clk);
        IF_instruction_in = 32'b00000000000100001010000010000000; // Example instruction 5

        // Apply the sixth instruction
        @(posedge clk);
        IF_instruction_in = 32'b00000000000100001010000010000001; // Example instruction 6

        
        repeat (5) @(posedge clk);
        
        // End simulation
        $finish;
    end

    // Monitor internal signals
    initial begin
        $monitor("Time = %0d, Reset = %b, IF_instruction_in = %h, IF_instruction_out = %h, IF_pc_out = %h, IF_next_pc = %h, IF_ID_instruction = %h, ID_rs1 = %0d, ID_rd = %0d, ID_imm = %0d, ID_opcode = %b, ID_reg_type = %b, ID_load_type = %b", 
                 $time, reset, IF_instruction_in, 
                 uut.IF_instruction_out, uut.IF_pc_out, uut.IF_next_pc, uut.IF_ID_instruction,
                 uut.ID_rs1, uut.ID_rd, uut.ID_imm, uut.ID_opcode, 
                 uut.ID_reg_type, uut.ID_load_type);
    end

    // Dump waveform for all variables
    initial begin
        $dumpfile("tb_MainCPU.vcd"); // Creates a waveform file
        $dumpvars(0, tb_MainCPU);    // Dumps all variables from the current module and all submodules
    end

endmodule
