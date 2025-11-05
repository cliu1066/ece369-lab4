`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2025 11:44:27 AM
// Design Name: 
// Module Name: Controller_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Controller_tb();
    reg [5:0] OpCode, Funct;
    reg [4:0] Rt;
    
    wire RegDst, Jump, Branch, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;
    wire [3:0] ALUOp;
    
    Controller u0(
        .OpCode(OpCode),
        .Funct(Funct),
        .RegDst(RegDst),
        .Jump(Jump),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Rt(Rt)
    );
    
    initial begin
        #5;
        OpCode <= 6'b000000;
        Funct <= 6'b100110;
        #5;
        OpCode <= 6'b000001;
        Rt <= 5'b00001;
        #5;
        OpCode <= 6'b000111;
        #5; 
        OpCode <= 6'b001010;
    end

endmodule
