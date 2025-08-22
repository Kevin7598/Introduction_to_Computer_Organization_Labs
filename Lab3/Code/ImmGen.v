`timescale 1ns / 1ps

module ImmGen(ins,imm);
    input [31:0] ins;
    output reg [31:0] imm;
wire [6:0] opcode = ins[6:0];
always @(*) begin
case(opcode)
7'b0110011: imm <= 32'b0;
7'b0010011: imm <= {{20{ins[31]}}, ins[31:20]};
7'b0000011: imm <= {{20{ins[31]}}, ins[31:20]};
7'b0100011: imm <= {{20{ins[31]}}, ins[31:25], ins[11:7]};
7'b1100011: imm <= {{21{ins[31]}}, ins[7], ins[30:25],ins[11:8]};
7'b1100111: imm <= {{20{ins[31]}}, ins[31:20]};
7'b1101111: imm <= {{13{ins[31]}}, ins[19:12], ins[20], ins[30:21]};
endcase
end
endmodule
