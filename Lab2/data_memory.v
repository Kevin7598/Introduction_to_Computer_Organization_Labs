`timescale 1ns / 1ps

module data_memory(MemRead, MemWrite, addr, WriteData, ReadData, clk);
    input MemRead, MemWrite, clk;
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
ReadData <= {regs[addr + 3], regs[addr + 2], regs[addr + 1], regs[addr]};
end
else begin
ReadData <= 0;
end
end
always @(posedge clk) begin
if (MemWrite) begin
regs[addr] <= WriteData[7:0];
regs[addr + 1] <= WriteData[15:8];
regs[addr + 2] <= WriteData[23:16];
regs[addr + 3] <= WriteData[31:24];
end
end
    
endmodule