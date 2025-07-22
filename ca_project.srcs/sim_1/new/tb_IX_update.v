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
            assign NSR_data_monitor[idx] = uut.NSR_data_array[idx];
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
        // Test case 1: Update  (func3 = 000)
        ID_EXE_opcode = 7'b0000100;
        func3 = 3'b000; // Update 
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_rs2 = 5'b00010;
        ID_EXE_rd_N = 5'b00011; // Wait for updates to complete

        // Test case 2: Update  (func3 = 001)
        @(posedge clk);
        func3 = 3'b001; 
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_rs2 = 5'b00010;
        ID_EXE_rd_N = 5'b00011;// Wait for updates to complete

        // Test case 3: Update  (func3 = 010)
        @(posedge clk);
        func3 = 3'b010; 
        ID_EXE_rs1 = 5'b00001;
        ID_EXE_rs2 = 5'b00010;
        ID_EXE_rd_N = 5'b00011;// Wait for updates to complete
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
