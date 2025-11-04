`timescale 1ns / 1ps

module MEM_WB_Reg(
    input Clk, Rst,
    input RegWrite_In, MemToReg_In, Link,
    input [31:0] DM_ReadData_In, ALU_Result_In, PC_AddResult_In,
    input [4:0] EX_MEM_Rd_In,
    
    output reg RegWrite_Out, MemToReg_Out,
    output reg [31:0] DM_ReadData_Out, ALU_Result_Out, PC_AddResult_Out,
    output reg [4:0] MEM_WB_Rd_Out
    );
    
    always @(posedge Clk) begin
        if (Rst) begin
            RegWrite_Out <= 1'b0;
            MemToReg_Out <= 1'b0;
            DM_ReadData_Out <= 32'b0;
            ALU_Result_Out <= 32'b0;
            PC_AddResult_Out <= 32'b0;
            MEM_WB_Rd_Out <= 5'b0;
        end
        else begin
            RegWrite_Out <= RegWrite_In;
            MemToReg_Out <= MemToReg_In;
            DM_ReadData_Out <= DM_ReadData_In;
            ALU_Result_Out <= PC_AddResult_In;
            PC_AddResult_Out <= PC_AddResult_In;
            MEM_WB_Rd_Out <= EX_MEM_Rd_In;
        end
    end

endmodule