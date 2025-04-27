`timescale 1ns / 1ps


module control(Inst, Branch, MemRead, MemtoReg, ALUop, MemWrite, ALUsrc, RegWrite, jump);
    input [6:0] Inst;
    output reg Branch, MemRead, MemWrite, ALUsrc, RegWrite;
    output reg [1:0] MemtoReg, ALUop,jump;
    
always@(*) begin
case (Inst)
//R-type add/sub/and/or/sll/srl/sra
7'b0110011: begin
ALUop <= 2'b10;
ALUsrc <= 0;
MemWrite <= 0;
MemRead <= 0;
Branch <= 0;
MemtoReg <= 2'b00;
RegWrite <= 1;
jump <= 0;
end
//I-type addi/andi/slli/srli
7'b0010011: begin
ALUop <= 2'b00;
ALUsrc <= 1;
MemWrite <= 0;
MemRead <= 0;
Branch <= 0;
MemtoReg <= 2'b00;
RegWrite <= 1;
jump <= 0;
end
//I-type lw/lb/lbu
7'b0000011: begin
ALUop <= 2'b00;
ALUsrc <= 1;
MemWrite <= 0;
MemRead <= 1;
Branch <= 0;
MemtoReg <= 2'b01;
RegWrite <= 1;
jump <= 0;
end
//S-type sw/sb
7'b0100011: begin
ALUop <= 2'b00;
ALUsrc <= 1;
MemWrite <= 1;
MemRead <= 0;
Branch <= 0;
MemtoReg <= 2'b00;
RegWrite <= 0;
jump <= 0;
end
//B-type beq/bne/bge/blt
7'b1100011: begin
ALUop <= 2'b01;
ALUsrc <= 0;
MemWrite <= 0;
MemRead <= 0;
Branch <= 1;
MemtoReg <= 2'b00;
RegWrite <= 0;
jump <= 0;
end
//jalr
7'b1100111: begin
ALUop <= 2'b11;
ALUsrc <= 1;
MemWrite <= 0;
MemRead <= 0;
Branch <= 1;
MemtoReg <= 2'b10;
RegWrite <= 1;
jump <= 1;
end
//jal
7'b1101111: begin
ALUop <= 2'b11;
ALUsrc <= 1;
MemWrite <= 0;
MemRead <= 0;
Branch <= 1;
MemtoReg <= 2'b10;
RegWrite <= 1;
jump <= 0;
end
default: begin
ALUop <= 2'b00;
ALUsrc <= 0;
MemWrite <= 0;
MemRead <= 0;
Branch <= 0;
MemtoReg <= 0;
RegWrite <= 0;
jump <= 0;
end
endcase
end
    
endmodule
