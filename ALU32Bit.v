`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit.v
// Description - 32-Bit wide arithmetic logic unit (ALU).
//
// INPUTS:-
// ALUControl: N-Bit input control bits to select an ALU operation.
// A: 32-Bit input port A.
// B: 32-Bit input port B.
//
// OUTPUTS:-
// ALUResult: 32-Bit ALU result output.
// ZERO: 1-Bit output flag. 
//
// FUNCTIONALITY:-
// Design a 32-Bit ALU, so that it supports all arithmetic operations 
// needed by the MIPS instructions given in Labs5-8.docx document. 
//   The 'ALUResult' will output the corresponding result of the operation 
//   based on the 32-Bit inputs, 'A', and 'B'. 
//   The 'Zero' flag is high when 'ALUResult' is '0'. 
//   The 'ALUControl' signal should determine the function of the ALU 
//   You need to determine the bitwidth of the ALUControl signal based on the number of 
//   operations needed to support. 
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit(ALUControl, A, B, ALUResult, Zero);

	input [3:0] ALUControl; // control bits for ALU operation
                                // you need to adjust the bitwidth as needed
	input [31:0] A, B;	    // inputs

	output reg [31:0] ALUResult;	// answer - added reg here
	output Zero;	    // Zero=1 if ALUResult == 0

    /* Please fill in the implementation here... */
    always @(*) begin
        case (ALUControl)
        // 4 to reprsent 4 bits in 'b' binary and the numbers are the control signals code        
            4'b0000: ALUResult = A & B;             // AND
            4'b0001: ALUResult = A | B;             // OR
            4'b0010: ALUResult = A + B;             // ADD
            4'b0110: ALUResult = A - B;             // SUB
            4'b0111: ALUResult = (A < B) ? 32'd1 : 32'd0; // SLT
            4'b1100: ALUResult = ~(A | B);          // NOR
            4'b0011: ALUResult = A ^ B;             // XOR (optional)
            4'b1000: ALUResult = B << A[4:0];       // SLL (shift left logical)
            4'b1001: ALUResult = B >> A[4:0];       // SRL (shift right logical)
            4'b1010: ALUResult = $signed(B) >>> A[4:0]; // SRA (arithmetic shift right)
            default: ALUResult = 32'd0;             // Default
        endcase
    end

    assign Zero = (ALUResult == 32'd0) ? 1'b1 : 1'b0;
            
endmodule

