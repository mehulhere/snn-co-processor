`timescale 1ns / 1ps
module tb_IM_stage;

    // Inputs
    reg clk;
    reg reset;
    reg [3:0] ex_rd;
    reg [4:0] ex_rd_N;
    reg [6:0] opcode;
    reg ex_hint;
    reg [2:0] ex_reg_type;
    reg [1:0] ex_load_type;
    reg [31:0] EXE_MEM_addr;

    // Outputs
    wire [1:0] MEM_WB_load_type;
    wire [3:0] MEM_WB_rd;
    wire [1023:0] MEM_WB_data;

    // Instantiate the IM_stage module
    IM_stage uut (
        .clk(clk),
        .reset(reset),
        .ex_rd(ex_rd),
        .ex_rd_N(ex_rd_N),
        .opcode(opcode),
        .ex_hint(ex_hint),
        .ex_reg_type(ex_reg_type),
        .ex_load_type(ex_load_type),
        .EXE_MEM_addr(EXE_MEM_addr),
        .MEM_WB_load_type(MEM_WB_load_type),
        .MEM_WB_rd(MEM_WB_rd),
        .MEM_WB_data(MEM_WB_data)
    ); 
    // Clock generation
    always #5 clk = ~clk;

    initial begin
    clk = 0;
        // Initialize the clock
        @(posedge clk);
        // First set of inputs
        reset = 0;
        ex_rd = 4'b0001;
        opcode = 7'b0000000;
        ex_hint = 0;
        ex_reg_type = 2'b00;
        ex_load_type = 2'b00;
        EXE_MEM_addr = 32'b00000000000000000000000000000001;
        @(posedge clk);
        $display("Test 1 - Load Type: %b, MEM_WB_rd: %d, MEM_WB_data[255:0]: %h", 
                 MEM_WB_load_type, MEM_WB_rd, MEM_WB_data[255:0]);
        @(posedge clk);
        // Second set of inputs
        ex_rd = 4'b0010;
        opcode = 7'b0000000;
        ex_hint = 0;
        ex_reg_type = 2'b00;
        ex_load_type = 2'b01;
        EXE_MEM_addr = 32'b00000000000000000000000000000010;
        @(posedge clk);
        // Wait and observe
        $display("Test 2 - Load Type: %b, MEM_WB_rd: %d, MEM_WB_data[1023:0]: %h", 
                 MEM_WB_load_type, MEM_WB_rd, MEM_WB_data[1023:0]);
        @(posedge clk);
        // Third set of inputs
        ex_rd = 4'b0011;
        opcode = 7'b0000000;
        ex_hint = 0;
        ex_reg_type = 2'b00;
        ex_load_type = 2'b10;
        EXE_MEM_addr = 32'b00000000000000000000000000000011;
        
        @(posedge clk);
        // Third set of inputs
        ex_rd = 4'b0100;
        opcode = 7'b0000010;
        ex_hint = 0;
        ex_reg_type = 2'b10;
        ex_load_type = 2'b00;
        EXE_MEM_addr = 32'b00000000000000000000000000000011;
        
        @(posedge clk);
        // Third set of inputs
        ex_rd = 4'b0101;
        opcode = 7'b0000010;
        ex_hint = 0;
        ex_reg_type = 2'b11;
        ex_load_type = 2'b00;
        EXE_MEM_addr = 32'b00000000000000000000000000000011;
        
        @(posedge clk);
        // Third set of inputs
        ex_rd = 4'b0110;
        opcode = 7'b0000010;
        ex_hint = 0;
        ex_reg_type = 3'b100;
        ex_load_type = 2'b00;
        EXE_MEM_addr = 32'b00000000000000000000000000000011;
        
        @(posedge clk);
        // Wait and observe
        $display("Test 3 - Load Type: %b, MEM_WB_rd: %d, MEM_WB_data[1023:0]: %h", 
                 MEM_WB_load_type, MEM_WB_rd, MEM_WB_data[1023:0]);

        // End simulation
        #10;
        $finish;
    end
endmodule
