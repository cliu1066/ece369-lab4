`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - RegisterFile.v
// Description - Test the register_file
// Suggested test case - First write arbitrary values into 
// the saved and temporary registers (i.e., register 8 through 25). Then, 2-by-2, 
// read values from these registers.
////////////////////////////////////////////////////////////////////////////////


module RegisterFile_tb();

	reg [4:0] ReadRegister1;
	reg [4:0] ReadRegister2;
	reg	[4:0] WriteRegister;
	reg [31:0] WriteData;
	reg RegWrite;
	reg Clk;

	wire [31:0] ReadData1;
	wire [31:0] ReadData2;
	
	integer i;

	RegisterFile u0(
		.ReadRegister1(ReadRegister1), 
		.ReadRegister2(ReadRegister2), 
		.WriteRegister(WriteRegister), 
		.WriteData(WriteData), 
		.RegWrite(RegWrite), 
		.Clk(Clk), 
		.ReadData1(ReadData1), 
		.ReadData2(ReadData2)
	);

	initial begin
		Clk <= 1'b0;
		forever #10 Clk <= ~Clk;
	end

	initial begin
	    RegWrite <= 1'b1;
	    
	    for (i = 8; i <= 25; i = i + 1) begin
	        @(posedge Clk);
	        WriteRegister <= i[4:0];
	        WriteData <= i;
	    end
	    
	    @(posedge Clk);
	    #5;
	    RegWrite <= 1'b0;
        ReadRegister1 <= 5'd8;
        ReadRegister2 <= 5'd9;
        @(posedge Clk);
        #5;
        ReadRegister1 <= 5'd10;
        ReadRegister2 <= 5'd11;
        @(posedge Clk);
        #5;
        ReadRegister1 <= 5'd12;
        ReadRegister2 <= 5'd13;
        @(posedge Clk);
        #5;
        ReadRegister1 <= 5'd14;
        ReadRegister2 <= 5'd15;
        @(posedge Clk);
        #5;
        ReadRegister1 <= 5'd16;
        ReadRegister2 <= 5'd17;
        @(posedge Clk);
        #5;
        ReadRegister1 <= 5'd18;
        ReadRegister2 <= 5'd19;
	end

endmodule
