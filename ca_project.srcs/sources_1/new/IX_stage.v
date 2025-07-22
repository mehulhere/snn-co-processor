`timescale 1ns / 1ps

module IX_stage(
    input wire clk,
    input wire reset,
    input wire [6:0] ID_EXE_opcode,
    input wire [4:0] ID_EXE_rs1,    // rs1 (5-bit index into GPR)
    input wire [4:0] ID_EXE_rs2,    // rs2 (5-bit index into GPR)
    input wire [3:0] ID_EXE_rd,   
    input wire [4:0] ID_EXE_rd_N, 
      
    input wire [11:0] ID_EXE_imm,   // Immediate (12-bit signed value)
    input wire [2:0] func3,
    input wire ID_EXE_hint,           
    input wire [2:0] ID_EXE_reg_type, 
    input wire [1:0] ID_EXE_load_type,
    
    output wire [3:0] ex_rd,            
    output wire [4:0] ex_rd_N, 
    output wire ex_hint,           
    output wire [2:0] ex_reg_type,
    output wire [1:0] ex_load_type,   
    output wire [6:0] ex_opcode,
    output reg [31:0] EXE_WB_addr  // 32-bit calculated memory address
);
    //Passing the data
    assign ex_rd = ID_EXE_rd;
    assign ex_hint = ID_EXE_hint;
    assign ex_opcode = ID_EXE_opcode;
    assign ex_reg_type = ID_EXE_reg_type;
    assign ex_load_type = ID_EXE_load_type;
    assign ex_rd_N = ID_EXE_rd_N;
   // ----------------------------------------------------------------------------------------
    
    // Instantiate GPR
    reg [4:0] GPR_read_addr1;   // Address to be read from GPR
    wire [31:0] GPR_read_data1;  // Read Data from read_addr
    reg [4:0] GPR_read_addr2;   // Address to be read from GPR
    wire [31:0] GPR_read_data2;
    reg [4:0] GPR_read_addr3;   // Address to be read from GPR
    wire [31:0] GPR_read_data3;
    GPR gpr (
        .reset(reset),
        .rd_addr1(GPR_read_addr1),    // Pass the rs1 index to the GPR module
        .rd_data1(GPR_read_data1),
        .rd_addr2(GPR_read_addr2),    // Pass the rs1 index to the GPR module
        .rd_data2(GPR_read_data2),      // Read the base address from GPR
        .rd_addr3(GPR_read_addr3),    // Pass the rs1 index to the GPR module
        .rd_data3(GPR_read_data3)      // Read the base address from GPR
    );
    
     // ----------------------------------------------------------------------------------------
    // Instantiate NTR
    wire NTR_write_enable;
    wire [127:0] NTR_read_data;
    wire [127:0] NTR_write_data;
    
    assign NTR_write_enable = 0;
    NTR ntr_inst (
        .clk(clk),
        .reset(reset),
        .write_enable(NTR_write_enable),
        .write_data(NTR_write_data),
        .read_data(NTR_read_data)
    );
    
     // ----------------------------------------------------------------------------------------
    
    // Instantiate NSR
    reg NSR_write_enable;            
    wire [4095:0] NSR_read_data1;
    reg [4095:0] NSR_write_data;
    NSR nsr_inst (
        .clk(clk),
        .reset(reset),
        .write_enable(NSR_write_enable),
        .write_data(NSR_write_data),
        .read_data(NSR_read_data1) 
    );
    
    reg [4095:0] NSR_read_data;
    always @(*) begin
    NSR_read_data = NSR_read_data1;
    end

    // ----------------------------------------------------------------------------------------

    // Instantiate WVR
    wire WVR_write_enable;                         
    reg [3:0] WVR_rg_addr;                // Address of the WVR register (0-15)
    wire [1023:0] WVR_read_data1;          // Data read from each WVR instance (not used in this example)
    wire [1023:0] WVR_Input_Data;
    wire WVR_write_success;
    
    assign WVR_write_enable = 0;
    WVR wvr_inst (
        .reset(reset),
        .write(WVR_write_enable),
        .rd_addr(WVR_rg_addr),
        .load_type(ex_load_type),
        .Input_Data(WVR_Input_Data),
        .Output_Data(WVR_read_data1),
        .write_success(WVR_write_success)
    );
    
    reg [1023:0] WVR_read_data;
    always @(*) begin
    WVR_read_data = WVR_read_data1;
    end

     // ----------------------------------------------------------------------------------------

    // Instantiate SVR module
    wire SVR_write_enable;
    reg [3:0] SVR_rg_addr;                 // Address of the SVR register (0-15)
    wire [511:0] SVR_read_data;           // Data read from SVR (not used in this example)
    wire [511:0] SVR_Input_Data;
    wire SVR_write_success;
    
    assign SVR_write_enable = 0;
    SVR svr_inst (
        .reset(reset),
        .write(SVR_write_enable),
        .rd_addr(SVR_rg_addr),
        .load_type(ex_load_type),
        .Input_Data(SVR_Input_Data),
        .Output_Data(SVR_read_data),
        .write_success(SVR_write_success)
    );
    
     // ----------------------------------------------------------------------------------------
    // Define global leaky parameters
        parameter [7:0] LEAKY_CURRENT = 8'd2;  // Leaky factor for current (first 8 bits)
        parameter [7:0] LEAKY_VOLTAGE = 8'd1;  // Leaky factor for voltage (next 8 bits)
        parameter [7:0] LEAKY_THRESHOLD = 8'd3; // Leaky factor for threshold (next 8 bits)
        reg [7:0] neuron_current;
         reg [7:0] neuron_voltage;
         reg [7:0] neuron_threshold;
        
        
     // Sign-extend the 12-bit immediate to 32 bits
    wire [31:0] imm_ext_1 = {{20{ID_EXE_imm[11]}}, ID_EXE_imm};
    
    reg [4095:0] NSR_write_data1;
    integer i;
    reg [31:0] NSR_read_temp;
    reg [7:0] current_sum [15:0]; // 16 registers, each 7 bits wide
    reg [63:0] WVR_read_data_array [15:0];
    reg [31:0] SVR_read_data_array [15:0];
    reg [31:0] NSR_data_array [127:0];
    
    always @(*) begin
    // Fill WVR_read_data_array from WVR_read_data
        for (i = 0; i < 16; i = i + 1) begin
            WVR_read_data_array[i] = WVR_read_data[i * 64 +: 64]; // Extract 64 bits for each array element
        end
    
        // Fill SVR_read_data_array from SVR_read_data
        for (i = 0; i < 16; i = i + 1) begin
            SVR_read_data_array[i] = SVR_read_data[i * 32 +: 32]; // Extract 32 bits for each array element
        end
        
        // Fill NSR_read_data_array from NSR_read_data
        for (i = 0; i < 128; i = i + 1) begin
            NSR_data_array[i] = NSR_read_data[i * 32 +: 32]; // Extract 32 bits for each array element
        end
    end
    
    always @(posedge clk) begin 
            for (i = 0; i < 16; i = i + 1) begin
            current_sum[i] = 8'b0;
        end
    end
    
    always @(*) begin
        if (reset) begin
            EXE_WB_addr = 32'b0;
            NSR_write_enable = 0;
            current_sum[0] = 16'b0000000000000000;
        end 
        else if (ID_EXE_opcode == 7'b0000000 || ID_EXE_opcode == 7'b0000001) begin
            GPR_read_addr1 = ID_EXE_rs1;
            EXE_WB_addr = GPR_read_data1 + imm_ext_1;
            NSR_write_enable = 0;
        end
        else if (ID_EXE_opcode == 7'b0000010) begin
            GPR_read_addr1 = ID_EXE_rs1;
            GPR_read_addr2 = ID_EXE_rs2;
            EXE_WB_addr = GPR_read_data1 + GPR_read_data2; 
            NSR_write_enable = 0;
        end
        else if (ID_EXE_opcode == 7'b0000011) begin
                GPR_read_addr1 = ID_EXE_rd_N; //NSR
                GPR_read_addr2 = ID_EXE_rs1; //WVR
                GPR_read_addr3 = ID_EXE_rs2; //SVR
                
                if (func3 == 3'b000) begin //convh
                    for (i = 0; i < 32; i = i + 1) begin 
                    
                        if (SVR_read_data_array[GPR_read_data3][i] == 1'b1) begin
                            if (NTR_read_data[i] == 1'b1) begin
                                current_sum[0] = current_sum[0] + WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Excitatory neuron: Add weight to NSR
                            end else begin
                                current_sum[0] = current_sum[0] - WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Inhibitory neuron: Subtract weight from NSR
                            end
                            
                        end
                    end 
                    NSR_data_array[GPR_read_addr1] = NSR_data_array[GPR_read_addr1] + current_sum[0];   
                end
                else if (func3 == 3'b001) begin //conva
                    for (i = 0; i < 128; i = i + 1) begin
                        if (SVR_read_data_array[GPR_read_data3][i % 32] == 1'b1) begin
                            if (NTR_read_data[i] == 1'b1) begin
                                current_sum[0] = (current_sum[0] + WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]) & 8'hFF; // Excitatory neuron: Add weight to NSR
                            end else begin
                                current_sum[0] = current_sum[0] - WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Inhibitory neuron: Subtract weight from NSR
                            end
                        end
                        $display("SVR[%0d] = %b", i, SVR_read_data_array[GPR_read_data3][i % 32]);
                        $display("curr_sum[%0d] = %b", i, current_sum[0]);
                        if(i%32==0) begin
                            GPR_read_addr3 = GPR_read_addr3 + 1;
                        end
                    end 
                    NSR_data_array[GPR_read_addr1] = NSR_data_array[GPR_read_addr1] + current_sum[0];
                end
                else if (func3 == 3'b010) begin //convmh
                    for (i = 0; i < 128; i = i + 1) begin
                        SVR_rg_addr = GPR_read_data3 + i/32;
                        if (SVR_read_data_array[GPR_read_data3][i % 32] == 1'b1) begin
                            if (NTR_read_data[i] == 1'b1) begin    
                                current_sum[i/32] = current_sum[i/32] + WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Excitatory neuron: Add weight to NSR
                            end else begin
                                current_sum[i/32] = current_sum[i/32] - WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Inhibitory neuron: Subtract weight from NSR
                            end
                        end
                        if(i%32==0) begin
                            GPR_read_addr3 = GPR_read_addr3 + 1;
                        end
                    end
                    for (i = 0; i < 4; i = i + 1) begin
                        NSR_data_array[(GPR_read_addr1 + i) % 128] = NSR_data_array[(GPR_read_addr1 + i) % 128] + current_sum[i];
                    end
                end
                else if (func3 == 3'b011) begin //convma
                    for (i = 0; i < 128; i = i + 1) begin
                        if (SVR_read_data_array[GPR_read_data3][i % 32] == 1'b1) begin
                            if (NTR_read_data[i] == 1'b1) begin
                                current_sum[i/8] =  current_sum[i/8] + WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Excitatory neuron: Add weight to NSR
                            end else begin
                                current_sum[i/8] =  current_sum[i/8] - WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Inhibitory neuron: Subtract weight from NSR
                            end
                        end
                    end
                    for (i = 0; i < 16; i = i + 1) begin
                        NSR_data_array[(GPR_read_addr1 + i) % 128] = NSR_data_array[(GPR_read_addr1 + i) % 128] + current_sum[i];
                    end
                end
                else if (func3 == 3'b100) begin //doth
                    if (SVR_read_data_array[GPR_read_data3][0] == 1'b1) begin
                        for (i = 0; i < 32; i = i + 1) begin
                            if (NTR_read_data[i] == 1'b1) begin
                                NSR_data_array[(GPR_read_addr1 + i) % 128] = NSR_data_array[(GPR_read_addr1 + i) % 128] + WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Excitatory neuron: Add weight to NSR
                            end else begin
                                NSR_data_array[(GPR_read_addr1 + i) % 128] = NSR_data_array[(GPR_read_addr1 + i) % 128] - WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Inhibitory neuron: Subtract weight from NSR
                            end
                        end
                    end
                end
                else if (func3 ==3'b101) begin //dota
                    SVR_rg_addr = GPR_read_data3;
                    if (SVR_read_data_array[GPR_read_data3][0] == 1'b1) begin
                        for (i = 0; i < 128; i = i + 1) begin
                            if (NTR_read_data[i] == 1'b1) begin
                                $display("NSR_ARRAY[%0d] = %b", i, NSR_data_array[i]);
                                $display("NSR_ARRAY[%0d] = %b", i, WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]);
                                NSR_data_array[(GPR_read_addr1 + i) % 128] = NSR_data_array[(GPR_read_addr1 + i) % 128] + WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Excitatory neuron: Add weight to NSR
                            end else begin
                                NSR_data_array[(GPR_read_addr1 + i) % 128] = NSR_data_array[(GPR_read_addr1 + i) % 128] - WVR_read_data_array[GPR_read_data2 + i/8][(i % 8) * 8 +: 8]; // Inhibitory neuron: Subtract weight from NSR
                            end
                        end
                    end
                end
                for (i = 0; i < 128; i = i + 1) begin
                    NSR_write_data1[i * 32 +: 32] = NSR_data_array[i]; // Pack 32 bits into the correct position
                    $display("NSR_ARRAY[%0d] = %b", i, NSR_data_array[i]);
                end 
            end
        else if (ID_EXE_opcode == 7'b0000100) begin // Update
            GPR_read_addr1 = ID_EXE_rs1;  // Address for NSR base
            GPR_read_addr2 = ID_EXE_rs2;  // Address for auxiliary registers or WVR
            GPR_read_addr3 = ID_EXE_rd_N; // Address for neuron state data (NSR)
        
            // Iterate over all 128 neurons
            
                // Read the neuron state for this index
                NSR_read_temp = NSR_data_array[i]; // 32 bits: current (8), voltage (8), threshold (8), unused (8)
        
                // Extract components from the 32-bit neuron state
                neuron_current = NSR_read_temp[7:0];
                neuron_voltage = NSR_read_temp[15:8];
                neuron_threshold = NSR_read_temp[23:16];
        
               if (func3 == 3'b000) begin
                    // Update 1 neuron (e.g., neuron 0)
                    for (i = 0; i < 1; i = i + 1) begin
                        neuron_current = NSR_data_array[i][7:0] - LEAKY_CURRENT;
                        neuron_voltage = NSR_data_array[i][15:8] - LEAKY_VOLTAGE;
                        neuron_threshold = NSR_data_array[i][23:16] - LEAKY_THRESHOLD;
                
                        // Ensure non-negative values
                        if (neuron_current < 0) neuron_current = 8'b0;
                        if (neuron_voltage < 0) neuron_voltage = 8'b0;
                        if (neuron_threshold < 0) neuron_threshold = 8'b0;
                
                        // Write back updated values
                        NSR_data_array[i] = {8'b0, neuron_threshold, neuron_voltage, neuron_current};
                    end

                end 
                else if (func3 == 3'b001) begin
                    // Update 32 neurons (e.g., neurons 0-31)
                    for (i = 0; i < 32; i = i + 1) begin
                        neuron_current = NSR_data_array[i][7:0] - LEAKY_CURRENT;
                        neuron_voltage = NSR_data_array[i][15:8] - LEAKY_VOLTAGE;
                        neuron_threshold = NSR_data_array[i][23:16] - LEAKY_THRESHOLD;
                
                        // Ensure non-negative values
                        if (neuron_current < 0) neuron_current = 8'b0;
                        if (neuron_voltage < 0) neuron_voltage = 8'b0;
                        if (neuron_threshold < 0) neuron_threshold = 8'b0;
                
                        // Write back updated values
                        NSR_data_array[i] = {8'b0, neuron_threshold, neuron_voltage, neuron_current};
                    end
                
                end else if (func3 == 3'b010) begin
                    // Update all 128 neurons
                    for (i = 0; i < 128; i = i + 1) begin
                        neuron_current = NSR_data_array[i][7:0] - LEAKY_CURRENT;
                        neuron_voltage = NSR_data_array[i][15:8] - LEAKY_VOLTAGE;
                        neuron_threshold = NSR_data_array[i][23:16] - LEAKY_THRESHOLD;
                
                        // Ensure non-negative values
                        if (neuron_current < 0) neuron_current = 8'b0;
                        if (neuron_voltage < 0) neuron_voltage = 8'b0;
                        if (neuron_threshold < 0) neuron_threshold = 8'b0;
                
                        // Write back updated values
                        NSR_data_array[i] = {8'b0, neuron_threshold, neuron_voltage, neuron_current};
                    end
                
        // Recombine the updated state into the 32-bit register
        NSR_data_array[i] = {8'b0, neuron_threshold, neuron_voltage, neuron_current};
        end
    // Write back the updated NSR_data_array into NSR_write_data
    //NSR_write_enable = 1;
    //for (i = 0; i < 128; i = i + 1) begin
      //  NSR_write_data1[i * 32 +: 32] = NSR_data_array[i];
    //end
end
        end
        
        always @(*) begin
            NSR_write_enable = 1;
            NSR_write_data = NSR_write_data1;
        end
        
endmodule