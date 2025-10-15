`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 04:31:40 PM
// Design Name: 
// Module Name: DataMemory_tb
// Project Name: 
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


module DataMemory_tb();

    reg	[31:0] Address;
    reg [31:0] WriteData;
    reg Clk;
    reg MemWrite;
    reg MemRead;
    wire [31:0]ReadData;

    DataMemory u1(
        .Address(Address), .WriteData(WriteData), .Clk(Clk), .MemWrite(MemWrite),
        .MemRead(MemRead)
    );
        
    initial begin

	   /*@(posedge Clk);
	   #5 Reset <= 1'b0; Address <= 32'h00000000;
	   @(posedge Clk);
	   #5 Address <= Address + 3;
	   @(posedge Clk);
	   #5 Address <= Address + 3;
	   @(posedge Clk);
	   #5 Address <= Address + 3;
	   @(posedge Clk);
	   #5 Reset <= 1'b1;
	   @(posedge Clk);
	   #5 Reset <= 1'b0; Address <= Address + 3;
	 end
   */

endmodule
