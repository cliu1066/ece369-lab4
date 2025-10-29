`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Controller.v
// Description - Controller module for signals in datapath.
////////////////////////////////////////////////////////////////////////////////
module Controller(OpCode, RegDst, Jump, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite, rt);

    /* Instruction code*/
    input [5:0] OpCode;
    input [4:0] rt;
    
    /* All output controller values */
    output reg RegDst, Jump, Branch, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;
    output reg [1:0] ALUOp;
    
    /* Fill in the implementation here ... */
    always@(*) begin
        case (OpCode)
            6'b000000 : begin // R - type
                RegDst = 1'b1;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b10;
                Jump = 1'b0;
            end
            6'b100011 : begin // lw - load word
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b1;
                RegWrite= 1'b1;
                MemRead = 1'b1;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            6'b101011 : begin // sw - store word
                RegDst = 1'bx;
                ALUSrc = 1'b1;
                MemToReg= 1'bx;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b1;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end
            6'b000101 : begin // bne - branch if not equal
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b1;
                ALUOp = 2'b01;
                Jump = 1'b0;
            end

            6'b000100 : begin // beq
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b1;
                ALUOp = 2'b01;
                Jump = 1'b0;
            end
            
            6'b000001 : begin // bgez, bltz
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b1;
                ALUOp = 2'b01;
                Jump = 1'b0;
            end
            
            6'b001110 : begin // XORI - XOR immidiate
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b11;
                Jump = 1'b0;
            end
            6'b000010 : begin // j - Jump
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b1;
            end
            
            6'b001000 : begin // addi
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end

            6'b001100 : begin // andi
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end

            6'b001101 : begin // ori
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end

            6'b001010 : begin // slti
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end

            6'b001110 : begin // xori
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b10;
                Jump = 1'b0;
            end

            6'b101000 : begin // sb
                RegDst = 1'bx;
                ALUSrc = 1'b1;
                MemToReg= 1'bx;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b1;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end

            6'b100001 : begin // lh
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b1;
                RegWrite= 1'b1;
                MemRead = 1'b1;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end

            6'b100000 : begin // lb
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b1;
                RegWrite= 1'b1;
                MemRead = 1'b1;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end

            6'b101001 : begin // sh
                RegDst = 1'bx;
                ALUSrc = 1'b1;
                MemToReg= 1'bx;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b1;
                Branch = 1'b0;
                ALUOp = 2'b00;
                Jump = 1'b0;
            end

            default : begin 
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 2'b10;
                Jump = 1'b0;
            end
                
        endcase
    end

endmodule
