`timescale 1ns / 1ps
module main_memory(
    input read_write_mem, 
    input [9:0] address_mem,
    input [31:0] write_data_mem,
    output reg [31:0] read_data_mem,
    output reg Done
    );
    reg [31:0] regs[255:0];
    integer i;
    initial begin
        for(i=0;i<256;i=i+1) regs[i]=0;
        Done=0;
    end
    always@(address_mem) begin
        for(i=0;i<4;i=i+1) begin
            if(read_write_mem==1'b1)
                regs[address_mem / 4]=write_data_mem;
                //$display("write in mem");
            if(read_write_mem==1'b0)
                read_data_mem=regs[address_mem / 4];
                //$display("read in mem");       
            #0.2 Done=1;
            #0.2 Done=0;
        end
        //Done=1;
    end
endmodule