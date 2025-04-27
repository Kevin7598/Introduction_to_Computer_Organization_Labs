`timescale 1ns / 1ps

module ALU(in1, in2, control, zero, result);
    input [31:0] in1, in2;
    input [3:0] control;
    output reg zero;
    output reg [31:0] result;
    
    always@(*) begin
        case(control)
            //and/andi
            4'b0000: result = in1 & in2;
            //or
            4'b0001: result = in1 | in2;
            //add/addi/lw/lb/lbu/sw/sb
            4'b0010: result = in1 + in2;
            //sub
            4'b0011: result = in1 - in2;
            //bge
            4'b0100: result = in1 - in2;
            //blt
            4'b0101: result = in1 - in2;
            //beq
            4'b0110: result = in1 - in2;
            //bne
            4'b0111: result = in1 - in2;
            //slli/sll
            4'b1000: result = in1 << in2;
            //srli/srl
            4'b1001: result = in1 >> in2;
            //sra
            4'b1010: result = in1 >>> in2;
            //jal/jalr
            4'b1111: result = in1 + in2;
            default: result = 0;
        endcase
        if(result != 0 && control == 4'b0111) zero = 1;
        else if(result == 0 && control == 4'b0110) zero = 1;
        else if(control == 4'b1111) zero = 1;
        else if(result >= 0 && control == 4'b0100) zero = 1;
        else if(result < 0 && control == 4'b0101) zero = 1;
        else zero = 0;
    end
endmodule
