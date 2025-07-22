`timescale 1ns / 1ps


module tb_IF_stage;

    // Testbench signals
    reg clk;
    reg reset;
    reg debug_mode;
    reg [31:0] next_pc;
    reg [31:0] instruction_in;
    wire [31:0] instr_out;
    wire [31:0] pc_out;

    // Instantiate the IF_stage module
    IF_stage uut (
        .clk(clk),
        .reset(reset),
        .debug_mode(debug_mode),
        .next_pc(next_pc),
        .instruction_in(instruction_in),
        .instr_out(instr_out),
        .pc_out(pc_out)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns period clock

    initial begin
        
        clk = 0;
        reset = 1;
        debug_mode = 0;
        next_pc = 32'd0;
        instruction_in = 32'd0;

        // Wait for a few clock cycles
        #10;
        
        // Release reset
        reset = 0;
    end

    // Apply instructions and update PC on positive edge of the clock after reset
    always @(posedge clk) begin
        if (!reset) begin
            case (next_pc)
                32'd0: begin
                    next_pc <= 32'd4;
                    instruction_in <= 32'b00000000000100001000000010000000;
                end
                32'd4: begin
                    next_pc <= 32'd8;
                    instruction_in <= 32'b00000000001100011000000110000000;
                end
                32'd8: begin
                    next_pc <= 32'd12;
                    instruction_in <= 32'b00000000001000010000000100000000;
                end
                32'd12: begin
                    next_pc <= 32'd16;
                    instruction_in <= 32'b00000000000100001001000010000000;
                end
                32'd16: begin
                    next_pc <= 32'd20;
                    instruction_in <= 32'b00000000001100011001000110000000;
                end
                32'd20: begin
                    next_pc <= 32'd24;
                    instruction_in <= 32'b00000000001000010001000100000000;
                end
                32'd24: begin
                    next_pc <= 32'd28;
                    instruction_in <= 32'b00000000000100001010000010000000;
                end
                32'd28: begin
                    next_pc <= 32'd32;
                    instruction_in <= 32'b00000000001100011010000110000000;
                end
                32'd32: begin
                    next_pc <= 32'd36;
                    instruction_in <= 32'b00000000001000010010000100000000;
                end
                default: begin
                    next_pc <= next_pc; // Maintain current value
                    instruction_in <= 32'b0; // No instruction
                end
            endcase
        end
    end

    // Monitor the outputs
    initial begin
        $monitor("Time = %0d, PC = %0h, Instruction = %0h, Instr_Out = %0h, PC_Out = %0h", 
                 $time, next_pc, instruction_in, instr_out, pc_out);
    end
endmodule

