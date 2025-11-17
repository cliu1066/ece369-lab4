`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Controller.v
// Description - Controller module for signals in datapath.
////////////////////////////////////////////////////////////////////////////////
module Controller(OpCode, Funct, RegDst, Jump, JumpRegister, Link, Branch, MemRead, MemToReg, ALUOp, MemWrite, MemSize, ALUSrc, RegWrite, Rt);

    /* Instruction code*/
    input [5:0] OpCode, Funct;
    input [4:0] Rt;
    
    /* All output controller values */
    output reg RegDst, Jump, JumpRegister, Link, Branch, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;
    output reg [3:0] ALUOp;
    output reg [1:0] MemSize;
    
    /* Fill in the implementation here ... */
    always@(*) begin
        RegDst = 1'b0;
        ALUSrc = 1'b0;
        MemToReg = 1'b0;
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Jump = 1'b0;
        JumpRegister = 1'b0;
        Link = 1'b0;
        ALUOp = 4'b0010;
        MemSize = 2'b00;
        case (OpCode)
            // R - type
            6'b000000: begin
                case (Funct)
                    6'b001000: begin // jr
                        Jump = 1'b1;
                        JumpRegister = 1'b1;
                        ALUOp = 4'b0010;
                    end
                    
                    6'b000000: begin // nop
                        RegDst = 1'b0;
                        RegWrite = 1'b0;
                        ALUSrc = 1'b0;
                        MemToReg = 1'b0;
                        MemRead = 1'b0;
                        MemWrite = 1'b0;
                        Branch = 1'b0;
                        Jump = 1'b0;
                        JumpRegister = 1'b0;
                        Link = 1'b0;
                        ALUOp = 4'b0010;
                    end

                    default: begin
                        RegDst = 1'b1;
                        RegWrite = 1'b1;
                        case (Funct)
                            6'b100000: ALUOp = 4'b0010; // add
                            6'b100010: ALUOp = 4'b0011; // sub
                            6'b011000: ALUOp = 4'b1001; // mul
                            6'b100100: ALUOp = 4'b0000; // and
                            6'b100101: ALUOp = 4'b0001; // or
                            6'b100111: ALUOp = 4'b0101; // nor
                            6'b100110: ALUOp = 4'b0110; // xor
                            6'b000000: ALUOp = 4'b0111; // sll
                            6'b000010: ALUOp = 4'b1000; // srl
                            6'b101010: ALUOp = 4'b0100; // slt
                        endcase
                    end
                endcase
            end
            
            // Immediate 
            6'b001000 : begin // addi
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end

            6'b001100 : begin // andi
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0000;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end

            6'b001101 : begin // ori
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0001;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end

            6'b001010 : begin // slti
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0100;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end

            6'b001110 : begin // xori
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b1;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp =  4'b0110;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end
            
            // Data
            6'b100011 : begin // lw
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b1;
                RegWrite= 1'b1;
                MemRead = 1'b1;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
                MemSize = 2'b00;
            end
            
            6'b101011 : begin // sw
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b1;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
                MemSize = 2'b00;
            end
            
            6'b101000 : begin // sb
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b1;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
                MemSize = 2'b10;
            end

            6'b100001 : begin // lh
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b1;
                RegWrite= 1'b1;
                MemRead = 1'b1;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
                MemSize = 2'b01;
            end

            6'b100000 : begin // lb
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b1;
                RegWrite= 1'b1;
                MemRead = 1'b1;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
                MemSize = 2'b10;
            end

            6'b101001 : begin // sh
                RegDst = 1'b0;
                ALUSrc = 1'b1;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b1;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
                MemSize = 2'b01;
            end
            
            // Branch
            6'b000001 : begin // bgez, bltz
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b1;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
                case (Rt)
                    5'b00001 : ALUOp = 4'b1010; // bgez
                    5'b00000 : ALUOp = 4'b1111; // bltz
                    default : ALUOp = 4'b0010;
                endcase
            end
            
            6'b000100 : begin // beq
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b1;
                ALUOp = 4'b1011;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end
            
            6'b000101 : begin // bne
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b1;
                ALUOp = 4'b1100;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end

            6'b000111 : begin // bgtz
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b1;
                ALUOp =  4'b1101;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end

            6'b000110 : begin // blez
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b1;
                ALUOp = 4'b1110;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end

            6'b000010 : begin // j
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b1;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end

            6'b000011 : begin // jal
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b1;
                JumpRegister = 1'b0;
                Link = 1'b1;
            end

            default : begin 
                RegDst = 1'b0;
                ALUSrc = 1'b0;
                MemToReg= 1'b0;
                RegWrite= 1'b0;
                MemRead = 1'b0;
                MemWrite= 1'b0;
                Branch = 1'b0;
                ALUOp = 4'b0010;
                Jump = 1'b0;
                JumpRegister = 1'b0;
                Link = 1'b0;
            end
                
        endcase
    end

endmodule
