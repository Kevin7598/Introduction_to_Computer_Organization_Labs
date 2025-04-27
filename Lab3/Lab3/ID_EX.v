`timescale 1ns / 1ps

module ID_EX(clk, RegWrite, MemtoReg, MemRead, MemWrite, Branch, ALUSrc, ALUOp, current_PC, next_PC, 
Readdata1, Readdata2, Immediate, function_code, rd, jump,
RegWrite_out, MemtoReg_out, MemRead_out, MemWrite_out, Branch_out, ALUSrc_out, ALUOp_out, current_PC_out, 
next_PC_out, Readdata1_out, Readdata2_out, Immediate_out, function_code_out, rd_out, jump_out);
input clk, RegWrite, MemRead, MemWrite, Branch, ALUSrc, jump;
input [1:0] MemtoReg, ALUOp;
input [31:0] current_PC, next_PC, Readdata1, Readdata2, Immediate;
input [4:0] rd;
input [3:0] function_code;
output reg RegWrite_out, MemRead_out, MemWrite_out, Branch_out, ALUSrc_out, jump_out;
output reg [1:0] MemtoReg_out, ALUOp_out;
output reg [31:0] current_PC_out, next_PC_out, Readdata1_out, Readdata2_out, Immediate_out;
output reg [4:0] rd_out;
output reg [3:0] function_code_out;
initial begin
RegWrite_out <= 0;
MemRead_out <= 0;
MemWrite_out <= 0;
Branch_out <= 0;
ALUSrc_out <= 0;
MemtoReg_out <= 0;
ALUOp_out <= 0;
current_PC_out <= 0;
next_PC_out <= 0;
Readdata1_out <= 0;
Readdata2_out <= 0;
Immediate_out <= 0;
rd_out <= 0;
function_code_out <= 0;
jump_out <= 0;
end
always @(posedge clk) begin
RegWrite_out <= RegWrite;
MemRead_out <= MemRead;
MemWrite_out <= MemWrite;
Branch_out <= Branch;
ALUSrc_out <= ALUSrc;
MemtoReg_out <= MemtoReg;
ALUOp_out <= ALUOp;
current_PC_out <= current_PC;
next_PC_out <= next_PC;
Readdata1_out <= Readdata1;
Readdata2_out <= Readdata2;
Immediate_out <= Immediate;
rd_out <= rd;
function_code_out <= function_code;
jump_out <= jump;
end
endmodule