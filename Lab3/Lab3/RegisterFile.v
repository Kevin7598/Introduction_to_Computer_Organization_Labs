`timescale 1ns / 1ps

module register(read_reg1, read_reg2, write_reg, write_data, read_data1, read_data2, reg_write);
    input [4:0] read_reg1, read_reg2, write_reg;
    input [31:0] write_data;
    input reg_write;
    output reg [31:0] read_data1, read_data2;
    
reg [31:0] regs[31:0];
integer i;
initial begin
for (i = 0; i < 32; i = i + 1)
regs[i] <= 0;
end
always @(*) begin
read_data1 <= regs[read_reg1];
read_data2 <= regs[read_reg2];
end
always @(*) begin
if (reg_write && (write_reg != 0)) regs[write_reg] <= write_data;
end

endmodule
