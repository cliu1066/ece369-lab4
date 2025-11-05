`timescale 1ns / 1ps

module InstructionMemory(Address, Instruction); 

    input [31:0] Address;        // Input Address 
    output [31:0] Instruction;    // Instruction at memory location Address
    
    reg [31:0] memory [0:1023];
    
    initial begin
        $readmemh("instruction_memory.mem", memory);
    end
    
    assign Instruction = memory[Address[11:2]]; // need 10 bits to index into 1024 instructions
    
endmodule
