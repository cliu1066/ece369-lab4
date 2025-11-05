`timescale 1ns / 1ps

module Top_tb();
    reg Clk, Rst;
    wire [31:0] PC_Out, RegWriteData;

    Top u0(
        .Clk(Clk), 
        .Rst(Rst), 
        .PC_Out(PC_Out), 
        .RegWriteData(RegWriteData)
    );
    
    initial begin
        Clk <= 1'b0;
        forever #10 Clk <= ~Clk;
    end
    
    initial begin
        Rst <= 1'b1;
        #20;
        Rst <= 1'b0;
    end
    
endmodule