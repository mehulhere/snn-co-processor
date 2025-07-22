`timescale 1ns / 1ps
//reg_type 000 wvr 
// 001 svr
// 010 rpr
// 011 vtr
// 100 ntr
// 101 nsr

module ID_stage (
    input wire clk,
    input wire [31:0] instr,      
    output reg [4:0] rs1,         
    output reg [4:0] rs2,
    output reg [3:0] rd,          
    output reg [4:0] rd_N,
    output reg [11:0] imm,        
    output wire hint,     
    output wire [3:0] func3,
    output reg [2:0] reg_type,     
    output reg [1:0] load_type,           
    output wire [6:0] opcode
);

    assign opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] func7 = instr[31:25];     
    reg tempHint = 1'b0;       
    always @(*) begin
        if (opcode == 7'b0000000 || opcode == 7'b0000001) begin
             rd = instr[10:7];
             rs1 = instr[19:15];
             imm = instr[31:20];            
        end
        else if (opcode == 7'b0000010 || opcode == 7'b0000011 || opcode == 7'b0000100 || opcode == 7'b0000101) begin
             rd_N = instr[11:7];
             rs1 = instr[19:15]; 
             rs2 = instr[24:20];        
        end
    end
    always @(*) begin
    case (opcode)
        7'b0000000 : begin 
            case (funct3)
                3'b000: begin
                    reg_type = 3'b000; // wvr  
                    load_type = 2'b00; //00 1
                    tempHint = 0;
                end
                3'b001: begin
                    reg_type = 3'b000; // wvr  
                    tempHint = 1;
                    load_type = 2'b01;  // 4    
                end
                3'b010: begin
                    reg_type = 3'b000;
                    tempHint = 1;
                    load_type = 2'b10;// 16     
                end
            endcase
        end

        7'b0000001 : begin
            case (funct3)
                3'b000: begin
                    reg_type = 3'b001;  //svr
                    tempHint = 0;
                    load_type = 2'b00;
                end
                3'b001: begin
                    reg_type = 3'b001;  //svr
                    tempHint = 1;
                    load_type = 2'b01;   
                end
                3'b010: begin
                    reg_type = 3'b001; //svr
                    tempHint = 1;  
                    load_type = 2'b10;
                end
            endcase
        end
        7'b0000010 : begin //Neuron state and parameter laoding
            case(func7) 
                7'b0000001: begin
                    reg_type = 3'b010;  //rpr
                    load_type = 2'b00;
                    
                end
                7'b0000010: begin
                    reg_type = 3'b011;  //vtr
                    load_type = 2'b00;
                                            
                end
                7'b0000011: begin
                    reg_type = 3'b100; //ntr
                    load_type = 2'b00;
                    
                end 
            endcase  
        end
        7'b0000011 : begin // Neuron Current Computing
            case(func3) 
                7'b001: begin // convh
                        reg_type = 3'b101;
                end
                7'b001: begin //conva
                    reg_type = 3'b101;
                end
                7'b010: begin //convmh
                    reg_type = 3'b101;
                end 
                7'b011: begin //convma
                    reg_type = 3'b101;
                end
                7'b100: begin //doth
                    reg_type = 3'b101;
                end
                7'b101: begin //dota
                    reg_type = 3'b101;
                end
            endcase  
        end
        
        7'b0000100 : begin // Update
            case(func3) 
                7'b001: begin // convh
                    reg_type = 3'b101;
                end
                7'b001: begin //conva
                    reg_type = 3'b101;
                end
                7'b010: begin //convmh
                    reg_type = 3'b101;
                end 
                endcase
        end
        default: begin
                reg_type = 2'b00;  
                load_type = 0;
            end
        endcase
    end
    assign hint = tempHint;
endmodule
