`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALUControl.v
// Description - ALU control module mapping 2 bit ALUOp and 6 bit funct to 4 bit 
//               ALUControl.
////////////////////////////////////////////////////////////////////////////////

module ALUControl(ALUOp, Funct, ALUControl);
    input [1:0] ALUOp;
    input [5:0] Funct;
    output reg [3:0] ALUControl;
    
    always @(*) begin
        case (ALUOp)
            2'b00: // lw/sw ALUControl is ADD
                ALUControl = 4'b0010;
            2'b01: // beq ALUControl is SUB
                ALUControl = 4'b0110;
            2'b10: begin // R-type
                case (Funct)
                    6'b100100: ALUControl = 4'b0000; // AND
                    6'b100101: ALUControl = 4'b0001; // OR
                    6'b100000: ALUControl = 4'b0010; // ADD
                    6'b100010: ALUControl = 4'b0110; // SUB
                    6'b101010: ALUControl = 4'b0111; // SLT
                    6'b100111: ALUControl = 4'b1100; // NOR
                    6'b100110: ALUControl = 4'b0011; // XOR
                    6'b000000: ALUControl = 4'b1000; // SLL
                    6'b000010: ALUControl = 4'b1001; // SRL
                    6'b000011: ALUControl = 4'b1010; // SRA
                    6'b011000: ALUControl = 4'b1011; // MUL
                    default: ALUControl = 4'bxxxx;
                endcase
            end
        endcase
    end
    
endmodule
