`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Top.v
// Description - Top level module for MIPS 5 stage pipeline.
//
// INPUTS:-
// 
// 
// 
//
// OUTPUTS:-
// 
// 
//
// FUNCTIONALITY:-
// 
////////////////////////////////////////////////////////////////////////////////

module Top(Clk, Rst);
    input Clk, Rst;
    
    wire [31:0] PC_In, PC_Out, PC_AddResult;
    wire [31:0] Instruction;
    wire [31:0] JumpAddress;
    
    // Instruction Fetch
    ProgramCounter m1(PC_In, PC_Out, Rst, Clk);
    PCAdder m2(PC_Out, PC_AddResult);
    InstructionMemory m3(PC_AddResult, Instruction);
    
    // PCSrc Mux
    Mux32Bit2To1 m4(PC_Out, PC_AddResult, JumpAddress, PCSrc);
    
    // IF/ID
    wire [31:0] IF_ID_PC_Out, IF_ID_Instruction_Out;
    IF_ID_Reg m5(Clk, Rst, Instruction, PC_AddResult, IF_ID_PC_Out, IF_ID_Instruction_Out);
    
    // RegisterFile
    wire RegWrite;
    wire [4:0] MEM_WB_WriteRegister;
    wire [31:0] RegWriteData;
    wire [31:0] ReadData1, ReadData2;
    RegisterFile m6(IF_ID_Instruction_Out[25:21], IF_ID_Instruction_Out[20:16], MEM_WB_WriteRegister, RegWriteData, RegWrite, Clk, ReadData1, ReadData2);
    
    // Sign Extend
    wire [31:0] Imm_SE;
    SignExtension m7(IF_ID_Instruction_Out[15:0], Imm_SE);

    //control
    wire RegDst, Jump, Branch, MemRead, MemToReg, MemWrite, ALUSrc;
    wire [3:0] ALUOp;
    Controller m8(IF_ID_Instruction_Out[31:26], IF_ID_Instruction_Out[5:0], RegDst, Jump, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite, IF_ID_Instruction_Out[20:16]);

    //ID/EX
    wire ID_EX_RegDst, ID_EX_Jump, ID_EX_Branch, ID_EX_MemRead, ID_EX_MemToReg, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite;
    wire [3:0] ID_EX_ALUOp;
    wire [31:0] ID_EX_Jump_Addr;
    wire [31:0] ID_EX_PC_AddResult;
    wire [31:0] ID_EX_ReadData1, ID_EX_ReadData2;
    wire [31:0] ID_EX_Imm_SE;
    wire [4:0] ID_EX_Rs, ID_EX_Rt, ID_EX_Rd;
    wire [5:0] ID_EX_Funct, ID_EX_OpCode;
    ID_EX_Reg m9(Clk, Rst,
    RegWrite, MemToReg,
    Branch, MemRead, MemWrite, Jump,
    RegDst, ALUSrc,
    ALUOp,
    
    JumpAddress, IF_ID_PC_Out,
    ReadData1, ReadData2, Imm_SE,
    IF_ID_Instruction_Out[25:21], IF_ID_Instruction_Out[20:16], IF_ID_Instruction_Out[15:11],
    IF_ID_Instruction_Out[5:0], IF_ID_Instruction_Out[31:26],
                 
    ID_EX_RegWrite, ID_EX_MemToReg,
    ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_Jump,
    ID_EX_RegDst, ID_EX_ALUSrc,
    ID_EX_ALUOp,
    ID_EX_Jump_Addr, ID_EX_PC_AddResult,
    ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_Imm_SE,
    ID_EX_Rs, ID_EX_Rt, ID_EX_Rd,
    ID_EX_Funct, ID_EX_OpCode
    );
    
    //RegDst Mux
    wire [4:0] EX_RegDst_Out; 
    //output to RegDst mux in EX stage of pipeline
    Mux32Bit2To1 m10(EX_RegDst_Out, ID_EX_Rt, ID_EX_Rd, ID_EX_RegDst);

    //Shift left 2
    wire [31:0] SLL_Out;
    ALU32Bit m11(4'b0111, 32'd2, ID_EX_Imm_SE , SLL_Out, 1'b0);

    //Adder
    wire [31:0] Add_Result;
    ALU32Bit m12(4'b0010, ID_EX_PC_AddResult, SLL_Out, Add_Result, 1'b0);

    //ALUSrc Mux
    wire [31:0] EX_ALUSrc_Out;
    Mux32Bit2To1 m13(EX_ALUSrc_Out, ID_EX_ReadData2, ID_EX_Imm_SE, ID_EX_ALUSrc);

    //EX ALU
    wire EX_ALU_Zero;
    wire [31:0] EX_ALU_Result;
    ALU32Bit m14(ID_EX_ALUOp, ID_EX_ReadData1, EX_ALUSrc_Out, EX_ALU_Result, EX_ALU_Zero);

    //EX/MEM
    wire EX_MEM_Jump, EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemToReg, EX_MEM_MemWrite, EX_MEM_RegWrite;
    wire EX_MEM_Zero;
    wire [31:0] EX_MEM_Jump_Addr;
    wire [31:0] EX_MEM_ALU_Result;
    wire [31:0] EX_MEM_ReadData2;
    wire [4:0] EX_MEM_RegDst_Out;

    EX_MEM_Reg m15(
    Clk, Rst,
    ID_EX_RegWrite, ID_EX_MemToReg,
    ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_Jump,
    ID_EX_Jump_Addr, ID_EX_PC_AddResult,
    EX_ALU_Zero,
    EX_ALU_Result, ID_EX_ReadData2,
    EX_RegDst_Out,
    
    EX_MEM_RegWrite, EX_MEM_MemToReg,
    EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_Jump,
    EX_MEM_Jump_Addr, JumpAddress,
    EX_MEM_Zero,
    EX_MEM_ALU_Result, EX_MEM_ReadData2,
    EX_MEM_RegDst_Out
    );

    //Branch And Operation
    ALU32Bit m16(4'b0000, EX_MEM_Branch, EX_MEM_Zero, PCSrc, 1'b0);

    //Data Memory
    wire [31:0] MEM_DM_ReadData;
    DataMemory m17(EX_MEM_ALU_Result, EX_MEM_ReadData2, Clk, EX_MEM_MemWrite, EX_MEM_MemRead, MEM_DM_ReadData);

    //MEM/WB
    wire MEM_WB_MemToReg;
    wire [31:0] MEM_WB_DM_ReadData;
    wire [31:0] MEM_WB_ALU_Result;
    
    MEM_WB_Reg m18(
    Clk, Rst,
    EX_MEM_RegWrite, EX_MEM_MemToReg,
    MEM_DM_ReadData, EX_MEM_ALU_Result,
    EX_MEM_RegDst_Out,
    
    RegWrite, MEM_WB_MemToReg,
    MEM_WB_DM_ReadData, MEM_WB_ALU_Result,
    MEM_WB_WriteRegister
    );

    //WB Mux
    Mux32Bit2To1 m19(RegWriteData, MEM_WB_DM_ReadData, MEM_WB_ALU_Result, MEM_WB_MemToReg);

    //FIXME: jump
    
    
    
endmodule
