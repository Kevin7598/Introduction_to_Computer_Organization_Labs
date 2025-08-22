`timescale 1ns / 1ps

module PC_switch(PC_in, PC_out, clk);
    input [31:0] PC_in;
    input clk;
    output reg [31:0] PC_out;
    initial begin
        PC_out = 0;
    end
    
    always@(posedge clk) begin
        PC_out <= PC_in;
    end

endmodule
