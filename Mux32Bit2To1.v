`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module Mux32Bit2To1(out, inA, inB, sel);

    output [31:0] out;
    
    input [31:0] inA;
    input [31:0] inB;
    input sel;

    assign out = (sel == 1'b0) ? inA : inB;

endmodule
