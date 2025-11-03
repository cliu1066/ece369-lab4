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
    wire [4:0] ReadRegister1, ReadRegister2;
    wire [4:0] MEM_WB_WriteRegister;
    wire [31:0] RegWriteData;
    wire [31:0] ReadData1, ReadData2;
    RegisterFile m6(ReadRegister1, ReadRegister2, MEM_WB_WriteRegister, RegWriteData, RegWrite, Clk, ReadData1, ReadData2);
    
    // Sign Extend
    wire [31:0] Imm_SE;
    SignExtension m7(IF_ID_Instruction_Out, Imm_SE);
    
    // RegFile
    wire [4:0] Rs, Rt, Rd, EX_Rs, EX_Rt, EX_Rd, EX_WriteReg, MEM_WriteReg, WB_WriteReg;
    wire [31:0] WB_WriteData, ReadData1, ReadData2, EX_ReadData1, EX_ReadData2;
    
    // ALU
    wire [31:0] EX_ALUResult, MEM_ALUResult, WB_ALUResult;
    wire ALUZero;
    
    // Control Signals
    wire RegDst, Jump, Branch, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;
    wire ID_RegDst, ID_Jump, ID_Branch, ID_MemRead, ID_MemToReg, ID_MemWrite, ID_ALUSrc, ID_RegWrite;
    wire EX_RegDst, EX_Jump, EX_Branch, EX_MemRead, EX_MemToReg, EX_MemWrite, EX_ALUSrc, EX_RegWrite;
    wire MEM_MemToReg, MEM_RegWrite, MEM_MemRead, MEM_MemWrite;
    wire WB_MemToReg, WB_RegWrite;
    wire [3:0] ALUOp, ID_ALUOp, EX_ALUOp;
    
endmodule