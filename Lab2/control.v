`timescale 1ns / 1ps

module control(
input [6:0] instruction,
output reg ALUSrc, MemWrite, MemRead, Branch, MemtoReg, RegWrite,
output reg [1:0] ALUOp
    );
    always@(*) begin
    case (instruction)
    7'b0110011: begin
    ALUOp <= 2'b10;
    ALUSrc <= 0;
    MemWrite <= 0;
    MemRead <= 0;
    Branch <= 0;
    MemtoReg <= 0;
    RegWrite <= 1;
    end
    7'b0010011: begin
    ALUOp <= 2'b11;
    ALUSrc <= 1;
    MemWrite <= 0;
    MemRead <= 0;
    Branch <= 0;
    MemtoReg <= 0;
    RegWrite <= 1;
    end
    7'b0000011: begin
    ALUOp <= 2'b00;
    ALUSrc <= 1;
    MemWrite <= 0;
    MemRead <= 1;
    Branch <= 0;
    MemtoReg <= 1;
    RegWrite <= 1;
    end
    7'b0100011: begin
    ALUOp <= 2'b00;
    ALUSrc <= 1;
    MemWrite <= 1;
    MemRead <= 0;
    Branch <= 0;
    MemtoReg <= 0;
    RegWrite <= 0;
    end
    7'b1100011: begin
    ALUOp <= 2'b01;
    ALUSrc <= 0;
    MemWrite <= 0;
    MemRead <= 0;
    Branch <= 1;
    MemtoReg <= 0;
    RegWrite <= 0;
    end
    default: begin
    ALUOp <= 2'b00;
    ALUSrc <= 0;
    MemWrite <= 0;
    MemRead <= 0;
    Branch <= 0;
    MemtoReg <= 0;
    RegWrite <= 0;
    end
    endcase
    end
endmodule
