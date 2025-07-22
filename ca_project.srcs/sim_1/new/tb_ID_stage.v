module tb_ID_stage;

    // Testbench signals
    reg clk;
    reg [31:0] instr;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [3:0] rd;
    wire [4:0] rd_N;
    wire [11:0] imm;
    wire hint;
    wire [2:0] reg_type;
    wire [1:0] load_type;
    wire [6:0] opcode;

    // Instantiate the ID_stage module
    ID_stage uut (
        .clk(clk),
        .instr(instr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rd_N(rd_N),
        .imm(imm),
        .hint(hint),
        .reg_type(reg_type),
        .load_type(load_type),
        .opcode(opcode)
    );
    initial begin
    clk = 0;
    end
    // Clock generation
    always #5 clk = ~clk;  // 10 time units period clock

    // Initialize the testbench signals
    initial begin
        // Initialize clock
        clk = 0;

        // Test instruction 1
        @(posedge clk);
        instr = 32'b00000000000100001000000010000000; // Example instruction 1
        @(posedge clk);

        // Test instruction 2
        instr = 32'b00000000001100011000000110000000; // Example instruction 2
        @(posedge clk);

        // Test instruction 3
        instr = 32'b00000000001000010000000100000000; // Example instruction 3
        @(posedge clk);

        // Test instruction 4
        instr = 32'b00000000000100001001000010000000; // Example instruction 4
        @(posedge clk);

        // Test instruction 5
        instr = 32'b00000000001100011001000110000000; // Example instruction 5
        @(posedge clk);

        // Test instruction 6
        instr = 32'b00000000001000010001000100000000; // Example instruction 6
        @(posedge clk);

        // Test instruction 7
        instr = 32'b00000000000100001010000010000000; // Example instruction 7
        @(posedge clk);

        // Test instruction 8
        instr = 32'b00000000001100011010000110000001; // Example instruction 8
        @(posedge clk);

        // Test instruction 9
        instr = 32'b00000000001000010010000100000001; // Example instruction 9
        @(posedge clk);
        
        instr = 32'b00000010001000001001001000000010;
        @(posedge clk);
        
        instr = 32'b00000100001000001010001010000010;
        @(posedge clk);
        
        instr = 32'b00000110001000001011001100000010;
        @(posedge clk);
        // End simulation
        @(posedge clk);
        $finish;
    end

    // Monitor the outputs
    initial begin
        $monitor("Time = %0d, instr = %b, rs1 = %0d, rs2 = %0d, rd = %0d, rd_N = %0d, imm = %0d, hint = %b, reg_type = %b, load_type = %b, opcode = %b", 
                 $time, instr, rs1, rs2, rd, rd_N, imm, hint, reg_type, load_type, opcode);
    end

endmodule
