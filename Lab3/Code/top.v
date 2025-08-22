`timescale 1ns / 1ps

module SingleCycleProcessor(input clk);

    // Program Counter (PC)
    wire [31:0] PC_in, PC_cs;
    PC_switch PC_reg(.PC_in(PC_in), .PC_out(PC_cs), .clk(clk));

    // Instruction Fetch (IF) Stage
    wire [31:0] Inst;
    instruction_memory IM(.PC(PC_cs), .Inst(Inst));

    // Next PC logic (PC + 4)
    wire [31:0] PC_plus4;
    adder PC_adder(.in1(PC_cs), .in2(32'd4), .out(PC_plus4));

    // IF/ID Pipeline Register
    wire [31:0] IF_ID_PC, IF_ID_nPC, IF_ID_Inst;
    IF_ID IF_ID_reg(
        .clk(clk),
        .current_PC(PC_cs),
        .next_PC(PC_plus4),
        .Instruction(Inst),
        .cPC(IF_ID_PC),
        .nPC(IF_ID_nPC),
        .Inst(IF_ID_Inst)
    );

    // Instruction Decode (ID) Stage
    // Extract instruction fields
    wire [6:0] opcode = IF_ID_Inst[6:0];
    wire [4:0] rd = IF_ID_Inst[11:7];
    wire [2:0] funct3 = IF_ID_Inst[14:12];
    wire [4:0] rs1 = IF_ID_Inst[19:15];
    wire [4:0] rs2 = IF_ID_Inst[24:20];
    wire [6:0] funct7 = IF_ID_Inst[31:25];
        wire [31:0] WriteData;


    // Control Unit
    wire Branch, MemRead, MemWrite, ALUSrc, RegWrite, Jump;
    wire [1:0] MemtoReg, ALUop;
    control control_unit(
        .Inst(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUop(ALUop),
        .MemWrite(MemWrite),
        .ALUsrc(ALUSrc),
        .RegWrite(RegWrite),
        .jump(Jump)
    );

    // Register File
    wire [31:0] ReadData1, ReadData2;
    wire [4:0] MEM_WB_rd_out;
    register RF1(
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(MEM_WB_rd_out),
        .write_data(WriteData),
        .read_data1(ReadData1),
        .read_data2(ReadData2),
        .reg_write(MEM_WB_RegWrite_out)
    );

    // Immediate Generator
    wire [31:0] Immediate;
    ImmGen Imm_Generator(.ins(IF_ID_Inst), .imm(Immediate));

    // Function code for ALU Control
    wire [3:0] function_code = {IF_ID_Inst[30], IF_ID_Inst[14:12]};

    // ID/EX Pipeline Register
    wire ID_EX_RegWrite_out, ID_EX_MemRead_out, ID_EX_MemWrite_out, ID_EX_Branch_out, ID_EX_ALUSrc_out, ID_EX_jump_out;
    wire [1:0] ID_EX_MemtoReg_out, ID_EX_ALUOp_out;
    wire [31:0] ID_EX_PC_out, ID_EX_nPC_out, ID_EX_ReadData1_out, ID_EX_ReadData2_out, ID_EX_Immediate_out;
    wire [3:0] ID_EX_function_code_out;
    wire [4:0] ID_EX_rd_out;
    ID_EX ID_EX_reg(
        .clk(clk),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUop),
        .current_PC(IF_ID_PC),
        .next_PC(IF_ID_nPC),
        .Readdata1(ReadData1),
        .Readdata2(ReadData2),
        .Immediate(Immediate),
        .function_code(function_code),
        .rd(rd),
        .jump(Jump),
        .RegWrite_out(ID_EX_RegWrite_out),
        .MemtoReg_out(ID_EX_MemtoReg_out),
        .MemRead_out(ID_EX_MemRead_out),
        .MemWrite_out(ID_EX_MemWrite_out),
        .Branch_out(ID_EX_Branch_out),
        .ALUSrc_out(ID_EX_ALUSrc_out),
        .ALUOp_out(ID_EX_ALUOp_out),
        .current_PC_out(ID_EX_PC_out),
        .next_PC_out(ID_EX_nPC_out),
        .Readdata1_out(ID_EX_ReadData1_out),
        .Readdata2_out(ID_EX_ReadData2_out),
        .Immediate_out(ID_EX_Immediate_out),
        .function_code_out(ID_EX_function_code_out),
        .rd_out(ID_EX_rd_out),
        .jump_out(ID_EX_jump_out)
    );

    // Execution (EX) Stage
    // ALU Control
    wire [3:0] ALU_Control_Signal;
    ALU_Control ALU_Control_Unit(
        .Inst(ID_EX_function_code_out),
        .ALUop(ID_EX_ALUOp_out),
        .control(ALU_Control_Signal)
    );

    // ALU Source MUX
    wire [31:0] ALU_in2;
    TWO_MUX ALU_Src_MUX(
        .in0(ID_EX_ReadData2_out),
        .in1(ID_EX_Immediate_out),
        .select(ID_EX_ALUSrc_out),
        .out(ALU_in2)
    );

    // ALU
    wire Zero;
    wire [31:0] ALU_Result;
    ALU ALU_Unit(
        .in1(ID_EX_ReadData1_out),
        .in2(ALU_in2),
        .control(ALU_Control_Signal),
        .zero(Zero),
        .result(ALU_Result)
    );

    // Branch Target Calculation
    wire [31:0] Shifted_Immediate;
    shift_left Shift_Left(
        .in(ID_EX_Immediate_out),
        .out(Shifted_Immediate)
    );

    wire [31:0] Branch_Target;
    adder Branch_Adder(
        .in1(ID_EX_PC_out),
        .in2(Shifted_Immediate),
        .out(Branch_Target)
    );
    
            // PC Selection Logic
    reg [1:0] PC_select;
    always @(*) begin
        if (ID_EX_Branch_out) begin
            if (Zero) begin
                PC_select = 2'b01; // Branch taken
            end else if (ALU_Control_Signal == 4'b1111) begin
            if (ID_EX_jump_out == 0)
                PC_select = 2'b10; // JAL
                else PC_select = 2'b11; // JALR
            end
        end else begin
            PC_select = 2'b00; // Next sequential instruction
        end
    end

    // PC MUX
    wire [31:0] PC_next;
    FOUR_MUX PC_MUX(
        .in0(PC_plus4),
        .in1(Branch_Target),
        .in2(Branch_Target),
        .in3(ALU_Result),
        .sel(PC_select),
        .out(PC_in)
    );

    // EX/MEM Pipeline Register
    wire EX_MEM_RegWrite_out, EX_MEM_MemRead_out, EX_MEM_MemWrite_out, EX_MEM_Branch_out, EX_MEM_Zero_out;
    wire [1:0] EX_MEM_MemtoReg_out;
    wire [31:0] EX_MEM_Branch_Target_out, EX_MEM_nPC_out, EX_MEM_ALU_Result_out, EX_MEM_ReadData2_out;
    wire [2:0] EX_MEM_funct3_out;
    wire [4:0] EX_MEM_rd_out;
    EX_MEM EX_MEM_reg(
        .clk(clk),
        .RegWrite(ID_EX_RegWrite_out),
        .MemtoReg(ID_EX_MemtoReg_out),
        .MemRead(ID_EX_MemRead_out),
        .MemWrite(ID_EX_MemWrite_out),
        .Branch(ID_EX_Branch_out),
        .Zero(Zero),
        .PC_sum(Branch_Target),
        .next_PC(ID_EX_nPC_out),
        .ALU_result(ALU_Result),
        .Readdata2(ID_EX_ReadData2_out),
        .funct3(ID_EX_function_code_out[2:0]),
        .rd(ID_EX_rd_out),
        .RegWrite_out(EX_MEM_RegWrite_out),
        .MemtoReg_out(EX_MEM_MemtoReg_out),
        .MemRead_out(EX_MEM_MemRead_out),
        .MemWrite_out(EX_MEM_MemWrite_out),
        .Branch_out(EX_MEM_Branch_out),
        .Zero_out(EX_MEM_Zero_out),
        .PC_sum_out(EX_MEM_Branch_Target_out),
        .next_PC_out(EX_MEM_nPC_out),
        .ALU_result_out(EX_MEM_ALU_Result_out),
        .Readdata2_out(EX_MEM_ReadData2_out),
        .funct3_out(EX_MEM_funct3_out),
        .rd_out(EX_MEM_rd_out)
    );

    // Memory Access (MEM) Stage
    // Data Memory
    wire [31:0] ReadData;
    data_memory DataMem1(
        .MemRead(EX_MEM_MemRead_out),
        .MemWrite(EX_MEM_MemWrite_out),
        .inst(EX_MEM_funct3_out),
        .addr(EX_MEM_ALU_Result_out),
        .WriteData(EX_MEM_ReadData2_out),
        .ReadData(ReadData)
    );

    // MEM/WB Pipeline Register
    wire [1:0] MEM_WB_MemtoReg_out;
    wire [31:0] MEM_WB_nPC_out, MEM_WB_ReadData_out, MEM_WB_ALU_Result_out, MEM_WB_Branch_Target_out;
    MEM_WB MEM_WB_reg(
        .clk(clk),
        .RegWrite(EX_MEM_RegWrite_out),
        .MemtoReg(EX_MEM_MemtoReg_out),
        .next_PC(EX_MEM_nPC_out),
        .Readdata(ReadData),
        .ALU_result(EX_MEM_ALU_Result_out),
        .rd(EX_MEM_rd_out),
        .Branch_target(EX_MEM_Branch_Target_out),
        .RegWrite_out(MEM_WB_RegWrite_out),
        .MemtoReg_out(MEM_WB_MemtoReg_out),
        .next_PC_out(MEM_WB_nPC_out),
        .Readdata_out(MEM_WB_ReadData_out),
        .ALU_result_out(MEM_WB_ALU_Result_out),
        .rd_out(MEM_WB_rd_out),
        .Branch_target_out(MEM_WB_Branch_Target_out)
    );

    // Write Back (WB) Stage
    // Write Back MUX
    FOUR_MUX Write_Back_MUX(
        .in0(MEM_WB_ALU_Result_out),
        .in1(MEM_WB_ReadData_out),
        .in2(MEM_WB_nPC_out),
        .in3(32'd0),
        .sel(MEM_WB_MemtoReg_out),
        .out(WriteData)
    );

endmodule
