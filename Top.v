`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Top.v
// Description - Top level module for MIPS 5 stage pipeline.
////////////////////////////////////////////////////////////////////////////////

module Top(Clk, Rst);
    input Clk, Rst;
    
    wire [31:0] PC_In, PC_Out, PC_AddResult;
    wire [31:0] Instruction;
    wire [31:0] JumpAddress, JumpRegAddress;
    
    // Instruction Fetch
    ProgramCounter m1(PC_In, PC_Out, Rst, Clk);
    PCAdder m2(PC_Out, PC_AddResult);
    InstructionMemory m3(PC_Out, Instruction);
    
    // IF/ID
    wire [31:0] IF_ID_PC_Out, IF_ID_Instruction_Out;
    IF_ID_Reg m5(Clk, Rst, Instruction, PC_Out, IF_ID_PC_Out, IF_ID_Instruction_Out);
    
    // RegisterFile
    wire RegWrite;
    wire [4:0] MEM_WB_WriteRegister;
    wire [31:0] RegWriteData;
    wire [31:0] ReadData1, ReadData2;
    RegisterFile m6(IF_ID_Instruction_Out[25:21], IF_ID_Instruction_Out[20:16], MEM_WB_WriteRegister, RegWriteData, RegWrite, Clk, ReadData1, ReadData2);
    
    // Sign Extend
    wire [31:0] Imm_SE;
    SignExtension m7(IF_ID_Instruction_Out[15:0], Imm_SE);

    // Jump Address (j, jal)
    wire [27:0] JumpTarget;
    assign JumpTarget = {IF_ID_Instruction_Out[25:0], 2'b00}; // shift left 2
    assign JumpAddress = {IF_ID_PC_Out[31:28], JumpTarget}; // full 32 bit jump address

    // Control
    wire RegDst, Jump, JumpRegister, Link, Branch, MemRead, MemToReg, MemWrite, ALUSrc;
    wire [3:0] ALUOp;
    Controller m8(IF_ID_Instruction_Out[31:26], IF_ID_Instruction_Out[5:0], RegDst, Jump, JumpRegister, Link, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite, IF_ID_Instruction_Out[20:16]);

    // ID/EX
    wire ID_EX_RegDst, ID_EX_Jump, ID_EX_JumpRegister, ID_EX_Link, ID_EX_Branch, ID_EX_MemRead, ID_EX_MemToReg, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite;
    wire [3:0] ID_EX_ALUOp;
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
        ALUOp,
        
        JumpAddress, IF_ID_PC_Out,
        ReadData1, ReadData2, Imm_SE,
        IF_ID_Instruction_Out[25:21], IF_ID_Instruction_Out[20:16], IF_ID_Instruction_Out[15:11],
        IF_ID_Instruction_Out[5:0], IF_ID_Instruction_Out[31:26],
                     
        ID_EX_RegWrite, ID_EX_MemToReg,
        ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_Jump, ID_EX_JumpRegister, ID_EX_Link,
        ID_EX_RegDst, ID_EX_ALUSrc,
        ID_EX_ALUOp,
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
    ALU32Bit m12(4'b0010, ID_EX_PC_AddResult, SLL_Out, Add_Result, 1'b0);

    // ALUSrc Mux
    wire [31:0] EX_ALUSrc_Out;
    Mux32Bit2To1 m13(EX_ALUSrc_Out, ID_EX_ReadData2, ID_EX_Imm_SE, ID_EX_ALUSrc);

    // EX ALU
    wire EX_ALU_Zero;
    wire [31:0] EX_ALU_Result;
    ALU32Bit m14(ID_EX_ALUOp, ID_EX_ReadData1, EX_ALUSrc_Out, EX_ALU_Result, EX_ALU_Zero);

    // EX/MEM
    wire EX_MEM_Jump, EX_MEM_JumpRegister, EX_MEM_Link, EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemToReg, EX_MEM_MemWrite, EX_MEM_RegWrite;
    wire EX_MEM_Zero;
    wire [31:0] EX_MEM_Jump_Addr, EX_MEM_PC_AddResult;
    wire [31:0] EX_MEM_ALU_Result;
    wire [31:0] EX_MEM_ReadData2;
    wire [4:0] EX_MEM_RegDst_Out;

    EX_MEM_Reg m15(
        Clk, Rst,
        ID_EX_RegWrite, ID_EX_MemToReg,
        ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_Jump, ID_EX_JumpRegister, ID_EX_Link,
        ID_EX_Jump_Addr, ID_EX_PC_AddResult,
        EX_ALU_Zero,
        EX_ALU_Result, ID_EX_ReadData2,
        EX_RegDst_Out,
        
        EX_MEM_RegWrite, EX_MEM_MemToReg,
        EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_Jump, EX_MEM_JumpRegister, EX_MEM_Link,
        EX_MEM_Jump_Addr, EX_MEM_PC_AddResult,
        EX_MEM_Zero,
        EX_MEM_ALU_Result, EX_MEM_ReadData2,
        EX_MEM_RegDst_Out
    );

    // PCSrc Mux
    wire [31:0] BranchTarget;
    assign BranchTarget = Add_Result;
    /*assign PC_In = EX_MEM_JumpRegister ? EX_MEM_ReadData2 :
                   EX_MEM_Jump ? EX_MEM_Jump_Addr :
                   (EX_MEM_Branch && EX_MEM_Zero) ? BranchTarget :
                   PC_AddResult;*/
    wire [1:0] PCSrc;
    assign PCSrc = EX_MEM_JumpRegister ? 2'b10 :
                   EX_MEM_Jump         ? 2'b01 :
                                         2'b00;
    Mux32Bit3To1 m21(PC_In, PC_AddResult, EX_MEM_Jump_Addr, EX_MEM_ReadData2, PCSrc);
    
    // Branch
    // ALU32Bit m16(4'b0000, EX_MEM_Branch, EX_MEM_Zero, PCSrc, 1'b0);

    // Data Memory
    wire [31:0] MEM_DM_ReadData;
    DataMemory m17(EX_MEM_ALU_Result, EX_MEM_ReadData2, Clk, EX_MEM_MemWrite, EX_MEM_MemRead, MEM_DM_ReadData);

    // MEM/WB
    wire MEM_WB_MemToReg, MEM_WB_Link;
    wire [31:0] MEM_WB_DM_ReadData, MEM_WB_ALU_Result, MEM_WB_PC_AddResult;
    wire [31:0] MEM_WB_RegDst_Out;
    
    MEM_WB_Reg m18(
        Clk, Rst,
        EX_MEM_RegWrite, EX_MEM_MemToReg, EX_MEM_Link,
        MEM_DM_ReadData, EX_MEM_ALU_Result, EX_MEM_PC_AddResult,
        EX_MEM_RegDst_Out,
        
        RegWrite, MEM_WB_MemToReg, MEM_WB_Link,
        MEM_WB_DM_ReadData, MEM_WB_ALU_Result, MEM_WB_PC_AddResult,
        MEM_WB_RegDst_Out
    );

    // WB Mux and WriteRegister Override for jal
    assign MEM_WB_WriteRegister = MEM_WB_Link ? 5'd31 : MEM_WB_RegDst_Out;
    assign RegWriteData = MEM_WB_Link ? MEM_WB_PC_AddResult :
                          MEM_WB_MemToReg ? MEM_WB_DM_ReadData :
                          MEM_WB_ALU_Result;
    //Mux32Bit2To1 m19(RegWriteData, MEM_WB_DM_ReadData, MEM_WB_ALU_Result, MEM_WB_MemToReg);
    
endmodule