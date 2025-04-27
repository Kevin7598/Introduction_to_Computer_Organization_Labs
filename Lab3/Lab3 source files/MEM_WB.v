`timescale 1ns / 1ps

module MEM_WB(clk, RegWrite, MemtoReg, next_PC, Readdata, ALU_result, rd,
RegWrite_out, MemtoReg_out, next_PC_out, Readdata_out, ALU_result_out, rd_out);
input clk, RegWrite;
input [1:0] MemtoReg;
input [4:0] rd;
input [31:0] next_PC, Readdata, ALU_result;
output reg RegWrite_out;
output reg [1:0] MemtoReg_out;
output reg [4:0] rd_out;
output reg [31:0] next_PC_out, Readdata_out, ALU_result_out;
initial begin
RegWrite_out <= RegWrite;
MemtoReg_out <= MemtoReg;
rd_out <= rd;
next_PC_out <= next_PC;
Readdata_out <= Readdata;
ALU_result_out <= ALU_result;
end
always @(posedge clk) begin

end
endmodule
