`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Candice Liu
// 
// Create Date: 10/13/2025 03:43:10 PM
// Design Name: 
// Module Name: Mux32Bit2To1_tb
// Project Name: ECE369 Lab 3 Datapath
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


module Mux32Bit2To1_tb();
    reg [31:0] inA, inB;
    reg sel;
    
    wire [31:0] out;
    
    Mux32Bit2To1 u0(
        .out(out), 
        .inA(inA), 
        .inB(inB), 
        .sel(sel)
    );
    
    initial begin
        inA <= 32'h00000000;
        inB <= 32'h00000001;
        sel <= 1'b0;
        #5;
        sel <= 1'b1;
        #5;
        inA <= 32'h00000010;
        sel <= 1'b0;
        #5;
        inB <= 32'h00000011;
        sel <= 1'b1;
        #5;
    end
    
endmodule
