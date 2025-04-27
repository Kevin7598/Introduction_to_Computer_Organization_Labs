`timescale 1ns / 1ps

module SingleCycleProcessor(clk);
input clk;
wire [31:0]PC, PC_next, PC_add, Inst, WriteData, ReadData1, ReadData2, ALUresult, ReadData, Imm, ALUin, ImmShift, PC_sum;
wire Branch, MemRead, MemWrite, ALUsrc, MemtoReg, RegWrite, zero, select;
wire [1:0] ALUop;
wire [3:0] control;

PC_switch switch(PC_next, PC, clk);
adder add1(PC, 4, PC_add);
instruction_memory InstMem(PC, Inst);
control Control(Inst[6:0], Branch, MemRead, MemtoReg, ALUop, MemWrite, ALUsrc, RegWrite);
register RF1(Inst[19:15], Inst[24:20], Inst[11:7], WriteData, ReadData1, ReadData2, RegWrite, clk);
ImmGen immgen(Inst, Imm);
ALU_Control ALUC({Inst[30], Inst[14:12]}, ALUop, control);
MUX Mux1(ReadData2, Imm, ALUsrc, ALUin);
ALU alu(ReadData1, ALUin, control, zero, ALUresult);
data_memory DataMem1(MemRead, MemWrite, ALUresult, ReadData2, ReadData, clk);
MUX Mux2(ALUresult, ReadData, MemtoReg, WriteData);
shift_left Shifter1(Imm, ImmShift);
adder add2(PC, ImmShift, PC_sum);
assign select= Branch & zero;
MUX Mux3(PC_add, PC_sum, select, PC_next);

endmodule