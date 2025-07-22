`timescale 1ns / 1ps

module tb_IW_neuronstates;

    // Testbench signals
    reg reset;
    reg [31:0] EXE_WB_addr;
    reg [3:0] wb_rd;
    reg [1:0] wb_load_type;
    reg [2:0] wb_reg_type;
    wire write_success;

// Internal signals to monitor all register values
    wire [127:0] NTR_reg;          // 128-bit Neuron Type Registers
    wire [1023:0] RPR_reg;         // 128 Refractory Period Registers (8 bits each)
    wire [1023:0] VTR_reg;         // 128 Threshold Voltage Registers (8 bits each)

    // Instantiate the IW_stage module
    IW_stage uut (
        .reset(reset),
        .EXE_WB_addr(EXE_WB_addr),
        .wb_rd(wb_rd),
        .wb_load_type(wb_load_type),
        .wb_reg_type(wb_reg_type),
        .write_success(write_success)
    );
    

    // Assign monitored values from NTR, VTR, and RPR registers
    // Assuming IW_neuronstates has submodules named ntr_inst, vtr_inst, and rpr_inst
    assign NTR_reg = uut.ntr_inst.read_data;
    assign VTR_reg = uut.vtr_inst.read_data;
    assign RPR_reg = uut.rpr_inst.read_data;

    // Initial block to initialize and test different scenarios
    integer i;
    initial begin
        // Initialize the reset signal
        reset = 0;

        // Test for NTR
        #10;
        EXE_WB_addr = 4'b100;
        wb_rd = 4'd2;
        wb_load_type = 2'b00;
        wb_reg_type = 3'b100;
        #10;
        
        // Test for RPR
        #10;
        EXE_WB_addr = 4'b100;
        wb_rd = 4'd0;
        wb_load_type = 2'b00;
        wb_reg_type = 3'b010;
        #10;

        // Test for VTR
        #10;
        EXE_WB_addr = 4'b100;
        wb_rd = 4'd1;
        wb_load_type = 2'b00;
        wb_reg_type = 3'b011;
        #10;


        // Finish the simulation
        $finish;
    end


    // Monitor the outputs
    initial begin
        // Monitor control signals and write_success
        $monitor("Time = %0d | Reset = %b | wb_rd = %d | wb_load_type = %b | wb_reg_type = %b | write_success = %b", 
                 $time, reset, wb_rd, wb_load_type, wb_reg_type, write_success);

        // Display the values of all NTR, VTR, and RPR registers
        // To avoid excessive output, you might want to limit the number of displayed registers
        // Here, we display the first 4 registers as an example

        // Wait for some time before displaying register values
        #15;

        // Display NTR Registers
        $display("---- NTR Registers ----");
        for (i = 0; i < 128; i = i + 1) begin
            $display("NTR[%0d] = %b", i, NTR_reg[i]);
        end

        // Display VTR Registers
        $display("---- VTR Registers ----");
        for (i = 0; i < 128; i = i + 1) begin
            $display("VTR[%0d] = %h", i, VTR_reg[(i*8) +:8]);
        end

        // Display RPR Registers
        $display("---- RPR Registers ----");
        for (i = 0; i < 128; i = i + 1) begin
            $display("RPR[%0d] = %h", i, RPR_reg[(i*8) +:8]);
        end
    end

endmodule
