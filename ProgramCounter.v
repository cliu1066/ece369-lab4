`timescale 1ns / 1ps

module ProgramCounter(Address, PCResult, Reset, Clk, PCWrite);

	input [31:0] Address;
	input Reset, Clk, PCWrite;
	
	output reg [31:0] PCResult;

    always @(posedge Clk) begin
        if (Reset) begin
            PCResult <= 32'd0;
        end
        else if (PCWrite) begin
            PCResult <= Address;
        end
    end

endmodule