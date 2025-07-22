`timescale 1ns / 1ps

module IW_stage (
    input wire reset,
    input wire clk,
    // Inputs from Memory Stage
    input wire [31:0] EXE_WB_addr,
    input wire [3:0] wb_rd,
    input wire [4:0] wb_rd_NSR,            // Destination register index (to select WVR or SVR)
    input wire [1:0] wb_load_type,     // Load type (00 = smallest, 01 = medium, 10 = largest)
    input wire [2:0] wb_reg_type,      // Register type (00 = WVR, 01 = SVR)
    
    // Outputs
    output wire write_success          // Indicates if the write was successful
);

    // ----------------------------------------------------------------------------------------
    // Control signals for WVR
    reg write_wvr;                         
    reg [1024:0] Input_Data_WVR;            // Data to be written to WVR
    reg [3:0] rg_addr_WVR;                 // Address of the WVR register (0-15)
    wire [63:0] Output_Data_WVR;          // Data read from each WVR instance (not used in this example)
    wire write_success_wvr;                // Write success signal from WVR


    reg write_enable_rpr = 0;
    reg write_enable_nsr = 0;
    reg write_enable_vtr = 0;
    reg write_enable_ntr = 0;
    reg [2047:0] write_data_rpr;
    reg [2047:0] write_data_vtr;
    reg [128:0] write_data_ntr;
    
    
    wire [1024:0] MEM_WB_data;
    reg [15:0] num_bytes;
    Memory memory_inst(
        .address(EXE_WB_addr),     // Base address from execute stage
        .num_bytes(num_bytes),      // Number of bytes to read
        .data_out(MEM_WB_data)      // Output data from memory
    );
    
    // Instantiate WVR module
    WVR wvr_inst (
        .reset(reset),
        .write(write_wvr),
        .rd_addr(rg_addr_WVR),
        .load_type(wb_load_type),
        .Input_Data(Input_Data_WVR),
        .Output_Data(Output_Data_WVR),
        .write_success(write_success_wvr)
    );

    // ----------------------------------------------------------------------------------------

    // Control signals for SVR
    reg write_svr;
    reg [511:0] Input_Data_SVR;             // Data to be written to SVR
    reg [3:0] rg_addr_SVR;                 // Address of the SVR register (0-15)
    wire [31:0] Output_Data_SVR;           // Data read from SVR (not used in this example)
    wire write_success_svr;                // Write success signal from SVR

    // Instantiate SVR module
    SVR svr_inst (
        .reset(reset),
        .write(write_svr),
        .rd_addr(rg_addr_SVR),
        .load_type(wb_load_type),
        .Input_Data(Input_Data_SVR),
        .Output_Data(Output_Data_SVR),
        .write_success(write_success_svr)
    );
    
    
    // ----------------------------------------------------------------------------------------
    
    wire [32:0] write_data_nsr;
    wire [32:0] read_data_nsr;
    // Instantiate the NSR module
    NSR NSR_inst (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable_nsr),
        .write_data(write_data_nsr),
        .read_data(read_data_nsr)
    );
    wire [6:0] address_rpr;
    wire [15:0] read_data_rpr;
    
    
    // ----------------------------------------------------------------------------------------
    
    
    // Instantiate the RPR module
    RPR rpr_inst (
    .clk(clk),
    .reset(reset),
    .write_enable(write_enable_rpr),
    .write_data(write_data_rpr),
    .read_data(read_data_rpr)
    );
    wire [6:0] address_vtr;
    wire [15:0] read_data_vtr;
    
    // ----------------------------------------------------------------------------------------
    
    
    // Instantiate the VTR module
    VTR vtr_inst (
    .clk(clk),
    .reset(reset),
    .write_enable(write_enable_vtr),
    .write_data(write_data_vtr),
    .read_data(read_data_vtr)
    );
    wire [6:0] address_ntr;
    wire [127:0] read_data_ntr;
    
    // ----------------------------------------------------------------------------------------
    
    
    // Instantiate the NTR module
    NTR ntr_inst (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable_ntr),
        .write_data(write_data_ntr),
        .read_data(read_data_ntr)
    );


    // ----------------------------------------------------------------------------------------

    integer i = 0;
    // Combinational logic to handle writing to WVRs or SVRs
    always @(*) begin
        // Reset logic
        if (reset) begin
            write_wvr = 0;
            write_svr = 0;
            rg_addr_WVR = 4'b0;
            rg_addr_SVR = 4'b0;
        end 
        else begin
            // Select the appropriate register type and set control signals accordingly
            case (wb_reg_type)
                3'b000: begin // Write in WVR
                
                    case(wb_load_type)
                        2'b00: num_bytes = 8;   // Load 64 bits (8 bytes)
                        2'b01: num_bytes = 32;  // Load 256 bits (32 bytes)
                        2'b10: num_bytes = 128;  // Load 1024 bits (128 bytes)
                        default: num_bytes = 8; // Default to 64 bits
                    endcase
                    
                    write_wvr = 1;
                    write_svr = 0; // Disable SVR write
                    write_enable_rpr = 0; // Disable SVR write
                    write_enable_nsr = 0; // Disable SVR write
                    write_enable_vtr = 0; // Disable SVR write
                    write_enable_ntr = 0; // Disable SVR write
                    
                    rg_addr_WVR = wb_rd;
                    Input_Data_WVR = MEM_WB_data;
                    
                end
                3'b001: begin // Write in SVR
                    
                    case(wb_load_type)
                        2'b00: num_bytes = 4;   // Load 32 bits (4 bytes)
                        2'b01: num_bytes = 16;  // Load 128 bits (16 bytes)
                        2'b10: num_bytes = 64;  // Load 512 bits (64 bytes)
                        default: num_bytes = 4; // Default to 8 bits
                    endcase
                    
                    write_svr = 1;
                    write_wvr = 0; // Disable WVR write
                    write_enable_rpr = 0; // Disable SVR write
                    write_enable_nsr = 0; // Disable SVR write
                    write_enable_vtr = 0; // Disable SVR write
                    write_enable_ntr = 0; // Disable SVR write
                    
                    rg_addr_SVR = wb_rd;
                    // Extract the appropriate bits for the SVR module based on load type
                    case (wb_load_type)
                        2'b00: Input_Data_SVR = MEM_WB_data[31:0];      // 32 bits for 1 SVR register
                        2'b01: Input_Data_SVR = MEM_WB_data[127:0];     // 128 bits for 4 SVR registers
                        2'b10: Input_Data_SVR = MEM_WB_data[512:0];     // 512 bits for 16 SVR registers
                        default: Input_Data_SVR = 512'b0;               // Default case to prevent latch inference
                    endcase
                end
 
                 3'b010: begin // Write in RPR
                    write_enable_rpr = 1;
                    write_enable_nsr = 0; // Disable SVR write
                    write_enable_vtr = 0; // Disable SVR write
                    write_enable_ntr = 0; // Disable SVR write
                    num_bytes = 128;
                    write_data_rpr = MEM_WB_data[1023:0];
                    if (1) $display("MEM_WB_data[%0d] = %h", i, MEM_WB_data[i]); // Debug first few entries
                 end
                 
                 3'b011: begin // Write in VTR
                    write_enable_vtr = 1;
                    write_enable_rpr = 0; // Disable SVR write
                    write_enable_nsr = 0; // Disable SVR write
                    write_enable_ntr = 0; // Disable SVR write
                    num_bytes = 128;
                    write_data_vtr = MEM_WB_data[1023:0];
                 end
                 
                 3'b100: begin // Write in NTR
                    write_enable_ntr = 1;
                    write_enable_rpr = 0; // Disable SVR write
                    write_enable_nsr = 0; // Disable SVR write
                    write_enable_vtr = 0; // Disable SVR write
                    num_bytes = 16;
                    write_data_ntr = MEM_WB_data[127:0];
                 end
                 
                default: begin
                    write_wvr = 0; // Disable SVR write
                    write_svr = 0; // Disable SVR write
                    write_enable_rpr = 0; // Disable SVR write
                    write_enable_nsr = 0; // Disable SVR write
                    write_enable_vtr = 0; // Disable SVR write
                    write_enable_ntr = 0; // Disable SVR write
                end
            endcase
        end
    end

    // Determine if the write was successful based on the register type
    assign write_success = (wb_reg_type == 2'b00) ? write_success_wvr : write_success_svr;

endmodule