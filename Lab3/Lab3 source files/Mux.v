`timescale 1ns / 1ps

module TWO_MUX(in0, in1, select, out);
    input [31:0] in0, in1;
    input select;
    output reg [31:0] out;
    
    always@(*) begin
        case(select)
            1'b0:out = in0;
            1'b1:out = in1;
            default: out = 0;
        endcase
    end
    
endmodule
