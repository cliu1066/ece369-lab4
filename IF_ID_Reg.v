`timescale 1ns / 1ps

module IF_ID_Reg(Clk, Rst, IF_ID_Write, IF_ID_Flush, Instruction_In, PC_In, Instruction_Out, PC_Out);
    input Clk, Rst;
    input IF_ID_Write, IF_ID_Flush;
    input [31:0] Instruction_In, PC_In;
    output reg [31:0] Instruction_Out, PC_Out;
    
    always @(posedge Clk) begin
        if (Rst) begin
            PC_Out <= 32'd0;
            Instruction_Out <= 32'd0;
        end
        else if (IF_ID_Write) begin
            PC_Out <= PC_In;
            Instruction_Out <= IF_ID_Flush ? 32'd0 : Instruction_In;
        end
    end
    
endmodule