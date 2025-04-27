`timescale 1ns / 1ps
// both current and next PC need to be preserved because one is used for addition with immediate
// the other is used for add 4
module IF_ID(clk, current_PC, next_PC, Instruction, cPC, nPC, Inst);
input clk;
input [31:0] current_PC, next_PC, Instruction;
output reg [31:0] cPC, nPC, Inst;
initial begin
cPC <= 0;
nPC <= 0;
Inst <= 0;
end
always @(posedge clk) begin
cPC <= current_PC;
nPC <= next_PC;
Inst <= Instruction;
end
endmodule
