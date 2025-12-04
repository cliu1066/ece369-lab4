module ForwardingUnit (
    // EX stage register sources
    input [4:0] EX_Rs,
    input [4:0] EX_Rt,

    // Destination registers from later pipeline stages
    input [4:0] MEM_WriteReg,
    input [4:0] WB_WriteReg,
    input MEM_RegWrite,
    input MEM_MemRead,
    input WB_RegWrite,

    // For store data forwarding
    input EX_isStore,

    // For branch forwarding (from ID stage)
    input [4:0] ID_Rs,
    input [4:0] ID_Rt,

    // ALU forwarding outputs
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB,

    // Branch comparator forwarding (ID stage)
    output reg [1:0] ForwardBranchA,
    output reg [1:0] ForwardBranchB,
    
    // Store forwarding
    output reg [1:0] ForwardStore
);

    //ALU forwarding EX stage
    always @(*) begin
        // default: no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;
    
        // For EX_Rs
        if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == EX_Rs)
            ForwardA = 2'b10;              // from MEM
        else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == EX_Rs)
            ForwardA = 2'b01;              // from WB
    
        // For EX_Rt
        if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == EX_Rt)
            ForwardB = 2'b10;
        else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == EX_Rt)
            ForwardB = 2'b01;
    end

    //Store forwarding in EX
    always @(*) begin
        ForwardStore = 2'b00;  // default: use register file value

        if (EX_isStore) begin
            // store uses rt as data
            if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == EX_Rt)
                ForwardStore = 2'b10;   // from MEM stage

            else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == EX_Rt)
                ForwardStore = 2'b01;   // from WB stage
        end
    end

    //branch forwarding
    always @(*) begin
        ForwardBranchA = 2'b00;
        ForwardBranchB = 2'b00;
        
        // For ID_Rs
        if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == ID_Rs) begin
            if (MEM_MemRead)
                ForwardBranchA = 2'b11;  // NEW: forward from MEM data memory
            else
                ForwardBranchA = 2'b10;  // forward from MEM ALU
        end
        else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == ID_Rs)
            ForwardBranchA = 2'b01;
        
        // For ID_Rt
        if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == ID_Rt) begin
            if (MEM_MemRead)
                ForwardBranchB = 2'b11;  // NEW: forward from MEM data memory
            else
                ForwardBranchB = 2'b10;  // forward from MEM ALU
        end
        else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == ID_Rt)
            ForwardBranchB = 2'b01;
    end

endmodule