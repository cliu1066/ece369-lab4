`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - data_memory.v
// Description - 32-Bit wide data memory.
//
// INPUTS:-
// Address: 32-Bit address input port.
// WriteData: 32-Bit input port.
// Clk: 1-Bit Input clock signal.
// MemWrite: 1-Bit control signal for memory write.
// MemRead: 1-Bit control signal for memory read.
//
// OUTPUTS:-
// ReadData: 32-Bit registered output port.
//
// FUNCTIONALITY:-
// Design the above memory similar to the 'RegisterFile' model in the previous 
// assignment.  Create a 1K memory, for which we need 10 bits.  In order to 
// implement byte addressing, we will use bits Address[11:2] to index the 
// memory location. The 'WriteData' value is written into the address 
// corresponding to Address[11:2] in the positive clock edge if 'MemWrite' 
// signal is 1. 'ReadData' is the value of memory location Address[11:2] if 
// 'MemRead' is 1, otherwise, it is 0x00000000. The reading of memory is not 
// clocked.
//
// you need to declare a 2d array. in this case we need an array of 1024 (1K)  
// 32-bit elements for the memory.   
// for example,  to declare an array of 256 32-bit elements, declaration is: reg[31:0] memory[0:255]
// if i continue with the same declaration, we need 8 bits to index to one of 256 elements. 
// however , address port for the data memory is 32 bits. from those 32 bits, least significant 2 
// bits help us index to one of the 4 bytes within a single word. therefore we only need bits [9-2] 
// of the "Address" input to index any of the 256 words. 
////////////////////////////////////////////////////////////////////////////////

module DataMemory(Address, WriteData, Clk, MemWrite, MemRead, ReadData, MemSize); 

    input [31:0] Address; 	// Input Address 
    input [31:0] WriteData; // Data that needs to be written into the address 
    input Clk;
    input MemWrite; 		// Control signal for memory write 
    input MemRead; 			// Control signal for memory read 
    input [1:0] MemSize; // 00: word, 01: halfword, 10: byte

    output reg[31:0] ReadData; // Contents of memory location at Address

    // memory array
    reg [31:0] memory [0:1023];

    // Read data
    // Word index (use bits [11:2] for byte addressing)
    wire [9:0] word_index = Address[11:2];
    
    initial begin
        $readmemh("data_memory.mem", memory);
    end
    
    always @(*) begin
        if (MemRead) begin
            case (MemSize)
                2'b00: begin // word
                    ReadData = memory[word_index];
                end
                2'b01: begin // halfword
                    if (Address[1])
                        ReadData = {{16{memory[word_index][31]}}, memory[word_index][31:16]};
                    else
                        ReadData = {{16{memory[word_index][15]}}, memory[word_index][15:0]};
                end
                2'b10: begin // byte
                    case (Address[1:0])
                        2'b00: ReadData = {{24{memory[word_index][7]}},  memory[word_index][7:0]};
                        2'b01: ReadData = {{24{memory[word_index][15]}}, memory[word_index][15:8]};
                        2'b10: ReadData = {{24{memory[word_index][23]}}, memory[word_index][23:16]};
                        2'b11: ReadData = {{24{memory[word_index][31]}}, memory[word_index][31:24]};
                    endcase
                end
                default: ReadData = 32'b0;
            endcase
        end
        else begin
            ReadData = 32'b0;
        end
    end

    // Write data
    always @(posedge Clk) begin
        if (MemWrite) begin
            case (MemSize)
                2'b00: begin // word
                    memory[word_index] <= WriteData;
                end

                2'b01: begin // halfword
                    if (Address[1])
                        memory[word_index][31:16] <= WriteData[15:0];
                    else
                        memory[word_index][15:0]  <= WriteData[15:0];
                end

                2'b10: begin // byte
                    case (Address[1:0])
                        2'b00: memory[word_index][7:0]   <= WriteData[7:0];
                        2'b01: memory[word_index][15:8]  <= WriteData[7:0];
                        2'b10: memory[word_index][23:16] <= WriteData[7:0];
                        2'b11: memory[word_index][31:24] <= WriteData[7:0];
                    endcase
                end
            endcase
        end
    end
endmodule
