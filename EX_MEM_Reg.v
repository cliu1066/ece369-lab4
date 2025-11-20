`timescale 1ns / 1ps
module EX_MEM_Reg(
    input Clk, Rst,
    input RegWrite_In, MemToReg_In,
    input Branch_In, MemRead_In, MemWrite_In, Jump_In,
    input JumpRegister_In, Link_In,
    input RegDst_In,            // needed to compute write register
    input [1:0] MemSize_In,
    input [31:0] JumpAddr_In, BranchAddr_In,
    input ALUZero_In,
    input [31:0] ALUResult_In, ReadData2_In,
    input [31:0] BranchTarget_In,
    input [4:0] ID_EX_Rd_In,
    input [4:0] ID_EX_Rt_In,    // added to select for I-type
     
    output reg RegWrite_Out, MemToReg_Out,
    output reg Branch_Out, MemRead_Out, MemWrite_Out, Jump_Out,
    output reg JumpRegister_Out, Link_Out,
    output reg [1:0] MemSize_Out,
    output reg [31:0] JumpAddr_Out, BranchAddr_Out,
    output reg ALUZero_Out,
    output reg [31:0] ALUResult_Out, ReadData2_Out,
    output reg [31:0] BranchTarget_Out,
    output reg [4:0] EX_MEM_Rd_Out   // this is now the correct write register
    );

    wire [4:0] EX_WriteReg = RegDst_In ? ID_EX_Rd_In : ID_EX_Rt_In;

    always @(posedge Clk) begin
        if (Rst) begin
            RegWrite_Out = 0;
            MemToReg_Out = 0;
            Branch_Out = 0;
            MemRead_Out = 0;
            MemWrite_Out = 0;
            Jump_Out = 0;
            JumpRegister_Out = 0;
            Link_Out = 0;
            MemSize_Out = 2'b0;
            JumpAddr_Out = 32'b0;
            BranchAddr_Out = 32'b0;
            ALUZero_Out = 0;
            ALUResult_Out = 32'b0;
            ReadData2_Out = 32'b0;
            BranchTarget_Out = 32'b0;
            EX_MEM_Rd_Out = 5'b0;
        end
        else begin
            RegWrite_Out = RegWrite_In;
            MemToReg_Out = MemToReg_In;
            Branch_Out = Branch_In;
            MemRead_Out = MemRead_In;
            MemWrite_Out = MemWrite_In;
            Jump_Out = Jump_In;
            JumpRegister_Out = JumpRegister_In;
            Link_Out = Link_In;
            MemSize_Out = MemSize_In;
            JumpAddr_Out = JumpAddr_In;
            BranchAddr_Out = BranchAddr_In;
            ALUZero_Out = ALUZero_In;
            ALUResult_Out = ALUResult_In;
            ReadData2_Out = ReadData2_In;
            BranchTarget_Out = BranchTarget_In;
            EX_MEM_Rd_Out = EX_WriteReg;  // select Rd or Rt correctly
        end
    end
    
endmodule