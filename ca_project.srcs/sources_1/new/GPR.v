`timescale 1ns / 1ps

module GPR (
    input wire reset,
    input wire [4:0] rd_addr1,     
    input wire [4:0] rd_addr2,
    input wire [4:0] rd_addr3,
    output reg [31:0] rd_data1,    
    output reg [31:0] rd_data2,
    output reg [31:0] rd_data3
);

    reg [31:0] reg_file [0:31];   
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            reg_file[i] = i ;  // Set register values to 1, 2, 3, ..., 32
        end
    end
    always @(posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'b0;
            end
        end
    end
    always @(*) begin
        rd_data1 = reg_file[rd_addr1]; 
        rd_data2 = reg_file[rd_addr2];
        rd_data3 = reg_file[rd_addr3];
    end
endmodule

