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

module Top(Clk, Rst, WriteData);
    input Clk, Rst;
    output reg [31:0] WriteData;
    
    wire [31:0] PCIn, PCOut;
    wire [5:0] OpCode, Funct;
    
    wire [31:0] Instruction, ID_Instruction, EX_Instruction;
    wire [31:0] JumpAddress;
    
    // Extend
    wire [15:0] Imm16;
    wire [31:0] Imm16_Ext, EX_Imm16_Ext;
    
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