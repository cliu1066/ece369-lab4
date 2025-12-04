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
    
    // Instruction Fetch
    ProgramCounter m1(PC_In, PC_Out, Rst, Clk, PC_Write);
    PCAdder m2(PC_Out, PC_AddResult);
    InstructionMemory m3(PC_Out, Instruction);
    
    // IF/ID - Instruction Fetch and Decode
    wire [31:0] IF_ID_PC_Out, IF_ID_Instruction_Out;
    wire IF_ID_Flush, IF_ID_FlushHazard, ID_EX_Flush, ID_EX_FlushControl;
    wire ID_EX_Jump, ID_EX_JumpRegister;

    IF_ID_Reg m5(
      .Clk(Clk),
      .Rst(Rst),
      .IF_ID_Write(IF_ID_Write),
      .IF_ID_Flush(IF_ID_Flush),
      .Instruction_In(Instruction),
      .PC_In(PC_AddResult),
      .Instruction_Out(IF_ID_Instruction_Out),
      .PC_Out(IF_ID_PC_Out)                    
    );
    
    // RegisterFile
    wire [4:0] MEM_WB_WriteRegister;
    wire [31:0] ReadData1, ReadData2;
    wire MEM_WB_RegWrite;
    
    RegisterFile m6 (
        .ReadRegister1(IF_ID_Instruction_Out[25:21]),
        .ReadRegister2(IF_ID_Instruction_Out[20:16]),
        .WriteRegister(MEM_WB_WriteRegister),
        .WriteData(RegWriteData),
        .RegWrite(MEM_WB_RegWrite),
        .Clk(Clk),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );
    
    // Sign Extend
    wire [31:0] Imm_SE;
    SignExtension m7(IF_ID_Instruction_Out[15:0], Imm_SE);

    // Jump Address (j, jal)
    // Format of jump instruction: [31:26] OpCode [25:0] Target
    wire [27:0] JumpTarget;
    assign JumpTarget = {IF_ID_Instruction_Out[25:0], 2'b00};
    // Shift address left by 2 -> multiply by 4 for word alignment
    assign JumpAddress = {IF_ID_PC_Out[31:28], JumpTarget}; // full 32 bit jump address
    // 28 bit shifted address + upper 4 PC bits = 32 bit address

    // Control
    wire RegDst, Jump, JumpRegister, Link, Branch, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0] MemSize; // 00: word, 01: halfword, 10: byte
    wire [3:0] ALUOp;
    wire [5:0] IF_ID_OpCode = IF_ID_Instruction_Out[31:26];
    wire [5:0] IF_ID_Funct = IF_ID_Instruction_Out[5:0];
    wire [4:0] IF_ID_Rt = IF_ID_Instruction_Out[20:16];

    // Controller
    Controller m8 (
        .OpCode(IF_ID_Instruction_Out[31:26]),
        .Funct (IF_ID_Instruction_Out[5:0]),
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
    
    wire ID_UsesRtAsSrc, Jump_ID;
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
    
    ID_EX_Reg m9(
        .Clk(Clk), 
        .Rst(Rst),
        .RegWrite_In(RegWrite), 
        .MemToReg_In(MemToReg),
        .Branch_In(Branch), 
        .MemRead_In(MemRead), .MemWrite_In(MemWrite), 
        .Jump_In(Jump), .JumpRegister_In(JumpRegister), 
        .Link_In(Link),
        .RegDst_In(RegDst), .ALUSrc_In(ALUSrc),
        .ALUOp_In(ALUOp), .MemSize_In(MemSize),
        
        .Jump_Addr_In(JumpAddress), .PC_In(IF_ID_PC_Out),
        .ReadData1(ReadData1), .ReadData2(ReadData2), .ImmSE_In(Imm_SE),
        .IF_ID_Rs_In(IF_ID_Instruction_Out[25:21]), 
        .IF_ID_Rt_In(IF_ID_Instruction_Out[20:16]), 
        .IF_ID_Rd_In(IF_ID_Instruction_Out[15:11]),
        .IF_ID_Funct_In(IF_ID_Instruction_Out[5:0]),
        .IF_ID_OpCode_In(IF_ID_Instruction_Out[31:26]),
        .Shamt_In(IF_ID_Instruction_Out[10:6]), 
        .ID_EX_Flush(ID_EX_FlushControl),
                     
        .RegWrite_Out(ID_EX_RegWrite),
        .MemToReg_Out(ID_EX_MemToReg),
        .Branch_Out(ID_EX_Branch),
        .MemRead_Out(ID_EX_MemRead),
        .MemWrite_Out(ID_EX_MemWrite),
        .Jump_Out(ID_EX_Jump), 
        .JumpRegister_Out(ID_EX_JumpRegister),
        .Link_Out(ID_EX_Link),
        .RegDst_Out(ID_EX_RegDst),
        .ALUSrc_Out(ID_EX_ALUSrc),
        .ALUOp_Out(ID_EX_ALUOp), .MemSize_Out(ID_EX_MemSize),
        .Jump_Addr_Out(ID_EX_Jump_Addr),
        .PC_Out(ID_EX_PC_AddResult),
        .ReadData1_Out(ID_EX_ReadData1),
        .ReadData2_Out(ID_EX_ReadData2), 
        .ImmSE_Out(ID_EX_Imm_SE),
        .IF_ID_Rs_Out(ID_EX_Rs), .IF_ID_Rt_Out(ID_EX_Rt),
        .IF_ID_Rd_Out(ID_EX_Rd),
        .IF_ID_Funct_Out(ID_EX_Funct), 
        .IF_ID_OpCode_Out(ID_EX_OpCode),
        .Shamt_Out(ID_EX_Shamt) 
    );

    // RegDst
    wire [4:0] MEM_WriteReg;
    assign MEM_WriteReg = EX_MEM_Link ? 5'd31 : EX_MEM_Rd;

    // ALUSrc
    wire [31:0] EX_ALUSrc_Out;
    wire [31:0] EX_ALU_A;

    // EX ALU
    wire EX_ALU_Zero;
    wire [31:0] EX_ALU_Result;
    wire [1:0] ForwardA, ForwardB, ForwardStore;
    wire [1:0] ForwardBranchA, ForwardBranchB;
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

    // Store data forwarding (goes to DataMemory WriteData via EX/MEM)
    assign StoreData_EX =
        (ForwardStore == 2'b00) ? ID_EX_ReadData2  :
        (ForwardStore == 2'b10) ? EX_MEM_ALU_Result:
                                  RegWriteData;
                                  
    wire [31:0] BranchA_ID, BranchB_ID;
    // Branch forwarding - from MEM (non-load) or WB stage
    assign BranchA_ID =
        (ForwardBranchA == 2'b00) ? ReadData1 :
        (ForwardBranchA == 2'b10) ? EX_MEM_ALU_Result :  // from MEM (non-load only)
                                    RegWriteData;         // from WB
        
    assign BranchB_ID =
        (ForwardBranchB == 2'b00) ? ReadData2 :
        (ForwardBranchB == 2'b10) ? EX_MEM_ALU_Result :  // from MEM (non-load only)
                                    RegWriteData;         // from WB
    
    // Branch target calculation in ID stage
    wire [31:0] ID_BranchOffset_Shifted = Imm_SE << 2;
    wire [31:0] ID_BranchTarget = IF_ID_PC_Out + ID_BranchOffset_Shifted;
                                  
    wire BEQ = (IF_ID_OpCode == 6'b000100) && (BranchA_ID == BranchB_ID);
    wire BNE = (IF_ID_OpCode == 6'b000101) && (BranchA_ID != BranchB_ID);
    wire BGTZ = (IF_ID_OpCode == 6'b000111) && ($signed(BranchA_ID) > $signed(32'b0));
    wire BLEZ = (IF_ID_OpCode == 6'b000110) && ($signed(BranchA_ID) <= $signed(32'b0));
    wire BGEZ = (IF_ID_OpCode == 6'b000001) && (IF_ID_Rt == 5'b00001) && ($signed(BranchA_ID) >= $signed(32'b0));
    wire BLTZ = (IF_ID_OpCode == 6'b000001) && (IF_ID_Rt == 5'b00000) && ($signed(BranchA_ID) < $signed(32'b0));
    
    wire BranchTaken_ID = BEQ || BNE || BGTZ || BLEZ || BGEZ || BLTZ;
    
    wire ControlFlowChange_ID;
    assign ControlFlowChange_ID = (Branch && BranchTaken_ID) || Jump || JumpRegister;
    
    assign IF_ID_Flush = IF_ID_FlushHazard || ControlFlowChange_ID;
    assign ID_EX_FlushControl = ID_EX_Flush || ControlFlowChange_ID;
    
    Mux32Bit2To1 m13(EX_ALUSrc_Out, ForwardedB_EX, ID_EX_Imm_SE, ID_EX_ALUSrc);
    
    // For SLL/SRL, use shamt as the A input (in bits [4:0]) otherwise use ReadData1
    assign EX_ALU_A = (ID_EX_ALUOp == 4'b0111 || ID_EX_ALUOp == 4'b1000) ?  // SLL or SRL
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
    
    wire [4:0] EX_Rd;
    assign EX_Rd = ID_EX_RegDst ? ID_EX_Rd : ID_EX_Rt;

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
        .BranchTarget_In(32'b0),
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
    wire [31:0] PC_Next;
    assign PC_Next = JumpRegister ? ReadData1 :     // jr uses register value
           Jump ? JumpAddress :                  // j, jal
           (Branch && BranchTaken_ID) ? ID_BranchTarget : // branch target from ID
           PC_AddResult;
           
    assign PC_In = ControlFlowChange_ID ? PC_Next : (PC_Write ? PC_AddResult : PC_Out);
    
    // Data Memory
    wire [31:0] MEM_DM_ReadData;
    DataMemory m17(EX_MEM_ALU_Result, EX_MEM_ReadData2, Clk, EX_MEM_MemWrite, EX_MEM_MemRead, MEM_DM_ReadData, EX_MEM_MemSize);
    
    // MEM/WB
    wire MEM_WB_MemToReg, MEM_WB_Link;
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
        .EX_Rs(ID_EX_Rs),
        .EX_Rt(ID_EX_Rt),
        .MEM_WriteReg(MEM_WriteReg),
        .WB_WriteReg(MEM_WB_WriteRegister),
        .MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_MemRead(EX_MEM_MemRead),
        .WB_RegWrite(MEM_WB_RegWrite),
        .EX_isStore(ID_EX_MemWrite),
        .ID_Rs(IF_ID_Instruction_Out[25:21]),
        .ID_Rt(IF_ID_Instruction_Out[20:16]),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .ForwardBranchA(ForwardBranchA),
        .ForwardBranchB(ForwardBranchB),
        .ForwardStore(ForwardStore)
    );
   
    HazardDetectionUnit m20(
        // EX stage
        .EX_MemRead(ID_EX_MemRead),
        .EX_RegWrite(ID_EX_RegWrite),
        .EX_Rd(EX_Rd),

        // MEM stage
        .MEM_MemRead(EX_MEM_MemRead),
        .MEM_Rd(MEM_WriteReg),
        .WB_Rd(MEM_WB_WriteRegister),

        // ID stage sources
        .ID_Rs(IF_ID_Instruction_Out[25:21]),
        .ID_Rt(IF_ID_Instruction_Out[20:16]),
        .ID_UsesRtAsSrc(ID_UsesRtAsSrc),

        .Branch_ID(Branch),
        .Jump_ID(Jump_ID),

        // Outputs
        .PC_Write(PC_Write),
        .IF_ID_Write(IF_ID_Write),
        .ID_EX_Flush(ID_EX_Flush),
        .IF_ID_Flush(IF_ID_FlushHazard)
    );

    // WB Mux and WriteRegister Override for jal
    // If jal, WriteRegister = $ra (register 31)
    assign MEM_WB_WriteRegister = MEM_WB_Link ? 5'd31 : MEM_WB_Rd;
    assign RegWriteData = MEM_WB_RegWrite ? 
                      (MEM_WB_Link ? MEM_WB_PC_AddResult :
                       MEM_WB_MemToReg ? MEM_WB_DM_ReadData :
                       MEM_WB_ALU_Result) :
                      32'b0;

endmodule