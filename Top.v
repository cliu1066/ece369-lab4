`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
//
// Student(s) Name and Last Name: 
//      Candice Liu (33%), Andrew Ghartey (33%), Barack Marwanga Asande (33%)
// 
// Module - Top.v
// Description - Top level datapath module for MIPS 5 stage pipeline
//
////////////////////////////////////////////////////////////////////////////////

module Top(Clk, Rst, PC_Out, RegWriteData);
    input Clk, Rst;
    output wire [31:0] PC_Out;
    output wire [31:0] RegWriteData;
    
    wire [31:0] PC_In, PC_AddResult;
    wire [31:0] Instruction;
    wire [31:0] JumpAddress;
    
    wire PC_Write, IF_ID_Write;
    wire ID_EX_Flush, IF_ID_Flush;
    
    wire [1:0] ForwardA, ForwardB, ForwardStore;
    wire [1:0] ForwardBranchA, ForwardBranchB;
    
    wire ID_UsesRtAsSrc, Jump_ID, ForwardingEnabled;
    assign ForwardingEnabled = 1'b1;
    
    wire [4:0] EX_Rd;
    wire [4:0] MEM_WriteReg;
    
    // Instruction Fetch
    // ProgramCounter: input PC_In, output PC_Out if not Rst and at posedge Clk
    ProgramCounter m1(PC_In, PC_Out, Rst, Clk, PC_Write);
    // PCAdder: PC_AddResult = PC_Oout + 4
    PCAdder m2(PC_Out, PC_AddResult);
    // InustructionMemory: PC_Out is the index into the instruction memory array
    // and gives the instruction (array initialized by readmemh instruction_memory.mem)
    InstructionMemory m3(PC_Out, Instruction);
    
    // IF/ID - Instruction Fetch and Decode
    wire [31:0] IF_ID_PC_Out, IF_ID_Instruction_Out;
    // For all pipeline register modules, they take in the input control signals and reset
    // all to 0 when Rst is high, else they retain the values since no forwarding
    
    wire ID_EX_Jump, ID_EX_JumpRegister, BranchTaken_EX;
    wire Flush_EX = BranchTaken_EX || Jump || JumpRegister;
    
    wire IF_ID_Flush_Final = Flush_EX | IF_ID_Flush;

    IF_ID_Reg m5(
      .Clk(Clk),
      .Rst(Rst),
      .IF_ID_Write(IF_ID_Write),
      .IF_ID_Flush(IF_ID_Flush_Final),
      .Instruction_In(Instruction),
      .PC_In(PC_AddResult),
      .Instruction_Out(IF_ID_Instruction_Out),
      .PC_Out(IF_ID_PC_Out)                    
    );

    
    // RegisterFile
    wire RegWrite;
    wire [4:0] MEM_WB_WriteRegister;
    wire [31:0] ReadData1, ReadData2;
    wire MEM_WB_RegWrite, MEM_WB_MemToReg, MEM_WB_Link;
    
    // RegisterFile initialized with all 0s
    // Write at posedge Clk when RegWrite is high and read at negedge Clk
    // Ensures register $zero is always 0
    RegisterFile m6 (
        .ReadRegister1(IF_ID_Instruction_Out[25:21]),
        .ReadRegister2(IF_ID_Instruction_Out[20:16]),
        .WriteRegister(MEM_WB_WriteRegister),          // 5-bit
        .WriteData(RegWriteData),
        .RegWrite(MEM_WB_RegWrite),
        .Clk(Clk),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );
    
    // Sign Extend
    wire [31:0] Imm_SE;
    // SignExtension, concatenates 16 copies of sign bit with 16 bit input
    SignExtension m7(IF_ID_Instruction_Out[15:0], Imm_SE);

    // Jump Address (j, jal)
    // Format of jump instruction: [31:26] OpCode [25:0] Target
    wire [27:0] JumpTarget;
    assign JumpTarget = {IF_ID_Instruction_Out[25:0], 2'b00}; // shift left 2
    // Shift address left by 2 -> multiply by 4 for word alignment
    assign JumpAddress = {IF_ID_PC_Out[31:28], JumpTarget}; // full 32 bit jump address
    // 28 bit shifted address + upper 4 PC bits = 32 bit address

    // Control
    wire RegDst, Jump, JumpRegister, Link, Branch, MemRead, MemToReg, MemWrite, ALUSrc;
    wire [1:0] MemSize; // 00: word, 01: halfword, 10: byte
    wire [3:0] ALUOp;

    // Controller: input OpCode, Funct, Rt, outputs control signals
    Controller m8 (
        .OpCode(IF_ID_Instruction_Out[31:26]),
        .Funct (IF_ID_Instruction_Out[5:0]),    // for differentiating R-type, nop, jr
        .RegDst(RegDst),
        .Jump(Jump),
        .JumpRegister(JumpRegister),    // jr
        .Link(Link),                    // jal
        .Branch(Branch),
        .MemRead(MemRead),
        .MemToReg(MemToReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .MemSize(MemSize),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Rt(IF_ID_Instruction_Out[20:16])    // for differentiating bgez and bltz
    );
    
    assign ID_UsesRtAsSrc = Branch || MemWrite || (IF_ID_Instruction_Out[31:26] == 6'b000000);
    assign Jump_ID = Jump | JumpRegister;

    // ID/EX
    wire ID_EX_RegDst, ID_EX_Link, ID_EX_Branch, ID_EX_MemRead, ID_EX_MemToReg, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite;
    wire [3:0] ID_EX_ALUOp;
    wire [1:0] ID_EX_MemSize;
    wire [31:0] ID_EX_Jump_Addr;
    wire [31:0] ID_EX_PC_AddResult;
    wire [31:0] ID_EX_ReadData1, ID_EX_ReadData2;
    wire [31:0] ID_EX_Imm_SE;
    wire [4:0] ID_EX_Rs, ID_EX_Rt, ID_EX_Rd;
    wire [5:0] ID_EX_Funct, ID_EX_OpCode;
    wire [4:0] ID_EX_Shamt;
    
    ID_EX_Reg m9(Clk, Rst,
        RegWrite, MemToReg,
        Branch, MemRead, MemWrite, Jump, JumpRegister, Link,
        RegDst, ALUSrc,
        ALUOp, MemSize,
        
        JumpAddress, IF_ID_PC_Out,
        ReadData1, ReadData2, Imm_SE,
        IF_ID_Instruction_Out[25:21], IF_ID_Instruction_Out[20:16], IF_ID_Instruction_Out[15:11],
        IF_ID_Instruction_Out[5:0], IF_ID_Instruction_Out[31:26],
        IF_ID_Instruction_Out[10:6], 
        ID_EX_Flush,
                     
        ID_EX_RegWrite, ID_EX_MemToReg,
        ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_Jump, ID_EX_JumpRegister, ID_EX_Link,
        ID_EX_RegDst, ID_EX_ALUSrc,
        ID_EX_ALUOp, ID_EX_MemSize,
        ID_EX_Jump_Addr, ID_EX_PC_AddResult,
        ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_Imm_SE,
        ID_EX_Rs, ID_EX_Rt, ID_EX_Rd,
        ID_EX_Funct, ID_EX_OpCode,
        ID_EX_Shamt 
    );

    
    // RegDst Mux
    assign MEM_WriteReg = EX_MEM_Link ? 5'd31 : EX_MEM_Rd;

    // Shift left 2
    wire [31:0] SLL_Out;
    //ALU32Bit m11(4'b0111, 32'd2, ID_EX_Imm_SE , SLL_Out, 1'b0);
    assign SLL_Out = ID_EX_Imm_SE << 2;

    // Branch Target Adder
    wire [31:0] Add_Result;
    wire DummyZero;
    // Branch target address = shift left 2 output + (PC + 4)
    ALU32Bit m12(4'b0010, ID_EX_PC_AddResult, SLL_Out, Add_Result, DummyZero);

    // ALUSrc Mux
    wire [31:0] EX_ALUSrc_Out;
    wire [31:0] EX_ALU_A;

    // EX ALU
    wire EX_ALU_Zero;
    wire [31:0] EX_ALU_Result;
    wire [31:0] ForwardedA_EX, ForwardedB_EX, StoreData_EX;
    
    // Forwarded A (to ALU / branch)
    assign ForwardedA_EX =
        (ForwardA == 2'b00) ? ID_EX_ReadData1      :
        (ForwardA == 2'b10) ? EX_MEM_ALU_Result    :   // from MEM
                              RegWriteData;             // from WB

    // Forwarded B (to ALU second source)
    assign ForwardedB_EX =
        (ForwardB == 2'b00) ? ID_EX_ReadData2      :
        (ForwardB == 2'b10) ? EX_MEM_ALU_Result    :
                              RegWriteData;

    // Store data forwarding (goes to DataMemory write data via EX/MEM)
    assign StoreData_EX =
        (ForwardStore == 2'b00) ? ID_EX_ReadData2  :
        (ForwardStore == 2'b10) ? EX_MEM_ALU_Result:
                                  RegWriteData;
                                  
    Mux32Bit2To1 m13(EX_ALUSrc_Out, ForwardedB_EX, ID_EX_Imm_SE, ID_EX_ALUSrc);
    
    // For SLL/SRL, use shamt as the A input (in bits [4:0]) otherwise use ReadData1
    assign EX_ALU_A = (ID_EX_ALUOp == 4'b0111 || ID_EX_ALUOp == 4'b1000) ?  // SLL or SRL // *** ADDED ***
                      {27'd0, ID_EX_Shamt} :                               
                      ForwardedA_EX;                                     
                      
    ALU32Bit m14(ID_EX_ALUOp, EX_ALU_A, EX_ALUSrc_Out, EX_ALU_Result, EX_ALU_Zero);

    // EX/MEM
    wire [31:0] EX_MEM_BranchAddr;
    wire EX_MEM_Jump, EX_MEM_JumpRegister, EX_MEM_Branch;
    wire EX_MEM_Link, EX_MEM_MemRead, EX_MEM_MemToReg, EX_MEM_MemWrite, EX_MEM_RegWrite;
    wire EX_MEM_ALUZero;
    wire [1:0] EX_MEM_MemSize;
    wire [31:0] EX_MEM_Jump_Addr, EX_MEM_PC_AddResult;
    wire [31:0] EX_MEM_ALU_Result;
    wire [31:0] EX_MEM_ReadData2;
    wire [31:0] EX_MEM_BranchTarget;
    wire [4:0] EX_MEM_Rd;

    EX_MEM_Reg m15 (
        .Clk(Clk),
        .Rst(Rst),
        .RegWrite_In(ID_EX_RegWrite),
        .MemToReg_In(ID_EX_MemToReg),
        .Branch_In(ID_EX_Branch),
        .MemRead_In(ID_EX_MemRead),
        .MemWrite_In(ID_EX_MemWrite),
        .Jump_In(ID_EX_Jump),
        .JumpRegister_In(ID_EX_JumpRegister),
        .Link_In(ID_EX_Link),
        .RegDst_In(ID_EX_RegDst),
        .MemSize_In(ID_EX_MemSize),
        .JumpAddr_In(ID_EX_Jump_Addr),
        .BranchAddr_In(ID_EX_PC_AddResult),
        .ALUZero_In(EX_ALU_Zero),
        .ALUResult_In(EX_ALU_Result),
        .ReadData2_In(StoreData_EX),
        .BranchTarget_In(Add_Result),
        .WriteReg_In(EX_Rd),
        
        .RegWrite_Out(EX_MEM_RegWrite),
        .MemToReg_Out(EX_MEM_MemToReg),
        .Branch_Out(EX_MEM_Branch),
        .MemRead_Out(EX_MEM_MemRead),
        .MemWrite_Out(EX_MEM_MemWrite),
        .Jump_Out(EX_MEM_Jump),
        .JumpRegister_Out(EX_MEM_JumpRegister),
        .Link_Out(EX_MEM_Link),
        .MemSize_Out(EX_MEM_MemSize),
        .JumpAddr_Out(EX_MEM_Jump_Addr),
        .BranchAddr_Out(EX_MEM_BranchAddr),
        .ALUZero_Out(EX_MEM_ALUZero),
        .ALUResult_Out(EX_MEM_ALU_Result),
        .ReadData2_Out(EX_MEM_ReadData2),
        .BranchTarget_Out(EX_MEM_BranchTarget),
        .EX_MEM_Rd_Out(EX_MEM_Rd)
    );

    // PCSrc Mux
    // Current Datapath: ALUZero && Branch -> mux sel signal
    // Modified: Check BranchALUResult since branch comparisons implemented in ALU
    // Then check if j, select JumpAddr for PC value
    // Finally check if jr, select ReadData2 for PC
    wire [31:0] BranchTarget;
    wire BEQ_taken = (ID_EX_OpCode == 6'b000100) && EX_ALU_Zero;
    wire BNE_taken = (ID_EX_OpCode == 6'b000101) && !EX_ALU_Zero;
    wire OTHER_taken = ((ID_EX_OpCode == 6'b000001) ||
                        (ID_EX_OpCode == 6'b000110) ||
                        (ID_EX_OpCode == 6'b000111)) &&
                        (EX_ALU_Result == 32'd1);
    
    assign BranchTaken_EX = BEQ_taken || BNE_taken || OTHER_taken;
    
    assign BranchTarget = EX_MEM_BranchTarget;
    
    wire [31:0] PC_Next;
    assign PC_Next = ID_EX_JumpRegister ? EX_ALU_Result :     // jr
               ID_EX_Jump ? ID_EX_Jump_Addr :   // j, jal
               (ID_EX_Branch && BranchTaken_EX) ? Add_Result : // branch target
               PC_AddResult;
    assign PC_In = PC_Write ? PC_Next : PC_Out;

    /*wire [1:0] PCSrc;
    assign PCSrc = EX_MEM_JumpRegister ? 2'b10 :
                   EX_MEM_Jump         ? 2'b01 :
                                         2'b00;
    Mux32Bit3To1 m21(PC_In, PC_AddResult, EX_MEM_Jump_Addr, EX_MEM_ReadData2, PCSrc);*/
    
    // Branch
    //ALU32Bit m16(4'b0000, EX_MEM_Branch, EX_MEM_ALU_Result[0], PCSrc, 1'b0);
    
    // Data Memory
    // Data memory array initialized with $readmemh("data_memory.mem")
    // Need 10 bit address to index into 1024 memory elements
    // lh: sign-extends bit 15 to 32 bits, lb: selects byte based on offset and sign extends to 32 bits
    // Writes only happen on posedge Clk and only write in number of bits requested (otehr bytes unchanged)
    wire [31:0] MEM_DM_ReadData;
    DataMemory m17(EX_MEM_ALU_Result, EX_MEM_ReadData2, Clk, EX_MEM_MemWrite, EX_MEM_MemRead, MEM_DM_ReadData, EX_MEM_MemSize);
    
    // MEM/WB
    wire [31:0] MEM_WB_DM_ReadData, MEM_WB_ALU_Result, MEM_WB_PC_AddResult;
    wire [4:0] MEM_WB_Rd;
    wire [1:0] MEM_WB_MemSize;
    
    MEM_WB_Reg m18 (
        .Clk(Clk),
        .Rst(Rst),
        .RegWrite_In(EX_MEM_RegWrite),
        .MemToReg_In(EX_MEM_MemToReg),
        .Link_In(EX_MEM_Link),
        .DM_ReadData_In(MEM_DM_ReadData),
        .ALU_Result_In(EX_MEM_ALU_Result),
        .PC_AddResult_In(EX_MEM_BranchAddr),
        .EX_MEM_Rd_In(EX_MEM_Rd),
        .MemSize_In(EX_MEM_MemSize),
        
        .RegWrite_Out(MEM_WB_RegWrite),
        .MemToReg_Out(MEM_WB_MemToReg),
        .Link_Out(MEM_WB_Link),
        .DM_ReadData_Out(MEM_WB_DM_ReadData),
        .MEM_WB_ALU_Result(MEM_WB_ALU_Result),
        .PC_AddResult_Out(MEM_WB_PC_AddResult),
        .MEM_WB_Rd(MEM_WB_Rd),
        .MemSize_Out(MEM_WB_MemSize)
    );
    
    ForwardingUnit m19(
        .EX_rs(ID_EX_Rs),
        .EX_rt(ID_EX_Rt),
        .MEM_WriteReg(MEM_WriteReg),
        .WB_WriteReg(MEM_WB_WriteRegister),
        .MEM_RegWrite(EX_MEM_RegWrite),
        .WB_RegWrite(MEM_WB_RegWrite),
        .EX_isStore(ID_EX_MemWrite),
        .ID_rs(IF_ID_Instruction_Out[25:21]),
        .ID_rt(IF_ID_Instruction_Out[20:16]),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .ForwardBranchA(ForwardBranchA),
        .ForwardBranchB(ForwardBranchB),
        .ForwardStore(ForwardStore)
    );
    wire [4:0] EX_Rd;
    assign EX_Rd = ID_EX_RegDst ? ID_EX_Rd : ID_EX_Rt;
    HazardDetectionUnit m20(
        .clk(Clk),
        .reset(Rst),

        // EX stage
        .EX_MemRead(ID_EX_MemRead),
        .EX_RegWrite(ID_EX_RegWrite),
        .EX_rd(EX_Rd),

        // MEM stage
        .MEM_MemRead(EX_MEM_MemRead),
        .MEM_rd(MEM_WriteReg),            // actual write reg (handles jal)
        .WB_rd(MEM_WB_WriteRegister),

        // ID stage sources
        .ID_rs(IF_ID_Instruction_Out[25:21]),
        .ID_rt(IF_ID_Instruction_Out[20:16]),
        .ID_UsesRtAsSrc(ID_UsesRtAsSrc),

        .Branch_ID(Branch),
        .Jump_ID(Jump_ID),
        .BranchTaken_EX(BranchTaken_EX),

        .Forwarding_Enabled(Forwarding_Enabled),

        // Outputs
        .PC_Write(PC_Write),
        .IF_ID_Write(IF_ID_Write),
        .ID_EX_Flush(ID_EX_Flush),
        .IF_ID_Flush(IF_ID_Flush)
    );


    // WB Mux and WriteRegister Override for jal
    // If jal, WriteRegister = $ra (register 31)
    assign MEM_WB_WriteRegister = MEM_WB_Link ? 5'd31 : MEM_WB_Rd;
    // If jal, RegWriteData = PC + 4, if lw/mem: RegWriteData = ReadData, else R-Type/Imm: ALU_Result
    assign RegWriteData = MEM_WB_Link ? MEM_WB_PC_AddResult :
                          MEM_WB_MemToReg ? MEM_WB_DM_ReadData :
                          MEM_WB_ALU_Result;

endmodule