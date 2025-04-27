`timescale 1ns / 1ps
module Cache(
    input read_write_cache, 
    input [9:0] address_cache,
    input [31:0] write_data_cache,
    input Done,
    input [31:0] read_data_mem,
    output reg [31:0] read_data_cache,
    output reg hit_miss,
    output reg read_write_mem,
    output reg [9:0] address_mem,
    output reg [31:0] write_data_mem
    );
    reg valid [3:0];
    reg dirty [3:0];
    reg [3:0] tag [3:0];
    reg [31:0] data [15:0];
    reg [9:0] address_mem_base;

    wire [3:0] tag_data;
    wire [1:0] index;
    wire [1:0] word_offset;
    wire [1:0] byte_offset;
    wire load_byte;
    wire [3:0] data_index;
    assign tag_data = (address_cache >> 6);
    assign index = ((address_cache >> 4) & 2'b11);
    assign word_offset = ((address_cache >> 2) & 2'b11);
    assign byte_offset = (address_cache & 2'b11);    
    assign load_byte = ~(byte_offset==0);
    assign data_index = (index << 2) + word_offset;

    integer i;
    initial begin
        for(i=0;i<4;i=i+1) begin
            valid[i]=0;
            dirty[i]=0;
            tag[i]=0;
            data[i]=0;
        end
        address_mem_base=10'b0000000000;
    end

    always@(*) begin
        #2
        if(read_write_cache) begin
            if(tag[index]==tag_data && valid[index]) hit_miss=1;
            else begin
                hit_miss=0;
                if(dirty[index]) begin
                    read_write_mem=1;
                    address_mem_base={tag[index], index, 4'b0000};
                    for(i=0;i<4;i=i+1) begin
                        if(Done || !i) begin
                            address_mem=address_mem_base + (i<<2);
                            write_data_mem=data[(index<<2)+i];
                        end
                        if(i)#0.4;
                        else #0.25;
                    end
                    #10.3;
                end
                else #15.3;
                read_write_mem=0;
                #0.1
                address_mem_base={tag[index], index, 4'b0000};
                address_mem=address_mem_base;
                read_write_mem=0;
                #0.1;
                for(i=0;i<4;i=i+1) begin
                    #0.2;
                    if(Done) begin
                        data[(index<<2)+i]=read_data_mem;
                        address_mem=address_mem_base + ((i+1)<<2);
                    end
                    #0.2;
                end
                tag[index]=tag_data;
                valid[index]=1;
            end
            hit_miss=1;
            dirty[index]=1;
            if(!load_byte) data[data_index]=write_data_cache;
            else data[data_index][((byte_offset<<3)+7)-:8]=write_data_cache;            
        end
        else begin
            if(tag[index]==tag_data && valid[index]) hit_miss=1;
            else begin
                hit_miss=0;
                if(dirty[index]) begin
                    read_write_mem=1;
                    address_mem_base={tag[index], index, 4'b0000};
                    for(i=0;i<4;i=i+1) begin
                        if(Done || !i) begin
                            address_mem=address_mem_base + (i<<2);
                            write_data_mem=data[(index<<2)+i];
                        end
                        if(i)#0.4;
                        else #0.25;
                    end
                    dirty[index]=0;
                    #10.3;
                end
                else #15.3;
                address_mem_base={address_cache[9:4], 4'b0};
                address_mem=address_mem_base;
                read_write_mem=0;
                #0.1;
                for(i=0;i<4;i=i+1) begin
                    #0.2;
                    if(Done) begin
                        data[(index<<2)+i]=read_data_mem;
                        address_mem=address_mem_base + ((i+1)<<2);
                    end
                    #0.2;
                end
                tag[index]=tag_data;
                valid[index]=1;       
            end
            hit_miss=1;
            if(!load_byte) read_data_cache=data[data_index];
            else read_data_cache={24'b0,data[data_index][((byte_offset<<3)+7)-:8]};
        end
    end
    
        
endmodule