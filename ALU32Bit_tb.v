`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit_tb.v
// Description - Test the 'ALU32Bit.v' module.
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit_tb(); 

	reg [3:0] ALUControl;   // control bits for ALU operation
	reg [31:0] A, B;	        // inputs

	wire [31:0] ALUResult;	// answer
	wire Zero;	        // Zero=1 if ALUResult == 0

    ALU32Bit u0(
        .ALUControl(ALUControl), 
        .A(A), 
        .B(B), 
        .ALUResult(ALUResult), 
        .Zero(Zero)
    );

	initial begin
	
    /* Please fill in the implementation here... */
    // Initializing values
    A = 32'h00000010;   // 16
    B = 32'h00000004;   // 4
    
    // Testing AND (0000)
    ALUControl = 4'b0000;
    #10;
        
    // Testing OR (0001)
    ALUControl = 4'b0001;   // OR
    #10;
    
    // Testing ADD (0010)
    ALUControl = 4'b0010;   // ADD
    #10;
    
    // Testing SUB (0110)
    ALUControl = 4'b0110;   // SUB
    #10;
    
    // Testing SLT (0111)
    ALUControl = 4'b0111;   // Set Less Than
    A = 32'h00000004;
    B = 32'h00000010;
    #10;
    
    // Testing NOR (1100)
    ALUControl = 4'b1100;   // NOR
    A = 32'h0000000F;
    B = 32'h000000F0;
    #10;
    
    // Testing  XOR (0011)
    ALUControl = 4'b0011;   // XOR
    A = 32'hF0F0F0F0;
    B = 32'h0F0F0F0F;
    #10;

    // Testing SLL (1000)
    ALUControl = 4'b1000;   // Shift Left Logical
    A = 32'h00000004;       // shift amount = 4
    B = 32'h00000010;       // 0x10 << 4 = 0x100
    #10;

    // Testing SRL (1001)
    ALUControl = 4'b1001;   // Shift Right Logical
    A = 32'h00000002;       // shift amount = 2
    B = 32'h00000040;       // 0x40 >> 2 = 0x10
    #10;

    // Testing SRA (1010)
    ALUControl = 4'b1010;   // Shift Right Arithmetic
    A = 32'h00000002;
    B = 32'hFFFFFFF0;       // -16 (arithmetic right shift)
    #10;

    // Test 11: ZERO flag check
    ALUControl = 4'b0110;   // SUB
    A = 32'h00000005;
    B = 32'h00000005;       // Result should be 0 ? Zero = 1
    #10; // Implementing a time delay for the ALU to settle
	
	end
endmodule

