`timescale 1ns / 1ps


module Registers(
    input clk,
    input reset,
    input [255:0] data_in,         //25000 10000 250   
    input [1:0] select_reg,        
    input [4:0] index,              
    input load,                    
    input read,                  
    output reg [255:0] data_out    //gpr  
);

reg [255:0] WVR [0:15];   
reg [32:0] SVR [0:15];   
reg [255:0] SOR [0:15];   
reg [255:0] NSR [0:15];
integer i;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 16; i = i + 1) begin
            WVR[i] <= 255'b0;
            SVR[i] <= 32'b0;
            SOR[i] <= 255'b0;
            NSR[i] <= 255'b0;
        end
    end 
    else if (load) begin
        case (select_reg)
            4'b0001: WVR[index] <= data_in;// check1 = 1 wvr[index] wvr[index +1 ] wvr[index +2] 
            4'b0010: SVR[index] <= data_in; 
            4'b0100: SOR[index] <= data_in; 
            4'b1000: NSR[index] <= data_in; 
        endcase
    end
end

always @(posedge clk) begin
    if (read) begin
        case (select_reg)
            4'b0001: data_out <= WVR[index]; 
            4'b0010: data_out <= SVR[index]; 
            4'b0100: data_out <= SOR[index]; 
            4'b1000: data_out <= NSR[index]; 
        endcase
    end
end
endmodule


