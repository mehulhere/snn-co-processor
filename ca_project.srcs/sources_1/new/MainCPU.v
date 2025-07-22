`timescale 1ns / 1ps

`define wvr            2'b00
`define svr            2'b01
`define sor            2'b10
`define nsr            2'b11
`define swl_ins        7'b0000000
`define svl_ins        7'b0000001

module MainCPU (
    input wire clk,
    input wire reset,
    input wire debug_mode,
    input wire [31:0] IF_instruction_in,
    output wire [31:0] IF_ID_instruction_out,
     output wire [4:0] ID_IX_rs1_out,
    output wire [3:0] ID_IX_rd_out,
    output wire [11:0] ID_IX_imm_out,
    output wire ID_IX_hint_out,
    output wire [2:0] ID_IX_reg_type_out,
    output wire [1:0] ID_IX_load_type_out,
    output wire [6:0] ID_IX_opcode_out,
    output wire [31:0] EXE_MEM_addr_out, 
    output wire [4095:0] MEM_data_out
 
);
    
    // IF Stage Wires
    wire [31:0] IF_instruction_out;
    wire [31:0] IF_pc_out;
    wire [31:0] IF_next_pc;

    // Instantiate IF Stage
    IF_stage fetch_stage (
        .clk(clk),
        .reset(reset),
        .debug_mode(debug_mode),
        .next_pc(IF_next_pc),
        .instruction_in(IF_instruction_in),
        
        .instr_out(IF_instruction_out),
        .pc_out(IF_pc_out)
    );
    
    // IF/ID Pipeline Registers - Buffers
    reg [31:0] IF_ID_instruction;

    // IF/ID Pipeline Register Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IF_ID_instruction <= 32'b0;
        end else begin
            IF_ID_instruction <= IF_instruction_out;
        end
    end

    // Update the next PC for IF stage
    assign IF_next_pc = IF_pc_out + 1;
    assign IF_ID_instruction_out = IF_ID_instruction;
  //--------------------------------------------------------------------------------------------------------

    // ID Stage Wires
    wire [4:0] ID_rs1;
    wire [4:0] ID_rs2;
    wire [3:0] ID_rd;
    wire [4:0] ID_rd_NeuronComp;
    wire [11:0] ID_imm;
    wire ID_hint;
    wire [2:0] ID_reg_type;
    wire [1:0] ID_load_type;
    wire [6:0] ID_opcode;
    wire [6:0] ID_func7;
    // Instantiate ID Stage
    ID_stage decode_stage (
        .clk(clk),
        .instr(IF_ID_instruction),
        .rs1(ID_rs1),
        .rs2(ID_rs2),
        .rd(ID_rd),
        .rd_N(ID_rd_NeuronComp),
        .imm(ID_imm),
        .hint(ID_hint),
        .reg_type(ID_reg_type),
        .load_type(ID_load_type),
        .func7(ID_func7),
        .opcode(ID_opcode)
    );

    // ID/IX Pipeline Registers - Buffers
    reg [4:0] ID_IX_rs1;
    reg [4:0] ID_IX_rs2;
    reg [3:0] ID_IX_rd;
    reg [4:0] ID_IX_rd_neuronComp;
    reg [11:0] ID_IX_imm;
    reg ID_IX_hint;
    reg [2:0] ID_IX_reg_type;
    reg [1:0] ID_IX_load_type;
    reg [6:0] ID_IX_func7;
    reg [6:0] ID_IX_opcode;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_IX_rs1 <= 5'b0;
            ID_IX_rs2 <= 5'b0;
            ID_IX_rd_neuronComp <= 5'b0;
            ID_IX_func7 <= 7'b0;
            ID_IX_rd <= 4'b0;
            ID_IX_imm <= 12'b0;
            ID_IX_hint <= 1'b0;
            ID_IX_reg_type <= 2'b0;
            ID_IX_load_type <= 2'b0;
            ID_IX_opcode <= 7'b0;
        end else begin
            ID_IX_rs1 <= ID_rs1;
            ID_IX_rs2 <= ID_rs2;
            ID_IX_rd_neuronComp <= ID_rd_NeuronComp;
            ID_IX_func7 <= ID_func7;
            ID_IX_rd <= ID_rd;
            ID_IX_imm <= ID_imm;
            ID_IX_hint <= ID_hint;
            ID_IX_reg_type <= ID_reg_type;
            ID_IX_load_type <= ID_load_type;
            ID_IX_opcode <= ID_opcode;
        end
    end
    
    // ---------------------------------------------------------------------------------------------------
    assign ID_IX_rs1_out = ID_IX_rs1;
    assign ID_IX_rd_out = ID_IX_rd;
    assign ID_IX_imm_out = ID_IX_imm;
    assign ID_IX_hint_out = ID_IX_hint;
    assign ID_IX_reg_type_out = ID_IX_reg_type;
    assign ID_IX_load_type_out = ID_IX_load_type;
    assign ID_IX_opcode_out = ID_IX_opcode;
    // IX Stage Wires
    wire [3:0] IX_rd;
    wire IX_hint;
    wire [1:0] IX_reg_type;
    wire [1:0] IX_load_type;
    wire [6:0] IX_opcode;
    wire [31:0] IX_addr;
    wire [4:0] IX_rd_NSR;
    // Instantiate IX Stage
    IX_stage execute_stage (
        .clk(clk),
        .reset(reset),
        .ID_EXE_opcode(ID_IX_opcode),
        .ID_EXE_rs1(ID_IX_rs1),
        .ID_EXE_imm(ID_IX_imm),
        .ID_EXE_rd(ID_IX_rd),
        .ID_EXE_hint(ID_IX_hint),
        .ID_EXE_reg_type(ID_IX_reg_type),
        .ID_EXE_load_type(ID_IX_load_type),
        .ex_rd(IX_rd),
        .ex_rd_N(IX_rd_NSR),
        .ex_hint(IX_hint),
        .ex_reg_type(IX_reg_type),
        .ex_load_type(IX_load_type),
        .ex_opcode(IX_opcode),
        .EXE_MEM_addr(IX_addr)
    );

    reg [31:0] IX_IW_addr;
    reg [3:0] IX_IW_rd;
    reg [4:0] IX_IW_rd_NSR;
    reg IX_IW_hint;
    reg [6:0] IX_IW_opcode;
    reg [1:0] IX_IW_reg_type;
    reg [1:0] IX_IW_load_type;
    
    // IX/IW Pipeline Register Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IX_IW_addr <= 32'b0;
            IX_IW_rd <= 4'b0;
            IX_IW_hint <= 1'b0;
            IX_IW_reg_type <= 2'b0;
            IX_IW_load_type <= 2'b0;
            IX_IW_opcode <= 7'b0;
        end else begin
            IX_IW_addr <= IX_addr;
            IX_IW_opcode <= IX_opcode;
            IX_IW_rd <= IX_rd;
            IX_IW_hint <= IX_hint;
            IX_IW_rd_NSR <= IX_rd_NSR;
            IX_IW_reg_type <= IX_reg_type;
            IX_IW_load_type <= IX_load_type;
        end
    end
    
    assign EXE_MEM_addr_out = IX_IW_addr;
//    // MEM Stage Wires
//    wire [1023:0] MEM_data;
//    wire [1:0] MEM_load_type;
//    wire [1:0] MEM_reg_type;
//    wire [3:0] MEM_rd;
//    IM_stage memory_stage (
//        .clk(clk),
//        .reset(reset),
//        .ex_rd(IX_MEM_rd),
//        .opcode(IX_MEM_opcode),
//        .ex_hint(IX_MEM_hint),
//        .ex_reg_type(IX_MEM_reg_type),
//        .ex_load_type(IX_MEM_load_type),
//        .EXE_MEM_addr(IX_MEM_addr),
//        .MEM_WB_load_type(MEM_load_type),
//        .MEM_WB_rd(MEM_rd),
//        .MEM_WB_reg_type(MEM_reg_type),
//        .MEM_WB_data(MEM_data)
//    );

    // MEM/WB Pipeline Registers
//    reg [1023:0] MEM_WB_data;
//    reg [3:0] MEM_WB_rd;
//    reg [1:0] MEM_WB_load_type;
//    reg [1:0] MEM_WB_reg_type;
//    // MEM/WB Pipeline Register Logic
//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            MEM_WB_data <= 4096'b0;
//            MEM_WB_rd <= 4'b0;
//            MEM_WB_load_type <= 2'b0;
//            MEM_WB_reg_type <= 2'b0;
//        end 
//        else begin
//            MEM_WB_data <= MEM_data;
//            MEM_WB_rd <= MEM_rd;
//            MEM_WB_load_type <= MEM_load_type;
//            MEM_WB_reg_type <= MEM_reg_type;
//        end
//    end
//    assign MEM_data_out = MEM_WB_data;
    //----------------------------------------------------------------------------------------------------------------------------------
    wire write_success;
    // Instantiate WB Stage
    IW_stage iw_stage_inst (
    .clk(clk),
    .reset(reset),
    .EXE_WB_addr(IX_IW_addr),   // Address output from the pipeline stage
    .wb_rd(IX_IW_rd),                 // Destination register index
    .wb_rd_NSR(IX_IW_rd_NSR),            // Not explicitly defined; ensure to provide it
    .wb_load_type(IX_IW_load_type),   // Load type from the pipeline
    .wb_reg_type(IX_IW_reg_type),     // Register type from the pipeline
    .write_success(write_success)    // Output indicating write success
);

    reg WB_write_success;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            WB_write_success <= 1'b0;
            end
        else begin
            WB_write_success <= write_success;
            end
    end
    //assign WRITE_SUCCESS = WB_write_success;
endmodule
