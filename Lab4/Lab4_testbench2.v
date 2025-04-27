module singleCycleTest;
    reg clk = 1;
	top test (
		clk
	);

    initial begin
            #2 clk = 0;
        forever #2 clk = ~clk;
        end
       initial begin
       forever #4 begin
            $display("===============================================");
            $display("Clock cycle %d, PC = %H", $time/2, test.PC_cs);
            //$display("Instruction0: %h, Instruction1: %h", test.Instruct, test.inst_out);
            //$display("ALUResult: %h", test.ALU_Result);
            //$display("EX_MEM_RegWrite: %h, MEM_WB_...: %h", test.EX_MEM_RegWrite_out, test.MEM_WB_RegWrite_out);
            $display("ra = %H, t0 = %H, t1 = %H", test.RF1.regs[1], test.RF1.regs[5], test.RF1.regs[6]);
            $display("t2 = %H, t3 = %H, t4 = %H", test.RF1.regs[7], test.RF1.regs[28], test.RF1.regs[29]);
            $display("===============================================");
        end
        end
        initial #120 $stop;
endmodule