`timescale 1ns / 1ps

module ALU_Control(Inst, ALUop, control);
    input [3:0] Inst;
    input [1:0] ALUop;
    output reg [3:0] control;
    
    always@(*) begin
        case(ALUop)
            2'b00: control = 4'b0010;
            2'b01: begin
                case(Inst[2:0])
                    3'b000: control = 4'b0110;
                    3'b001: control = 4'b0111;
                    default: control = 0;
                endcase
                end
            2'b10: begin
                case (Inst)
                    4'b0000: control = 4'b0010;
                    4'b1000: control = 4'b0110;
                    4'b0111: control = 4'b0000;
                    4'b0110: control = 4'b0001;
                    default: control = 0;
                endcase
            end
            default: control=0;
        endcase
    end
    
endmodule