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
        .Address(Address),
        .WriteData(WriteData),
        .Clk(Clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ReadData(ReadData)

    );
    
	initial begin
        // Initialize inputs
        Address = 32'h00000000;
        WriteData = 32'h00000000;
        MemWrite = 0;
        MemRead = 0;

        // Wait for global reset
        #10;

        // Write 0xDEADBEEF to address 0x00000004 (word index = 1)
        Address = 32'h00000004;
        WriteData = 32'hDEADBEEF;
        MemWrite = 1;
        MemRead = 0;
        #10;

        // Disable write
        MemWrite = 0;

        // Read from address 0x00000004
        MemRead = 1;
        #10;

		// Display result
        $display("ReadData from address 0x00000004: %h", ReadData);

        // Read from address 0x00000008 (should be 0)
        Address = 32'h00000008;
        #10;
        $display("ReadData from address 0x00000008: %h", ReadData);

        // Finish simulation
        $finish;
    end

endmodule


