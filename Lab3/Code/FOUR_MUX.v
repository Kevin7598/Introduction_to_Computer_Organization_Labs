`timescale 1ns / 1ps
//used for MemtoReg to select what is used for the PC of next cycle(ALUresult ot Memory read or added by 4)
module FOUR_MUX(in0, in1, in2, in3, sel, out);
input [31:0] in0, in1, in2, in3;
input [1:0] sel;
output reg [31:0] out;
always @ (*) begin
case (sel)
2'b00: out = in0;
2'b01: out = in1;
2'b10: out = in2;
2'b11: out = in3;
default: out = 0;
endcase
end
endmodule