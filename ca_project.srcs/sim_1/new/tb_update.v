module tb_update;
    // Define the inputs
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

    // Internal signals
    reg clk;
    wire [31:0] NSR_data_monitor [0:127];
    reg [2:0] func3;
    integer i;
    // Instantiate the IX_stage module
    IX_stage uut (
        .clk(clk),
        .reset(reset),
        .ID_EXE_opcode(ID_EXE_opcode),
        .ID_EXE_rs1(ID_EXE_rs1),
        .ID_EXE_rs2(ID_EXE_rs2),
        .ID_EXE_rd(ID_EXE_rd),
        .ID_EXE_rd_N(ID_EXE_rd_N),
        .ID_EXE_imm(ID_EXE_imm),
        .func3(func3),
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

    // Generate NSR data monitor for observing memory state
    genvar idx;
    generate
        for (idx = 0; idx < 128; idx = idx + 1) begin : monitor_NSR
            assign NSR_data_monitor[idx] = uut.NSR_data_array[idx];
        end
    endgenerate

    // Clock generation
    initial begin
        clk = 0;
        
        forever #5 clk = ~clk; // 10 time unit clock period
    end

    // Reset and test sequence
    initial begin
        reset = 1; // Activate reset
        #10;       // Hold reset for one clock cycle
        reset = 0; // Release reset

        // Test Case 1: Initialization Test
        @(posedge clk);
        ID_EXE_opcode = 7'b0000011; // Load opcode
        func3 = 3'b000;             // Load function
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_rs2 = 5'b00000;
        ID_EXE_rd = 4'b0001;
        ID_EXE_rd_N = 5'b00010;
        ID_EXE_imm = 12'd0;
        ID_EXE_hint = 1'b0;
        ID_EXE_reg_type = 3'b000;
        ID_EXE_load_type = 2'b00;

      
        $display("Test 1 - Load instruction");
        $display("EXE_WB_addr: %h | EXE_rd: %b", EXE_WB_addr, ex_rd);

        // Test Case 2: Convolution Accumulate
        @(posedge clk);
        ID_EXE_opcode = 7'b0000011; // Custom opcode
        func3 = 3'b001;             // Convolution accumulate
        ID_EXE_rs1 = 5'd4;
        ID_EXE_rs2 = 5'd5;
        ID_EXE_rd = 4'd2;
        ID_EXE_rd_N = 5'd6;
        $display("Test 2 - Convolution Accumulate (func3 = 001)");
        $display("EXE_WB_addr: %h", EXE_WB_addr);

        // Test Case 3: Monitor Memory State
        
        $display("---- Monitoring NSR Memory State ----");
        for ( i = 0; i < 128; i = i + 1) begin
            $display("NSR[%0d] = %h", i, NSR_data_monitor[i]);
        end

        // Additional Test Cases
        // Test Case 4: convmh
        @(posedge clk);
        func3 = 3'b010;             // convmh
        ID_EXE_rs1 = 5'd7;
        ID_EXE_rs2 = 5'd8;
        ID_EXE_rd = 4'd3;
        ID_EXE_rd_N = 5'd9;

        
        $display("Test 4 - Convolution Multiply High (func3 = 010)");
        $display("EXE_WB_addr: %h", EXE_WB_addr);

        // Test Case 5: Update Neuron State
        @(posedge clk);
        ID_EXE_opcode = 7'b0000100; // Update opcode
        func3 = 3'b011;             // Update function
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_rs2 = 5'b00010;
        ID_EXE_rd_N = 5'b00011;

        $display("Test 5 - Update Neuron State (func3 = 011)");
        $display("EXE_WB_addr: %h", EXE_WB_addr);

        // Finish simulation
        @(posedge clk);
        $finish;
    end

    // Monitor key values
    initial begin
        $monitor("Time: %0t | clk: %b | Reset: %b | Opcode: %b | EXE_WB_addr: %h", 
                 $time, clk, reset, ID_EXE_opcode, EXE_WB_addr);
    end
endmodule
