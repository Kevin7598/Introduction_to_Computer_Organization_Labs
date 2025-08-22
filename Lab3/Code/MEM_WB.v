`timescale 1ns / 1ps

module MEM_WB(clk, RegWrite, MemtoReg, next_PC, Readdata, ALU_result, rd, Branch_target,
RegWrite_out, MemtoReg_out, next_PC_out, Readdata_out, ALU_result_out, rd_out, Branch_target_out);
input clk, RegWrite;
input [1:0] MemtoReg;
input [4:0] rd;
input [31:0] next_PC, Readdata, ALU_result, Branch_target;
output reg RegWrite_out;
output reg [1:0] MemtoReg_out;
output reg [4:0] rd_out;
output reg [31:0] next_PC_out, Readdata_out, ALU_result_out, Branch_target_out;
initial begin
RegWrite_out <= 0;
MemtoReg_out <= 0;
rd_out <= 0;
next_PC_out <= 0;
Readdata_out <= 0;
ALU_result_out <= 0;
Branch_target_out <= 0;
end
always @(posedge clk) begin
RegWrite_out <= RegWrite;
MemtoReg_out <= MemtoReg;
rd_out <= rd;
next_PC_out <= next_PC;
Readdata_out <= Readdata;
ALU_result_out <= ALU_result;
Branch_target_out <= Branch_target;
end
endmodule
