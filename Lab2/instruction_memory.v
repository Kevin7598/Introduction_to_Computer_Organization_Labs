`timescale 1ns / 1ps

module instruction_memory(PC, Inst);
    input [31:0] PC;
    output reg [31:0] Inst;
    
    reg [31:0] regs[31:0];
    
    initial
        begin
    regs[0] = 32'hff600293;
    regs[1] = 32'h00528333;
    regs[2] = 32'h4062_83b3;
    regs[3] = 32'h0003_7e33;
    regs[4] = 32'h0053_6eb3;
    regs[5] = 32'h01d0_2023;
    regs[6] = 32'h0050_2223;
    regs[7] = 32'h0002_8463;
    regs[8] = 32'h0003_0eb3;
    regs[9] = 32'h01d3_1463;
    regs[10] = 32'h01c3_1463;
    regs[11] = 32'h0000_03b3;
    regs[12] = 32'h0000_2403;
    regs[13] = 32'h0040_2483;
    regs[14] = 32'h0084_8493;
    regs[15] = 32'h0094_0463;
    regs[16] = 32'h0000_03b3;
    regs[17] = 32'h0073_83b3;

        end
always @(*) begin
Inst <= regs[PC >> 2];
end
endmodule