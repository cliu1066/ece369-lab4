`timescale 1ns / 1ps

module ID_EX_Reg(
    input Clk, Rst,
    input RegWrite_In, MemToReg_In,
    input Branch_In, MemRead_In, MemWrite_In, Jump_In,
    input JumpRegister_In, Link_In,
    input RegDst_In, ALUSrc_In,
    input [3:0] ALUOp_In,
    input [1:0] MemSize_In,
    
    input [31:0] Jump_Addr_In, PC_In,
    input [31:0] ReadData1, ReadData2, ImmSE_In,
    input [4:0] IF_ID_Rs_In, IF_ID_Rt_In, IF_ID_Rd_In,
    input [5:0] IF_ID_Funct_In, IF_ID_OpCode_In,
    input [4:0] Shamt_In,
    input ID_EX_Flush,
    
    output reg RegWrite_Out, MemToReg_Out,
    output reg Branch_Out, MemRead_Out, MemWrite_Out, Jump_Out,
    output reg JumpRegister_Out, Link_Out,
    output reg RegDst_Out, ALUSrc_Out,
    output reg [3:0] ALUOp_Out,
    output reg [1:0] MemSize_Out,
    output reg [31:0] Jump_Addr_Out, PC_Out,
    output reg [31:0] ReadData1_Out, ReadData2_Out, ImmSE_Out,
    output reg [4:0] IF_ID_Rs_Out, IF_ID_Rt_Out, IF_ID_Rd_Out,
    output reg [5:0] IF_ID_Funct_Out, IF_ID_OpCode_Out,
    output reg [4:0] Shamt_Out
    );
    
    always@(posedge Clk) begin
        if (Rst) begin
            RegWrite_Out <= 1'b0;
            MemToReg_Out <= 1'b0;
            Branch_Out <= 1'b0;
            MemRead_Out <= 1'b0;
            MemWrite_Out <= 1'b0;
            Jump_Out <= 1'b0;
            JumpRegister_Out <= 1'b0;
            Link_Out <= 1'b0;
            RegDst_Out <= 1'b0;
            ALUSrc_Out <= 1'b0;
            ALUOp_Out <= 4'b0;
            MemSize_Out <= 2'b0;
            Jump_Addr_Out <= 32'b0;
            PC_Out <= 32'b0;
            ReadData1_Out <= 32'b0;
            ReadData2_Out <= 32'b0;
            ImmSE_Out <= 32'b0;
            IF_ID_Rs_Out <= 5'b0;
            IF_ID_Rt_Out <= 5'b0;
            IF_ID_Rd_Out <= 5'b0;
            IF_ID_Funct_Out <= 6'b0;
            IF_ID_OpCode_Out <= 6'b0;
            Shamt_Out <= 5'b0;
        end
        else if (ID_EX_Flush) begin
            RegWrite_Out <= 0;
            MemToReg_Out <= 0;
            Branch_Out   <= 0;
            MemRead_Out  <= 0;
            MemWrite_Out <= 0;
            Jump_Out     <= 0;
            JumpRegister_Out <= 0;
            Link_Out <= 0;
            RegDst_Out <= 0;
            ALUSrc_Out <= 0;
            ALUOp_Out  <= 4'b0000;
            MemSize_Out <= 2'b00;
        end
        else begin
            RegWrite_Out <= RegWrite_In;
            MemToReg_Out <= MemToReg_In;
            Branch_Out <= Branch_In;
            MemRead_Out <= MemRead_In;
            MemWrite_Out <= MemWrite_In;
            Jump_Out <= Jump_In;
            JumpRegister_Out <= JumpRegister_In;
            Link_Out <= Link_In;
            RegDst_Out <= RegDst_In;
            ALUSrc_Out <= ALUSrc_In;
            ALUOp_Out <= ALUOp_In;
            MemSize_Out <= MemSize_In;
            Jump_Addr_Out <= Jump_Addr_In;
            PC_Out <= PC_In;
            ReadData1_Out <= ReadData1;
            ReadData2_Out <= ReadData2;
            ImmSE_Out <= ImmSE_In;
            IF_ID_Rs_Out <= IF_ID_Rs_In;
            IF_ID_Rt_Out <= IF_ID_Rt_In;
            IF_ID_Rd_Out <= IF_ID_Rd_In;
            IF_ID_Funct_Out <= IF_ID_Funct_In;
            IF_ID_OpCode_Out <= IF_ID_OpCode_In;
            Shamt_Out <= Shamt_In;
        end
    end

endmodule