`timescale 1ns / 1ps

module data_memory(MemRead, MemWrite, inst, addr, WriteData, ReadData);
    input MemRead, MemWrite;
    input [2:0] inst;
    input [31:0] addr;
    input [31:0] WriteData;
    output reg [31:0] ReadData;
    
reg [7:0] regs [127:0];
integer i;
initial begin
for (i = 0; i < 128; i = i + 1) regs[i] = 0;
end
always @(*) begin
if (MemRead) begin
case (inst)
//lw
3'b010: ReadData <= {regs[addr + 3], regs[addr + 2], regs[addr + 1], regs[addr]};
//lb
3'b000: ReadData <= {{24{regs[addr][7]}}, regs[addr]};
//lbu
3'b100: ReadData <= {{24'b0}, regs[addr]};
default: ReadData <= 0;
endcase
end else begin
ReadData <= 0;
end
end
always @(*) begin
if (MemWrite) begin
case (inst)
//sw
3'b010: begin
regs[addr] <= WriteData[7:0];
regs[addr + 1] <= WriteData[15:8];
regs[addr + 2] <= WriteData[23:16];
regs[addr + 3] <= WriteData[31:24];
end
//sb
3'b000: regs[addr] <= WriteData[7:0];
default: regs[addr] <= 0;
endcase
end
end
    
endmodule
