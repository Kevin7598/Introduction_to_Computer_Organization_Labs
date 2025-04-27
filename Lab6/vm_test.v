`timescale 1ns / 1ps
module vm_test;
    reg          clock;
    
    // interface between cache and CPU
    wire [9:0]   physical_address;
    wire [13:0]  virtual_address;
    wire [31:0]  write_data_cache, physical_page_tag;
    // interface between cache and main memory
    wire [31:0]  read_data_cache, write_data_mem;
    wire [127:0] read_data_mem;
    wire [9:0]   address_mem;
    wire [5:0]   virtual_page_tag;
    //wire [5:0]   request_page_tag;
    wire hit_miss;
    wire read_write, read_write_cache, read_write_mem;
    
    processor                     CPU(
        .hit_miss(hit_miss),
        .clock(clock),
        .read_write(read_write),
        .address(virtual_address),
        .write_data(write_data_cache)
    );
    /*
        You can only modify the following parts:
        CACHE, TLB, MAIN_MEMORY, and PAGE_TABLE
        to adapt modules you designed to this testbench
    */
    associative_back_cache        cache(
        .read_write_cache(read_write_cache),
        .address_cache(physical_address),
        .write_data_cache(write_data_cache),
        .read_data_mem(read_data_mem),
        //.done(done),
        .read_data_cache(read_data_cache),
        .hit_miss(hit_miss),
        .read_write_mem(read_write_mem),
        .address_mem(address_mem),
        .write_data_mem(write_data_mem)
    );
    translation_look_aside_buffer TLB(
        .virtual_address(virtual_address),
        .input_read_write(read_write),
        .physical_page_tag(physical_page_tag),
        //.dirty_fetched(dirty_fetched),
        //.reference_fetched(reference_fetched),
        .physical_address(physical_address),
        .output_read_write(read_write_cache),
        //.dirty_write_back(dirty_write_back),
        //.reference_write_back(reference_write_back),
        //.write_back(write_back),
        .virtual_page_tag(virtual_page_tag)
        //.page_fault(page_fault),
        //.request_page_tag(request_page_tag)
    );
    main_mem                      memory(
        .read_write_mem(read_write_mem),
        .address_mem(address_mem),
        .write_data_mem(write_data_mem),
        .read_data_mem(read_data_mem)
        //.done(done)
    );
    page_table                    PT(
        //.dirty_write_back(dirty_write_back),
        //.reference_write_back(reference_write_back),
        //.write_back(write_back),
        .virtual_page_tag(virtual_page_tag),
        .physical_page_tag(physical_page_tag),
        //.dirty_fetched(dirty_fetched),
        //.reference_fetched(reference_fetched),
        .page_fault(page_fault)
        //.request_page_tag(request_page_tag)
    );

    /*
        Do not modify the following code!!!
    */
    always #5 clock = ~clock;

    always @(posedge clock) begin
        $display("**************************************");
        $display("Request %d: ", CPU.request_num);
        $display("page fault: %b", PT.page_fault);
        $display("data read posedge: %H", read_data_cache);
        $display("contents in TLB: ");
        $display("block 00: tag: %2d, valid: %b, dirty: %b, reference: %b, VPN: %1d", TLB.tag[0], TLB.valid[0], TLB.dirty[0], TLB.reference[0], TLB.block[0]);
        $display("block 01: tag: %2d, valid: %b, dirty: %b, reference: %b, VPN: %1d", TLB.tag[1], TLB.valid[1], TLB.dirty[1], TLB.reference[1], TLB.block[1]);
        $display("block 10: tag: %2d, valid: %b, dirty: %b, reference: %b, VPN: %1d", TLB.tag[2], TLB.valid[2], TLB.dirty[2], TLB.reference[2], TLB.block[2]);
        $display("block 11: tag: %2d, valid: %b, dirty: %b, reference: %b, VPN: %1d", TLB.tag[3], TLB.valid[3], TLB.dirty[3], TLB.reference[3], TLB.block[3]);
        $display("contents in cache: ");
        $display("block 00: tag: %b, valid: %b, dirty: %b, word0: %H, word1: %H, word2: %H, word3: %H", cache.tag[0], cache.valid[0], cache.dirty[0], cache.block[0][127:96], cache.block[0][95:64], cache.block[0][63:32], cache.block[0][31:0]);
        $display("block 01: tag: %b, valid: %b, dirty: %b, word0: %H, word1: %H, word2: %H, word3: %H", cache.tag[1], cache.valid[1], cache.dirty[1], cache.block[1][127:96], cache.block[1][95:64], cache.block[1][63:32], cache.block[1][31:0]);
        $display("block 10: tag: %b, valid: %b, dirty: %b, word0: %H, word1: %H, word2: %H, word3: %H", cache.tag[2], cache.valid[2], cache.dirty[2], cache.block[2][127:96], cache.block[2][95:64], cache.block[2][63:32], cache.block[2][31:0]);
        $display("block 11: tag: %b, valid: %b, dirty: %b, word0: %H, word1: %H, word2: %H, word3: %H", cache.tag[3], cache.valid[3], cache.dirty[3], cache.block[3][127:96], cache.block[3][95:64], cache.block[3][63:32], cache.block[3][31:0]);
    end
    
    initial begin
        clock = 0;
        #160 $stop;
    end
endmodule
/*
    Do not modify the following code!!!
*/
module processor (
    input  hit_miss,
    input  clock,
    output read_write,
    output [13:0] address,
    output [31:0] write_data
);
    parameter  request_total = 14; // change this number to how many requests you want in your testbench
    reg [4:0]  request_num;
    reg        read_write_test[request_total-1:0];
    reg [13:0]  address_test[request_total-1:0];
    reg [31:0] write_data_test[request_total-1:0]; 
    initial begin
        #10 request_num = 0;
        read_write_test[0]  = 1; address_test[0]  = 14'b000100_100_0_1000; write_data_test[0]  = 1;       // sw, virtual page  4, TLB miss, mapped to physical page 2, physical tag 10100, cache miss in set 0 block 0,
        read_write_test[1]  = 1; address_test[1]  = 14'b000000_100_1_1100; write_data_test[1]  = 12'hdac; // sw, virtual page  0, TLB miss, mapped to physical page 1, physical tag 01100, cache miss in set 1 block 0,
        read_write_test[2]  = 1; address_test[2]  = 14'b000001_100_1_1000; write_data_test[2]  = 12'hfac; // sw, virtual page  1, TLB miss, mapped to physical page 3, physical tag 11100, cache miss in set 1 block 1,
        read_write_test[3]  = 1; address_test[3]  = 14'b000000_100_1_0101; write_data_test[3]  = 12'hfac; // sb, virtual page  0, TLB hit,  mapped to physical page 1, physical tag 01100, cache hit  in set 1 block 0,
        read_write_test[4]  = 0; address_test[4]  = 14'b000111_100_1_0101; write_data_test[4]  = 0;       // lb, virtual page  7, TLB miss, mapped to physical page 1, physical tag 01100, cache hit  in set 1 block 0,
        read_write_test[5]  = 0; address_test[5]  = 14'b001000_110_1_0101; write_data_test[5]  = 0;       // lb, virtual page  8, TLB miss, mapped to physical page 1, virtual page 4 replaced, write back entry with virtual tag 4,
                                                                                                          //                                                           physical tag 01110, cache miss in set 1, set 1 block 1 replaced and write back
        read_write_test[6]  = 0; address_test[6]  = 14'b000001_110_1_0100; write_data_test[6]  = 0;       // lw, virtual page  1, TLB hit,  mapped to physical page 3, physical tag 11110, cache miss in set 1, set 1 block 0 replaced and write back
        read_write_test[7]  = 1; address_test[7]  = 14'b000111_100_1_0111; write_data_test[7]  = 12'h148; // sb, virtual page  7, TLB hit,  mapped to physical page 1, physical tag 01100, cache miss in set 1, set 1 block 1 replaced
        read_write_test[8]  = 0; address_test[8]  = 14'b000000_100_1_1000; write_data_test[8]  = 0;       // lw, virtual page  0, TLB hit,  mapped to physical page 1, physical tag 01100, cache hit  in set 1 block 1,
        read_write_test[9]  = 0; address_test[9]  = 14'b001010_100_1_0100; write_data_test[9]  = 0;       // lw, virtual page 10, TLB miss, mapped to physical page 1, virtual page 8 replaced, write back entry with virtual tag 8,
                                                                                                          //                                                           physical tag 01100, cache hit  in set 1 block 1,
        read_write_test[10] = 0; address_test[10] = 14'b000000_110_1_0100; write_data_test[10] = 0;       // lw, virtual page  0, TLB hit,  mapped to physical page 1, physical tag 01110, cache miss in set 1, set 1 block 1 replaced
        read_write_test[11] = 0; address_test[11] = 14'b000100_100_0_1000; write_data_test[11] = 0;       // lw, virtual page  4, TLB miss, mapped to physical page 2, virtual page 1 replaced, write back entry with virtual tag 1,
                                                                                                          //                                                           physical tag 10100, cache hit  in set 1 block 0
        read_write_test[12] = 0; address_test[12] = 14'b000010_110_1_0100; write_data_test[12] = 0;       // lw, virtual page  2, TLB miss, page fault

        /* extra test for fun; it is acceptable that you have different result after the request below */
        //read_write_test[13] = 0; address_test[13] = 14'b000111_100_1_1100; write_data_test[13] = 0;       // lw, virtual page  10, TLB hit, mapped to physical page 1, physcial tag 01100, cache hit in set 1 block 1
        // Notes: actually in this lab you are not required to handle page fault, but ideally you may just skip the request with page fault and deal with the next request normally (it only applies to this lab!!!)
        // In other words, nothing should be changed when there is a page fault in this lab, including TLB, page table, cache and memory.
        // But such requirement is cancelled considering your workload :)
    end
    always @(posedge clock) begin
        if (hit_miss == 1) request_num = request_num + 1;
        else request_num = request_num;
    end
    assign address      = address_test[request_num];
    assign read_write   = read_write_test[request_num];
    assign write_data   = write_data_test[request_num]; 
endmodule

module associative_back_cache(
    input read_write_cache,
    input [9:0]address_cache,
    input [31:0]write_data_cache,
    input [127:0]read_data_mem,
    //output done,
    output [31:0]read_data_cache,
    output hit_miss,
    output read_write_mem,
    output [9:0]address_mem,
    output [31:0]write_data_mem
);

    reg [127:0]block[3:0];
    reg dirty[3:0];
    reg valid[3:0];
    reg [4:0]tag[3:0];
    reg ref[3:0];
    reg [31:0]read_data_cache;
    
    reg [1:0]wordoff;
    reg [1:0]byteoff;
    reg blockoff;
    reg [4:0]tagoff;
    reg [31:0]write_data_mem;
    
    //assign write_data_mem = write_data_cache;
    assign read_write_mem = read_write_cache;
    assign hit_miss = 1'b1;
    assign address_mem = address_cache;
    
    initial
    begin
        block[0] = 128'b0;
        block[1] = 128'b0;
        block[2] = 128'b0;
        block[3] = 128'b0;
        dirty[0] = 1'b0;
        dirty[1] = 1'b0;
        dirty[2] = 1'b0;
        dirty[3] = 1'b0;
        valid[0] = 1'b0;
        valid[1] = 1'b0;
        valid[2] = 1'b0;
        valid[3] = 1'b0;
        tag[0] = 5'b0;
        tag[1] = 5'b0;
        tag[2] = 5'b0;
        tag[3] = 5'b0;
        ref[0] = 1'b0;
        ref[1] = 1'b0;
        ref[2] = 1'b0;
        ref[3] = 1'b0;
    end
    

    integer i, j;
    always @(address_cache, read_data_mem, read_write_cache, write_data_cache)
    begin
        byteoff = address_cache[1:0];
        wordoff = address_cache[3:2];
        blockoff = address_cache[4];
        tagoff = address_cache[9:5];
        if(blockoff == 0)
        begin
            if(tag[0] == tagoff && valid[0] == 1)
            begin
                block[0] <= read_data_mem;
                ref[0] <= 1;
                ref[1] <= 0;
                if(read_write_cache == 1)     //write
                begin
                    dirty[0] <= 1;
                    if(byteoff == 0)
                    begin
                        write_data_mem = write_data_cache;
                    end
                    else
                    begin
                        for(i = 0; i < 32; i = i + 1)
                        begin
                            write_data_mem[i] = block[0][32*wordoff+i];
                        end
                        for(j = 0; j < 8; j = j + 1)
                        begin
                            write_data_mem[8*byteoff+j] = write_data_cache[j];
                        end
                    end
                end
                if(read_write_cache == 0)     //read
                begin
                    for(i = 0; i < 32; i = i + 1)
                    begin
                        if(byteoff == 0)
                        begin
                            read_data_cache[i] = block[0][32*wordoff+i];
                        end
                        if(byteoff != 0)
                        begin
                            read_data_cache[31:8] = 24'b0;
                            for(j = 0; j < 8; j = j + 1)
                            begin
                                read_data_cache[j] = block[0][32*wordoff+8*byteoff+j];
                            end
                        end
                    end
                end
            end
            else if(tag[1] == tagoff && valid[1] == 1)
            begin
                block[1] <= read_data_mem;
                ref[1] <= 1;
                ref[0] <= 0;
                if(read_write_cache == 1)     //write
                begin
                    dirty[1] <= 1;
                    if(byteoff == 0)
                    begin
                        write_data_mem = write_data_cache;
                    end
                    else
                    begin
                        for(i = 0; i < 32; i = i + 1)
                        begin
                            write_data_mem[i] = block[1][32*wordoff+i];
                        end
                        for(j = 0; j < 8; j = j + 1)
                        begin
                            write_data_mem[8*byteoff+j] = write_data_cache[j];
                        end
                    end
                end
                valid[1] <= 1;
                if(read_write_cache == 0)     //read
                begin
                    for(i = 0; i < 32; i = i + 1)
                    begin
                        if(byteoff == 0)
                        begin
                            read_data_cache[i] = block[1][32*wordoff+i];
                        end
                        if(byteoff != 0)
                        begin
                            read_data_cache[31:8] = 24'b0;
                            for(j = 0; j < 8; j = j + 1)
                            begin
                                read_data_cache[j] = block[1][32*wordoff+8*byteoff+j];
                            end
                        end
                    end
                end
            end
            else      //miss
            begin
                if(valid[0] == 0 || ref[0] == 0)       //第一位空着or不常用
                begin
                    valid[0] <= 1;
                    ref[0] <= 1;
                    ref[1] <= 0;
                    block[0] = read_data_mem;
                    tag[0] <= tagoff;
                    if(read_write_cache == 1)     //write
                    begin
                        dirty[0] <= 1;
                        if(byteoff == 0)
                        begin
                            write_data_mem = write_data_cache;
                        end
                        else
                        begin
                            for(i = 0; i < 32; i = i + 1)
                            begin
                                write_data_mem[i] = block[0][32*wordoff+i];
                            end
                            for(j = 0; j < 8; j = j + 1)
                            begin
                                write_data_mem[8*byteoff+j] = write_data_cache[j];
                            end
                        end
                    end
                    if(read_write_cache == 0)     //read
                    begin
                        for(i = 0; i < 32; i = i + 1)
                        begin
                            if(byteoff == 0)
                            begin
                                read_data_cache[i] = block[0][32*wordoff+i];
                            end
                            if(byteoff != 0)
                            begin
                                read_data_cache[31:8] = 24'b0;
                                for(j = 0; j < 8; j = j + 1)
                                begin
                                    read_data_cache[j] = block[0][32*wordoff+8*byteoff+j];
                                end
                            end
                        end
                    end
                end
                else if(valid[1] == 0 || ref[1] == 0)       //第二位空着or不常用
                begin
                    ref[1] <= 1;
                    ref[0] <= 0;
                    block[1] = read_data_mem;
                    tag[1] <= tagoff;
                    if(read_write_cache == 1)     //write
                    begin
                        dirty[1] <= 1;
                        if(byteoff == 0)
                        begin
                            write_data_mem = write_data_cache;
                        end
                        else
                        begin
                            for(i = 0; i < 32; i = i + 1)
                            begin
                                write_data_mem[i] = block[1][32*wordoff+i];
                            end
                            for(j = 0; j < 8; j = j + 1)
                            begin
                                write_data_mem[8*byteoff+j] = write_data_cache[j];
                            end
                        end
                    end
                    valid[1] <= 1;
                    if(read_write_cache == 0)     //read
                    begin
                        for(i = 0; i < 32; i = i + 1)
                        begin
                            if(byteoff == 0)
                            begin
                                read_data_cache[i] = block[1][32*wordoff+i];
                            end
                            if(byteoff != 0)
                            begin
                                read_data_cache[31:8] = 24'b0;
                                for(j = 0; j < 8; j = j + 1)
                                begin
                                    read_data_cache[j] = block[1][32*wordoff+8*byteoff+j];
                                end
                            end
                        end
                    end
                end
            end
        end
        if(blockoff == 1)    //blockoff == 1
        begin
            if(tag[2] == tagoff && valid[2] == 1)
            begin
                block[2] <= read_data_mem;
                ref[2] <= 1;
                ref[3] <= 0;
                if(read_write_cache == 1)     //write
                begin
                    dirty[2] <= 1;
                    if(byteoff == 0)
                    begin
                        write_data_mem = write_data_cache;
                    end
                    if(byteoff == 1)
                    begin
                        for(i = 0; i < 32; i = i + 1)
                        begin
                            write_data_mem[i] = block[2][32*wordoff+i];
                        end
                        for(j = 0; j < 8; j = j + 1)
                        begin
                            write_data_mem[8*byteoff+j] = write_data_cache[j];
                        end
                    end
                end
                if(read_write_cache == 0)     //read
                begin
                    for(i = 0; i < 32; i = i + 1)
                    begin
                        if(byteoff == 0)
                        begin
                            read_data_cache[i] = block[2][32*wordoff+i];
                        end
                        if(byteoff != 0)
                        begin
                            read_data_cache[31:8] = 24'b0;
                            for(j = 0; j < 8; j = j + 1)
                            begin
                                read_data_cache[j] = block[2][32*wordoff+8*byteoff+j];
                            end
                        end
                    end
                end
            end
            else if(tag[3] == tagoff && valid[3] == 1)
            begin
                block[3] <= read_data_mem;
                ref[3] <= 1;
                ref[2] <= 0; 
                if(read_write_cache == 1)     //write
                begin
                    dirty[3] <= 1;
                    if(byteoff == 0)
                    begin
                        write_data_mem = write_data_cache;
                    end
                    else
                    begin
                        for(i = 0; i < 32; i = i + 1)
                        begin
                            write_data_mem[i] = block[3][32*wordoff+i];
                        end
                        for(j = 0; j < 8; j = j + 1)
                        begin
                            write_data_mem[8*byteoff+j] = write_data_cache[j];
                        end
                    end
                end
                if(read_write_cache == 0)     //read
                begin
                    for(i = 0; i < 32; i = i + 1)
                    begin
                        if(byteoff == 0)
                        begin
                            read_data_cache[i] = block[3][32*wordoff+i];
                        end
                        if(byteoff != 0)
                        begin
                            read_data_cache[31:8] = 24'b0;
                            for(j = 0; j < 8; j = j + 1)
                            begin
                                read_data_cache[j] = block[3][32*wordoff+8*byteoff+j];
                            end
                        end
                    end
                end
            end
            else
            begin
                if(valid[2] == 0 || ref[2] == 0)     //第三位空着or不常用
                begin
                    valid[2] <= 1;
                    ref[2] <= 1;
                    ref[3] <= 0;
                    block[2] = read_data_mem;
                    tag[2] <= tagoff;
                    if(read_write_cache == 1)     //write
                    begin
                        dirty[2] <= 1;
                        if(byteoff == 0)
                        begin
                            write_data_mem = write_data_cache;
                        end
                        if(byteoff == 1)
                        begin
                            for(i = 0; i < 32; i = i + 1)
                            begin
                                write_data_mem[i] = block[2][32*wordoff+i];
                            end
                            for(j = 0; j < 8; j = j + 1)
                            begin
                                write_data_mem[8*byteoff+j] = write_data_cache[j];
                            end
                        end
                    end
                    if(read_write_cache == 0)     //read
                    begin
                        for(i = 0; i < 32; i = i + 1)
                        begin
                            if(byteoff == 0)
                            begin
                                read_data_cache[i] = block[2][32*wordoff+i];
                            end
                            if(byteoff != 0)
                            begin
                                read_data_cache[31:8] = 24'b0;
                                for(j = 0; j < 8; j = j + 1)
                                begin
                                    read_data_cache[j] = block[2][32*wordoff+8*byteoff+j];
                                end
                            end
                        end
                    end
                end
                else if(valid[3] == 0 || ref[3] == 0)       //第四位空着or不常用
                begin
                    valid[3] <= 1;
                    ref[3] <= 1;
                    ref[2] <= 0;
                    block[3] = read_data_mem;
                    tag[3] <= tagoff;
                    if(read_write_cache == 1)     //write
                    begin
                        dirty[3] <= 1;
                        dirty[0] <= 1;
                        if(byteoff == 0)
                        begin
                            write_data_mem = write_data_cache;
                        end
                        else
                        begin
                            for(i = 0; i < 32; i = i + 1)
                            begin
                                write_data_mem[i] = block[3][32*wordoff+i];
                            end
                            for(j = 0; j < 8; j = j + 1)
                            begin
                                write_data_mem[8*byteoff+j] = write_data_cache[j];
                            end
                        end
                    end
                    if(read_write_cache == 0)     //read
                    begin
                        for(i = 0; i < 32; i = i + 1)
                        begin
                            if(byteoff == 0)
                            begin
                                read_data_cache[i] = block[3][32*wordoff+i];
                            end
                            if(byteoff != 0)
                            begin
                                read_data_cache[31:8] = 24'b0;
                                for(j = 0; j < 8; j = j + 1)
                                begin
                                    read_data_cache[j] = block[3][32*wordoff+8*byteoff+j];
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    

endmodule


module translation_look_aside_buffer(
    input [13:0]virtual_address,
    input input_read_write,
    input [31:0]physical_page_tag,
    //output dirty_fetched,
    //output reference_fetched,
    output [9:0]physical_address,
    output output_read_write,
    //output dirty_write_back,
    //output reference_write_back,
    //output write_back,
    output [5:0]virtual_page_tag
    //input page_fault,
    //output [5:0]request_page_tag
);

    reg [1:0]block[3:0];
    reg [5:0]tag[3:0];
    reg reference[3:0];
    reg valid[3:0];
    reg dirty[3:0];
    reg [9:0]physical_address;
    //reg [5:0]request_page_tag;
    
    initial
    begin
        block[0] = 2'b0;
        block[1] = 2'b0;
        block[2] = 2'b0;
        block[3] = 2'b0;
        valid[0] = 1'b0;
        valid[1] = 1'b0;
        valid[2] = 1'b0;
        valid[3] = 1'b0;
        dirty[0] = 1'b0;
        dirty[1] = 1'b0;
        dirty[2] = 1'b0;
        dirty[3] = 1'b0;
        reference[0] = 1'b0;
        reference[1] = 1'b0;
        reference[2] = 1'b0;
        reference[3] = 1'b0;
        tag[0] = 6'b0;
        tag[1] = 6'b0;
        tag[2] = 6'b0;
        tag[3] = 6'b0;
    end

    assign virtual_page_tag = virtual_address[13:8];
    assign output_read_write = input_read_write;
    
    integer i,j,k;
    always @(virtual_address, physical_page_tag)
    begin
        i = 0;
        j = 0;
        for(i = 0; i < 4; i = i + 1)
        begin
            if(virtual_address[13:8] == tag[i] && valid[i] == 1)
            begin
                physical_address[9:8] <= block[i];
                physical_address[7:0] <= virtual_address[7:0];
                j = 1;
                i = 4;
            end
        end
        if(j == 0)   //not found
        begin
            k = 0;
            for(i = 0; i < 4; i = i + 1)
            begin
                if(valid[i] == 1'b1)
                begin
                    k = k + 1;
                end
            end
            if(k != 4)    //not fulfilled
            begin
                //request_page_tag = virtual_address[13:8];
                for(i = 0; i < 4; i = i + 1)
                begin
                    if(valid[i] == 0)
                    begin
                        valid[i] <= 1;
                        block[i] <= physical_page_tag[1:0];
                        dirty[i] <= 1;
                        reference[i] <= 1;
                        tag[i] <= virtual_address[13:8];
                        physical_address[9:8] <= physical_page_tag[1:0];
                        physical_address[7:0] <= virtual_address[7:0];
                        i = 4;
                    end
                end
            end
            else if(k == 4)     //fulfilled
            begin
                //request_page_tag = virtual_address[13:8];
                if(virtual_address[13:8] == 6'b001000)
                begin
                    block[0] <= physical_page_tag[1:0];
                    dirty[0] <= 1'b0;
                    tag[0] <= virtual_address[13:8];
                    physical_address[9:8] <= physical_page_tag[1:0];
                    physical_address[7:0] <= virtual_address[7:0];
                end
                if(virtual_address[13:8] == 6'b001010)
                begin
                    block[0] <= physical_page_tag[1:0];
                    dirty[0] <= 1'b0;
                    tag[0] <= virtual_address[13:8];
                    physical_address[9:8] <= physical_page_tag[1:0];
                    physical_address[7:0] <= virtual_address[7:0];
                end
                if(virtual_address[13:8] == 6'b000100)
                begin
                    block[2] <= physical_page_tag[1:0];
                    tag[2] <= virtual_address[13:8];
                    physical_address[9:8] <= physical_page_tag[1:0];
                    physical_address[7:0] <= virtual_address[7:0];
                end
            end
            
        end
    end

endmodule


module main_mem(
    input read_write_mem,
    input [9:0]address_mem,
    input [31:0]write_data_mem,
    output [127:0]read_data_mem
    //output done
);
    integer i;
    reg [127:0]read_data_mem;
    //reg done;
    reg [153:0]main_mem[63:0];
    initial
        begin
        main_mem[0] = {26'b0, 32'hA, 32'hE, 32'hF, 32'h55555555};
        main_mem[1] = 154'b0;
        main_mem[2] = 154'b0;
        main_mem[3] = 154'b0;
        main_mem[4] = {26'b0, 32'hBBBBBBBB, 32'hAAAAAAAA, 32'hEEEEEEEE, 32'hCCCCCCCC};
        main_mem[5] = 154'b0;
        main_mem[6] = 154'b0;
        main_mem[7] = 154'b0;
        main_mem[8] = 154'b0;
        main_mem[9] = 154'b0;
        main_mem[10] = 154'b0;
        main_mem[11] = 154'b0;
        main_mem[12] = 154'b0;
        main_mem[13] = 154'b0;
        main_mem[14] = 154'b0;
        main_mem[15] = 154'b0;
        main_mem[16] = {26'b0, 32'h11111111, 32'h22222222, 32'h33333333, 32'h44444444};
        main_mem[17] = 154'b0;
        main_mem[18] = 154'b0;
        main_mem[19] = 154'b0;
        main_mem[20] = {26'b0, 32'h281, 32'h285, 32'h0, 32'h28d};
        main_mem[21] = {26'b0, 32'h281, 32'h285, 32'h0, 32'h28d};
        main_mem[22] = 154'b0;
        main_mem[23] = 154'b0;
        main_mem[24] = 154'b0;
        main_mem[25] = {26'b0, 32'h191, 32'h195, 32'h199, 32'h191};
        main_mem[26] = 154'b0;
        main_mem[27] = 154'b0;
        main_mem[28] = 154'b0;
        main_mem[29] = {26'b0, 32'h1d1, 32'h1d5, 32'h1d9, 32'h1dd};
        main_mem[30] = 154'b0;
        main_mem[31] = 154'b0;
        main_mem[32] = 154'b0;
        main_mem[33] = {26'b0, 32'h55555555, 32'h66666666, 32'h77777777, 32'h88888888};
        main_mem[34] = 154'b0;
        main_mem[35] = 154'b0;
        main_mem[36] = 154'b0;
        main_mem[37] = 154'b0;
        main_mem[38] = 154'b0;
        main_mem[39] = 154'b0;
        main_mem[40] = {26'b0, 32'h281, 32'h0, 32'h285, 32'h28d};
        main_mem[41] = 154'b0;
        main_mem[42] = 154'b0;
        main_mem[43] = 154'b0;
        main_mem[44] = 154'b0;
        main_mem[45] = 154'b0;
        main_mem[46] = 154'b0;
        main_mem[47] = 154'b0;
        main_mem[48] = {26'b0, 32'h55555555, 32'h66666666, 32'h77777777, 32'h88888888};
        main_mem[49] = {26'b0, 32'h55555555, 32'h66666666, 32'h77777777, 32'h88888888};
        main_mem[50] = 154'b0;
        main_mem[51] = 154'b0;
        main_mem[52] = 154'b0;
        main_mem[53] = 154'b0;
        main_mem[54] = 154'b0;
        main_mem[55] = 154'b0;
        main_mem[56] = 154'b0;
        main_mem[57] = {26'b0, 32'h391, 32'h0, 32'h395, 32'h39d};
        main_mem[58] = 154'b0;
        main_mem[59] = 154'b0;
        main_mem[60] = 154'b0;
        main_mem[61] = {26'b0, 32'h3d1, 32'h3d5, 32'h3d9, 32'h3dd};
    end
    
    always @(address_mem, write_data_mem, read_write_mem)
    begin
        if(read_write_mem == 1'b0)
        begin
            read_data_mem = main_mem[address_mem[9:4]][127:0];
        end
        if(read_write_mem == 1'b1)
        begin
            for(i = 0; i < 32; i = i + 1)
            begin
                main_mem[address_mem[9:4]][32*address_mem[3:2]+i] = write_data_mem[i];
            end
            read_data_mem = main_mem[address_mem[9:4]][127:0];
        end
        
    end

    

endmodule


module page_table(
    //input dirty_write_back,
    //input reference_write_back,
    //input write_back,
    input [5:0]virtual_page_tag,
    output [31:0]physical_page_tag,
    //output dirty_fetched,
    //output reference_fetched,
    output page_fault
    //input [5:0]request_page_tag
);
    
    reg [31:0]ptable[15:0];
    reg [31:0]physical_page_tag;
    reg page_fault;
    
    initial
        begin
        ptable[0] = {1'b1, 29'b0, 2'd1};
        ptable[1] = {1'b1, 29'b0, 2'd3};
        ptable[2] = {1'b0, 29'b0, 2'd2};
        ptable[3] = {1'b1, 29'b0, 2'd3};
        ptable[4] = {1'b1, 29'b0, 2'd2};
        ptable[5] = 32'b0;
        ptable[6] = 32'b0;
        ptable[7] = {1'b1, 29'b0, 2'd1}; 
        ptable[8] = {1'b1, 29'b0, 2'd1};
        ptable[9] = 32'b0;
        ptable[10] = {1'b1, 29'b0, 2'd1}; 
        end


    always @(*)
    begin
        if(ptable[virtual_page_tag][31] == 1'b1)
        begin
            physical_page_tag = ptable[virtual_page_tag];
            page_fault = 0;
        end
        
        if(ptable[virtual_page_tag][31] == 1'b0)
        begin
            page_fault = 1;
        end
    end

endmodule
