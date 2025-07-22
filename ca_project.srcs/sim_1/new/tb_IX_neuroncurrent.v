module tb_IX_neuroncurrent;
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
    reg clk_reg;
    wire clk = clk_reg;

    // Internal signals
    wire [31:0] NSR_data_monitor [0:127];
    wire [2:0] func3_use;
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
        .func3(func3_use),
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

    genvar idx;
    generate
        for (idx = 0; idx < 128; idx = idx + 1) begin : monitor_NSR
            assign NSR_data_monitor[idx] = uut.nsr_inst.mem[idx];
        end
    endgenerate

    reg [2:0] func3;
    assign func3_use = func3;

    // Clock generation
    initial begin
        clk_reg = 0;
        forever #10 clk_reg = ~clk_reg; // 10 time units clock period
    end

    // Reset and input initialization
    initial begin
        reset = 1;
        #10;
        reset = 0;

        @(posedge clk);
        // ----------------------------
            // Test 1: convh (func3 = 3'b000)
        // ----------------------------
        ID_EXE_opcode = 7'b0000011;
        func3 = 3'b000;
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_rs2 = 5'b00000;
        ID_EXE_rd = 4'b0001;
        ID_EXE_rd_N = 5'b00000;
        ID_EXE_imm = 12'd0;
        ID_EXE_hint = 1'b0;
        ID_EXE_reg_type = 3'b000;
        ID_EXE_load_type = 2'b00;

        @(posedge clk);
        // ----------------------------
                // Test 2: conva (func3 = 3'b001)
        // ----------------------------
        ID_EXE_opcode = 7'b0000011; // CUSTOM opcode
        func3 = 3'b001;             // conva
        ID_EXE_rs1 = 5'd4;          // Example GPR index
        ID_EXE_rs2 = 5'd5;          // Example GPR index
        ID_EXE_rd = 4'd2;           // Example destination GPR
        ID_EXE_rd_N = 5'd1;         // Example NSR index
        ID_EXE_imm = 12'd0;         // Not used for neuron current instructions
        ID_EXE_hint = 1'b0;
        ID_EXE_reg_type = 3'd0;     // Example register type
        ID_EXE_load_type = 2'b00;   // Example load type

        $display("Test 2 - Instruction: conva");
        $display("EXE_WB_addr: %h", EXE_WB_addr);

        @(posedge clk);
        
        // ----------------------------
        // Test 3: convmh (func3 = 3'b010)
        // ----------------------------
        ID_EXE_opcode = 7'b0000011; // CUSTOM opcode
        func3 = 3'b010;             // convmh
        ID_EXE_rs1 = 5'd0;          // Example GPR index
        ID_EXE_rs2 = 5'd0;          // Example GPR index
        ID_EXE_rd = 4'd3;           // Example destination GPR
        ID_EXE_rd_N = 5'd2;         // Example NSR index
        ID_EXE_imm = 12'd0;         // Not used for neuron current instructions
        ID_EXE_hint = 1'b0;
        ID_EXE_reg_type = 3'd0;     // Example register type
        ID_EXE_load_type = 2'b00;   // Example load type

        $display("Test 3 - Instruction: convmh");
        $display("EXE_WB_addr: %h", EXE_WB_addr);
       @(posedge clk);
        // ----------------------------
        // Test 4: convma (func3 = 3'b011)
        // ----------------------------
        ID_EXE_opcode = 7'b0000011; // CUSTOM opcode
        func3 = 3'b011;             // convma
        ID_EXE_rs1 = 5'd0;         // Example GPR index
        ID_EXE_rs2 = 5'd0;         // Example GPR index
        ID_EXE_rd = 4'd4;           // Example destination GPR
        ID_EXE_rd_N = 5'd2;        // Example NSR index
        ID_EXE_imm = 12'd0;         // Not used for neuron current instructions
        ID_EXE_hint = 1'b0;
        ID_EXE_reg_type = 3'd0;     // Example register type
        ID_EXE_load_type = 2'b00;   // Example load type
        $display("Test 4 - Instruction: convma");
        $display("EXE_WB_addr: %h", EXE_WB_addr);
        @(posedge clk);
        // ----------------------------
        // Test 5: doth (func3 = 3'b100)
        // ----------------------------
        ID_EXE_opcode = 7'b0000011; // CUSTOM opcode
        func3 = 3'b100;             // doth
        ID_EXE_rs1 = 5'd13;         // Example GPR index
        ID_EXE_rs2 = 5'd14;         // Example GPR index
        ID_EXE_rd = 4'd5;           // Example destination GPR
        ID_EXE_rd_N = 5'd18;        // Example NSR index
        ID_EXE_imm = 12'd0;         // Not used for neuron current instructions
        ID_EXE_hint = 1'b0;
        ID_EXE_reg_type = 3'd0;     // Example register type
        ID_EXE_load_type = 2'b00;   // Example load type

        $display("Test 5 - Instruction: doth");
        $display("EXE_WB_addr: %h", EXE_WB_addr);
        @(posedge clk);
        // ----------------------------
        // Test 6: dota (func3 = 3'b101)
        // ----------------------------
        ID_EXE_opcode = 7'b0000011; // CUSTOM opcode
        func3 = 3'b101;             // dota
        ID_EXE_rs1 = 5'd0;         // Example GPR index
        ID_EXE_rs2 = 5'd0;         // Example GPR index
        ID_EXE_rd = 4'd6;           // Example destination GPR
        ID_EXE_rd_N = 5'd0;        // Example NSR index
        ID_EXE_imm = 12'd0;         // Not used for neuron current instructions
        ID_EXE_hint = 1'b0;
        ID_EXE_reg_type = 3'd0;     // Example register type
        ID_EXE_load_type = 2'b00;   // Example load type
        #10;
        // End simulation
        $finish;
    end

    // Display monitored values
    integer i;
    initial begin
        $monitor("Time: %0t | EXE_WB_addr: %h | ID_EXE_rs1: %b", 
                 $time, EXE_WB_addr, ID_EXE_rs1);

        #15;
        $display("---- NSR Registers ----");
        for (i = 0; i < 128; i = i + 1) begin
            $display("NSR[%0d] = %h", i, NSR_data_monitor[i]);
        end
    end
endmodule
