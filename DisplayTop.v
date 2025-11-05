`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
//
// Student(s) Name and Last Name: 
//      Candice Liu (33%), Andrew Ghartey (33%), Barack Marwanga Asande (33%)
// 
// Module - DisplayTop.v
// Description - Top level module connecting datapath with modules for FPGA display
//
////////////////////////////////////////////////////////////////////////////////

module DisplayTop(Clk, Rst, out7, en_out);
    input Clk, Rst;
    output [6:0] out7;
    output [7:0] en_out;
    
    wire ClkOut;
    wire [31:0] PC_Out, RegWriteData;
    
    ClkDiv u0(
        .Clk(Clk),
        .Rst(1'b0),
        .ClkOut(ClkOut)
    );
    
    Top u1(
        .Clk(ClkOut),
        .Rst(Rst),
        .PC_Out(PC_Out),
        .RegWriteData(RegWriteData)
    );
    
    Two4DigitDisplay u2(
        .Clk(Clk),
        .NumberA(PC_Out[15:0]),
        .NumberB(RegWriteData[15:0]),
        .out7(out7),
        .en_out(en_out)
    );

endmodule
