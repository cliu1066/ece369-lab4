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
                 
    ID_EX_RegWrite, ID_EX_MemToRe,
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
    Mux32Bit2To1(EX_RegDst_Out, ID_EX_Rt, ID_EX_Rd, ID_EX_RegDst);

    //ALU
    
    
    
endmodule
