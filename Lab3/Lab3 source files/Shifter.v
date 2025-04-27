`timescale 1ns / 1ps

module shift_left(in, out);
    input [31:0] in;
    output [31:0] out;
    
    assign out = in << 1;
    
endmodule
