`timescale 1ns / 1ps


module tb_IW_stage;

    // Testbench signals
    reg reset;
    reg [31:0] EXE_WB_addr;
    reg [3:0] wb_rd;
    reg [1:0] wb_load_type;
    reg [2:0] wb_reg_type;
    wire write_success;

    // Internal signals to monitor all register values
    wire [63:0] WVR_reg [0:15];  // Array to hold 16 WVR registers
    wire [31:0] SVR_reg [0:15];   // Array to hold 16 SVR registers

    // Instantiate the IW_stage module
    IW_stage uut (
        .reset(reset),
        .EXE_WB_addr(EXE_WB_addr),
        .wb_rd(wb_rd),
        .wb_load_type(wb_load_type),
        .wb_reg_type(wb_reg_type),
        .write_success(write_success)
    );

    // Assign monitored values from all 16 WVR and SVR registers
    genvar idx;
    generate
        for (idx = 0; idx < 16; idx = idx + 1) begin : gen_assign
            assign WVR_reg[idx] = uut.wvr_inst.WVR_reg[idx];
            assign SVR_reg[idx] = uut.svr_inst.SVR_reg[idx];
        end
    endgenerate

    // Initial block to initialize and test different scenarios
    integer i;
    initial begin
        // Initialize the reset signal
//        reset = 0;


        // Test for WVR, load type 00 (256 bits), reg type 00
        #10;
        EXE_WB_addr = 4'b100;
        wb_rd = 4'd0;
        wb_load_type = 2'b00;
        wb_reg_type = 2'b00;
        #10;

        // Test for WVR, load type 01 (256 bits), reg type 00
        #10;
        EXE_WB_addr = 4'b100;
        wb_rd = 4'd1;
        wb_load_type = 2'b01;
        wb_reg_type = 2'b00;
        #10;

        // Test for WVR, load type 10 (1024 bits), reg type 00
        #10;
        EXE_WB_addr = 4'b100;
        wb_rd = 4'd2;
        wb_load_type = 2'b10;
        wb_reg_type = 2'b00;
        #10;

        // Test for SVR, load type 00 (32 bits), reg type 01
        #10;
        EXE_WB_addr = 4'b101;
        wb_rd = 4'd0;
        wb_load_type = 2'b00;
        wb_reg_type = 2'b01;
        #10;

        // Test for SVR, load type 01 (128 bits), reg type 01
        #10;
        EXE_WB_addr = 4'b101;
        wb_rd = 4'd1;
        wb_load_type = 2'b01;
        wb_reg_type = 2'b01;
        #10;

        // Test for SVR, load type 10 (512 bits), reg type 01
        #10;
        EXE_WB_addr = 4'b101;
        wb_rd = 4'd2;
        wb_load_type = 2'b10;
        wb_reg_type = 2'b01;
        #10;

        // Finish the simulation
        $finish;
    end


    // Monitor the outputs
    initial begin
        $monitor("Time = %0d, Reset = %b, wb_rd = %d, wb_load_type = %b, wb_reg_type = %b, write_success = %b", 
                 $time, reset, wb_rd, wb_load_type, wb_reg_type, write_success);
        // Display the values of all WVR and SVR registers
        for (i = 0; i < 16; i = i + 1) begin
            #1; // Adding a slight delay to help with register updates
            $display("WVR[%0d] = %h, SVR[%0d] = %h", i, WVR_reg[i], i, SVR_reg[i]);
        end
    end

endmodule
