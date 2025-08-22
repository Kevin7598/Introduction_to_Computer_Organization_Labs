`timescale 1ns / 1ps

module ALU_Control(Inst, ALUop, control);
    input [3:0] Inst;
    input [1:0] ALUop;
    output reg [3:0] control;
    
    always@(*) begin
        case(ALUop)
            //addi/andi/slli/srli/lw/lb/lbu/sw/sb
            2'b00: begin
            case(Inst[2:0])
            //addi/lw/lb/lbu/sw/sb
            3'b000: control = 4'b0010;
            //andi
            3'b111: control = 4'b0000;
            //slli
            3'b001: control = 4'b1000;
            //srli
            3'b101: control = 4'b1001;
            endcase
            end
            //B-type
            2'b01: begin
                case(Inst[2:0])
                    //beq
                    3'b000: control = 4'b0110;
                    //bne
                    3'b001: control = 4'b0111;
                    //bge
                    3'b101: control = 4'b0100;
                    //blt
                    3'b100: control = 4'b0101;
                    default: control = 0;
                endcase
                end
                //add/sub/and/or/sll/srl/sra
            2'b10: begin
                case (Inst)
                    //add
                    4'b0000: control = 4'b0010;
                    //sub
                    4'b1000: control = 4'b0110;
                    //and
                    4'b0111: control = 4'b0000;
                    //or
                    4'b0110: control = 4'b0001;
                    //sll
                    4'b0001: control = 4'b1000;
                    //srl
                    4'b0101: control = 4'b1001;
                    //sra
                    4'b1101: control = 4'b1010;
                    default: control = 0;
                endcase
            end
            //jal/jalr
            2'b11: control = 4'b1111;
            default: control = 0;
        endcase
    end
    
endmodule