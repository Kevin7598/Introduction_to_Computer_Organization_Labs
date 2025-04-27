`timescale 1ns / 1ps

module ALU(in1, in2, control, zero, result);
    input [31:0] in1, in2;
    input [3:0] control;
    output reg zero;
    output reg [31:0] result;
    
    always@(*) begin
        case(control)
            4'b0000: result = in1 & in2;
            4'b0001: result = in1 | in2;
            4'b0010: result = in1 + in2;
            4'b0110: result = in1 - in2;
            4'b0111: result = in1 - in2;
            default: result = 0;
        endcase
        if(result != 0 && control == 4'b0111) zero = 1;
        else if(result == 0 && control != 4'b0111) zero = 1;
        else zero = 0;
    end
endmodule
