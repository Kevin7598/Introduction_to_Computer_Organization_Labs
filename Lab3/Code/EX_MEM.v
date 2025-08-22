`timescale 1ns / 1ps

module EX_MEM(clk, RegWrite, MemtoReg, MemRead, MemWrite, Branch, Zero, PC_sum, next_PC, 
ALU_result, Readdata2, funct3, rd,
RegWrite_out, MemtoReg_out, MemRead_out, MemWrite_out, Branch_out, Zero_out, PC_sum_out, next_PC_out,
ALU_result_out, Readdata2_out, funct3_out, rd_out);
input clk, MemRead, MemWrite, Branch, Zero, RegWrite;
input [1:0] MemtoReg;
input [2:0] funct3;
input [4:0] rd;
input [31:0] next_PC, PC_sum, ALU_result, Readdata2;
output reg MemRead_out, MemWrite_out, Branch_out, Zero_out, RegWrite_out;
output reg [1:0] MemtoReg_out;
output reg [2:0] funct3_out;
output reg [4:0] rd_out;
output reg [31:0] next_PC_out, PC_sum_out, ALU_result_out, Readdata2_out;
initial begin
MemRead_out <= 0;
MemWrite_out <= 0;
Branch_out <= 0;
Zero_out <= 0;
RegWrite_out <= 0;
MemtoReg_out <= 0;
funct3_out <= 0;
rd_out <= 0;
next_PC_out <= 0;
PC_sum_out <= 0;
ALU_result_out <= 0;
Readdata2_out <= 0;
end
always @(posedge clk) begin
MemRead_out <= MemRead;
MemWrite_out <= MemWrite;
Branch_out <= Branch;
Zero_out <= Zero;
RegWrite_out <= RegWrite;
MemtoReg_out <= MemtoReg;
funct3_out <= funct3;
rd_out <= rd;
next_PC_out <= next_PC;
PC_sum_out <= PC_sum;
ALU_result_out <= ALU_result;
Readdata2_out <= Readdata2;
end
endmodule