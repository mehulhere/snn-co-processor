//module IF_stage (
//    input wire clk,                  
//    input wire reset,                
//    input wire debug_mode,           
//    input wire [31:0] next_pc,       
//    output reg [31:0] instr_out,     
//    output reg [31:0] pc_out         
//);
//    reg [31:0] instruction_memory [0:255]; 
//    reg [31:0] PC;
//    reg [31:0] prefetch_buffer;

//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            PC <= 32'd0;                
//            prefetch_buffer <= 32'd0;    
//        end 
//        else if (debug_mode) begin
//            instr_out <= 32'd0;          
//        end 
//        else begin
//            prefetch_buffer <= instruction_memory[PC[7:0]];
//            PC <= next_pc;             
//            instr_out <= prefetch_buffer;
//        end
//        pc_out <= PC;                    
//    end
//    initial begin
//        $readmemb("instrDATA.mem", instruction_memory); 
//    end

//endmodule
module IF_stage (
    input wire clk,                  
    input wire reset,               
    input wire debug_mode,          
    input wire [31:0] next_pc,      
    input wire [31:0] instruction_in, 
    output reg [31:0] instr_out,    
    output reg [31:0] pc_out        
);
    reg [31:0] PC;
    reg [31:0] prefetch_buffer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 32'd0;               
            instr_out <= 32'd0;   
        end 
        else if (debug_mode) begin
            instr_out <= 32'd0;         
        end 
        else begin
            PC <= next_pc;             
            instr_out <= instruction_in;
        end
        pc_out <= PC;                   
    end
endmodule
