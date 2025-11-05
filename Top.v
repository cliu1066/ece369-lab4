`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Top.v
// Description - Top level module for MIPS 5 stage pipeline.
////////////////////////////////////////////////////////////////////////////////

module Top(Clk, Rst, PC_Out, RegWriteData);
    input Clk, Rst;
    
    wire [31:0] PC_In, PC_AddResult;
    output wire [31:0] PC_Out;
    wire [31:0] Instruction;
    wire [31:0] JumpAddress;
    
    // Instruction Fetch
    ProgramCounter m1(PC_In, PC_Out, Rst, Clk);
    PCAdder m2(PC_Out, PC_AddResult);
    InstructionMemory m3(PC_Out, Instruction);
    
    // IF/ID
    wire [31:0] IF_ID_PC_Out, IF_ID_Instruction_Out;
    IF_ID_Reg m5(
      .Clk(Clk),
      .Rst(Rst),
      .Instruction_In(Instruction),
      .PC_In(PC_Out),
      .Instruction_Out(IF_ID_Instruction_Out),
      .PC_Out(IF_ID_PC_Out)                    
    );

    
    // RegisterFile
    wire RegWrite;
    wire [4:0] MEM_WB_WriteRegister;
    output wire [31:0] RegWriteData;
    wire [31:0] ReadData1, ReadData2;
    
    RegisterFile m6 (
        .ReadRegister1(IF_ID_Instruction_Out[25:21]),
        .ReadRegister2(IF_ID_Instruction_Out[20:16]),
        .WriteRegister(MEM_WB_WriteRegister),          // 5-bit
        .WriteData(RegWriteData),
        .RegWrite(MEM_WB_RegWrite),
        .Clk(Clk),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    
    // Sign Extend
    wire [31:0] Imm_SE;
    SignExtension m7(IF_ID_Instruction_Out[15:0], Imm_SE);

    // Jump Address (j, jal)
    wire [27:0] JumpTarget;
    assign JumpTarget = {IF_ID_Instruction_Out[25:0], 2'b00}; // shift left 2
    assign JumpAddress = {IF_ID_PC_Out[31:28], JumpTarget}; // full 32 bit jump address

    // Control
    wire RegDst, Jump, JumpRegister, Link, Branch, MemRead, MemToReg, MemWrite, ALUSrc;
    wire [1:0] MemSize; // 00: word, 01: halfword, 10: byte
    wire [3:0] ALUOp;
    Controller m8 (
        .OpCode(IF_ID_Instruction_Out[31:26]),
        .Funct (IF_ID_Instruction_Out[5:0]),
        .RegDst(RegDst),
        .Jump(Jump),
        .JumpRegister(JumpRegister),
        .Link(Link),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .MemSize(MemSize),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Rt(IF_ID_Instruction_Out[20:16])
    );

    // ID/EX
    wire ID_EX_RegDst, ID_EX_Jump, ID_EX_JumpRegister, ID_EX_Link, ID_EX_Branch, ID_EX_MemRead, ID_EX_MemToReg, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite;
    wire [3:0] ID_EX_ALUOp;
    wire [1:0] ID_EX_MemSize;
    wire [31:0] ID_EX_Jump_Addr;
    wire [31:0] ID_EX_PC_AddResult;
    wire [31:0] ID_EX_ReadData1, ID_EX_ReadData2;
    wire [31:0] ID_EX_Imm_SE;
    wire [4:0] ID_EX_Rs, ID_EX_Rt, ID_EX_Rd;
    wire [5:0] ID_EX_Funct, ID_EX_OpCode;
    ID_EX_Reg m9(Clk, Rst,
        RegWrite, MemToReg,
        Branch, MemRead, MemWrite, Jump, JumpRegister, Link,
        RegDst, ALUSrc,
        ALUOp, MemSize,
        
        JumpAddress, PC_AddResult,
        ReadData1, ReadData2, Imm_SE,
        IF_ID_Instruction_Out[25:21], IF_ID_Instruction_Out[20:16], IF_ID_Instruction_Out[15:11],
        IF_ID_Instruction_Out[5:0], IF_ID_Instruction_Out[31:26],
                     
        ID_EX_RegWrite, ID_EX_MemToReg,
        ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_Jump, ID_EX_JumpRegister, ID_EX_Link,
        ID_EX_RegDst, ID_EX_ALUSrc,
        ID_EX_ALUOp, ID_EX_MemSize,
        ID_EX_Jump_Addr, ID_EX_PC_AddResult,
        ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_Imm_SE,
        ID_EX_Rs, ID_EX_Rt, ID_EX_Rd,
        ID_EX_Funct, ID_EX_OpCode
    );
    
    // RegDst Mux
    wire [4:0] EX_RegDst_Out; 
    // output to RegDst mux in EX stage of pipeline
    //Mux32Bit2To1 m10(EX_RegDst_Out, ID_EX_Rt, ID_EX_Rd, ID_EX_RegDst);
    assign EX_RegDst_Out = ID_EX_RegDst ? ID_EX_Rd : ID_EX_Rt;

    // Shift left 2
    wire [31:0] SLL_Out;
    //ALU32Bit m11(4'b0111, 32'd2, ID_EX_Imm_SE , SLL_Out, 1'b0);
    assign SLL_Out = ID_EX_Imm_SE << 2;

    // Branch Target Adder
    wire [31:0] Add_Result;
    wire DummyZero;
    ALU32Bit m12(4'b0010, ID_EX_PC_AddResult, SLL_Out, Add_Result, DummyZero);

    // ALUSrc Mux
    wire [31:0] EX_ALUSrc_Out;
    Mux32Bit2To1 m13(EX_ALUSrc_Out, ID_EX_ReadData2, ID_EX_Imm_SE, ID_EX_ALUSrc);

    // EX ALU
    wire EX_ALU_Zero;
    wire [31:0] EX_ALU_Result;
    ALU32Bit m14(ID_EX_ALUOp, ID_EX_ReadData1, EX_ALUSrc_Out, EX_ALU_Result, EX_ALU_Zero);

    // EX/MEM
    wire [31:0] EX_MEM_BranchAddr;
    wire EX_MEM_Jump, EX_MEM_JumpRegister, EX_MEM_Link, EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemToReg, EX_MEM_MemWrite, EX_MEM_RegWrite;
    wire EX_MEM_ALUZero;
    wire [1:0] EX_MEM_MemSize;
    wire [31:0] EX_MEM_Jump_Addr, EX_MEM_PC_AddResult;
    wire [31:0] EX_MEM_ALU_Result;
    wire [31:0] EX_MEM_ReadData2;
    wire [31:0] EX_MEM_BranchTarget;
    wire [4:0] EX_MEM_Rd;

    EX_MEM_Reg m15 (
        .Clk(Clk),
        .Rst(Rst),
        .RegWrite_In(ID_EX_RegWrite),
        .MemToReg_In(ID_EX_MemToReg),
        .Branch_In(ID_EX_Branch),
        .MemRead_In(ID_EX_MemRead),
        .MemWrite_In(ID_EX_MemWrite),
        .Jump_In(ID_EX_Jump),
        .JumpRegister_In(ID_EX_JumpRegister),
        .Link_In(ID_EX_Link),
        .RegDst_In(ID_EX_RegDst),
        .MemSize_In(ID_EX_MemSize),
        .JumpAddr_In(ID_EX_Jump_Addr),
        .BranchAddr_In(ID_EX_PC_AddResult),
        .ALUZero_In(EX_ALU_Zero),
        .ALUResult_In(EX_ALU_Result),
        .ReadData2_In(ID_EX_ReadData2),
        .BranchTarget_In(Add_Result),
        .ID_EX_Rd_In(EX_RegDst_Out),
        .ID_EX_Rt_In(ID_EX_Rt),
        
        .RegWrite_Out(EX_MEM_RegWrite),
        .MemToReg_Out(EX_MEM_MemToReg),
        .Branch_Out(EX_MEM_Branch),
        .MemRead_Out(EX_MEM_MemRead),
        .MemWrite_Out(EX_MEM_MemWrite),
        .Jump_Out(EX_MEM_Jump),
        .JumpRegister_Out(EX_MEM_JumpRegister),
        .Link_Out(EX_MEM_Link),
        .MemSize_Out(EX_MEM_MemSize),
        .JumpAddr_Out(EX_MEM_Jump_Addr),
        .BranchAddr_Out(EX_MEM_BranchAddr),
        .ALUZero_Out(EX_MEM_ALUZero),
        .ALUResult_Out(EX_MEM_ALU_Result),
        .ReadData2_Out(EX_MEM_ReadData2),
        .BranchTarget_Out(EX_MEM_BranchTarget),
        .EX_MEM_Rd_Out(EX_MEM_Rd)
    );

    // PCSrc Mux
    wire [31:0] BranchTarget;
    wire BranchALUResult = EX_MEM_ALU_Result[0];
    assign BranchTarget = EX_MEM_BranchTarget;
    assign PC_In = EX_MEM_JumpRegister ? EX_MEM_ReadData2 :
                   EX_MEM_Jump ? EX_MEM_Jump_Addr :
                   (EX_MEM_Branch && BranchALUResult == 1'b1) ? BranchTarget :
                   PC_AddResult;
    /*wire [1:0] PCSrc;
    assign PCSrc = EX_MEM_JumpRegister ? 2'b10 :
                   EX_MEM_Jump         ? 2'b01 :
                                         2'b00;
    Mux32Bit3To1 m21(PC_In, PC_AddResult, EX_MEM_Jump_Addr, EX_MEM_ReadData2, PCSrc);*/
    
    // Branch
    //ALU32Bit m16(4'b0000, EX_MEM_Branch, EX_MEM_ALU_Result[0], PCSrc, 1'b0);
    
    // Data Memory
    wire [31:0] MEM_DM_ReadData;
    DataMemory m17(EX_MEM_ALU_Result, EX_MEM_ReadData2, Clk, EX_MEM_MemWrite, EX_MEM_MemRead, MEM_DM_ReadData, EX_MEM_MemSize);
    
    // MEM/WB
    wire MEM_WB_RegWrite, MEM_WB_MemToReg, MEM_WB_Link;
    wire [31:0] MEM_WB_DM_ReadData, MEM_WB_ALU_Result, MEM_WB_PC_AddResult;
    
    wire [4:0] MEM_WB_Rd;
    assign MEM_WB_WriteRegister = MEM_WB_Rd;
    
    wire [1:0] MEM_WB_MemSize;
    
    MEM_WB_Reg m18 (
        .Clk(Clk),
        .Rst(Rst),
        .RegWrite_In(EX_MEM_RegWrite),
        .MemToReg_In(EX_MEM_MemToReg),
        .Link_In(EX_MEM_Link),
        .DM_ReadData_In(MEM_DM_ReadData),
        .ALU_Result_In(EX_MEM_ALU_Result),
        .PC_AddResult_In(EX_MEM_BranchAddr),
        .EX_MEM_Rd_In(EX_MEM_Rd),
        .MemSize_In(EX_MEM_MemSize),
        
        .RegWrite_Out(MEM_WB_RegWrite),
        .MemToReg_Out(MEM_WB_MemToReg),
        .Link_Out(MEM_WB_Link),
        .DM_ReadData_Out(MEM_WB_DM_ReadData),
        .MEM_WB_ALU_Result(MEM_WB_ALU_Result),
        .PC_AddResult_Out(MEM_WB_PC_AddResult),
        .MEM_WB_Rd(MEM_WB_Rd),
        .MemSize_Out(MEM_WB_MemSize)
    );


    // WB Mux and WriteRegister Override for jal
    assign MEM_WB_WriteRegister = MEM_WB_Link ? 5'd31 : MEM_WB_Rd;
    assign RegWriteData = MEM_WB_Link ? MEM_WB_PC_AddResult :
                          MEM_WB_MemToReg ? MEM_WB_DM_ReadData :
                          MEM_WB_ALU_Result;
    //Mux32Bit2To1 m19(RegWriteData, MEM_WB_DM_ReadData, MEM_WB_ALU_Result, MEM_WB_MemToReg);
    
endmodule