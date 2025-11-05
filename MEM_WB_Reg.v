`timescale 1ns / 1ps
module MEM_WB_Reg(
    input Clk, Rst,
    input RegWrite_In, MemToReg_In, Link_In,
    input [31:0] DM_ReadData_In, ALU_Result_In, PC_AddResult_In,
    input [4:0] EX_MEM_Rd_In,   // now receives correct write register
    input [1:0] MemSize_In,
    
    output reg RegWrite_Out, MemToReg_Out, Link_Out,
    output reg [31:0] DM_ReadData_Out, MEM_WB_ALU_Result, PC_AddResult_Out,
    output reg [4:0] MEM_WB_Rd,
    output reg [1:0] MemSize_Out
    );

    always @(posedge Clk) begin
        if (Rst) begin
            RegWrite_Out <= 0;
            MemToReg_Out <= 0;
            Link_Out <= 0;
            DM_ReadData_Out <= 32'b0;
            MEM_WB_ALU_Result <= 32'b0;
            PC_AddResult_Out <= 32'b0;
            MEM_WB_Rd <= 5'b0;
            MemSize_Out <= 2'b0;
        end
        else begin
            RegWrite_Out <= RegWrite_In;
            MemToReg_Out <= MemToReg_In;
            Link_Out <= Link_In;
            DM_ReadData_Out <= DM_ReadData_In;
            MEM_WB_ALU_Result <= ALU_Result_In;
            PC_AddResult_Out <= PC_AddResult_In;
            MEM_WB_Rd <= EX_MEM_Rd_In;
            MemSize_Out <= MemSize_In;
        end
    end

endmodule
