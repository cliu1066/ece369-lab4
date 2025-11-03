`timescale 1ns / 1ps

module IF_ID_Reg(Clk, Rst, Instruction_In, PC_In, Instruction_Out, PC_Out);
    input Clk, Rst;
    input [31:0] Instruction_In, PC_In;
    output reg [31:0] Instruction_Out, PC_Out;
    
    always @(posedge Clk) begin
        if (Rst) begin
            PC_Out <= 32'd0;
            Instruction_Out <= 32'd0;
        end
        else begin
            PC_Out <= PC_In;
            Instruction_Out <= Instruction_In;
        end
    end
    
endmodule