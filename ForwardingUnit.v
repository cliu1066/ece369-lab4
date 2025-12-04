module ForwardingUnit (
    input [4:0] EX_Rs,
    input [4:0] EX_Rt,

    input [4:0] MEM_WriteReg,
    input [4:0] WB_WriteReg,
    input MEM_RegWrite,
    input MEM_MemRead,
    input WB_RegWrite,

    input EX_isStore,

    input [4:0] ID_Rs,
    input [4:0] ID_Rt,
    
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB,

    output reg [1:0] ForwardBranchA,
    output reg [1:0] ForwardBranchB,
    
    output reg [1:0] ForwardStore
);

    // ALU forwarding EX stage
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

    // Store forwarding in EX
    always @(*) begin
        ForwardStore = 2'b00;  // default: use register file value

        if (EX_isStore) begin
            // store uses Rt as data
            if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == EX_Rt)
                ForwardStore = 2'b10;   // from MEM stage

            else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == EX_Rt)
                ForwardStore = 2'b01;   // from WB stage
        end
    end

    // Branch forwarding
    always @(*) begin
        ForwardBranchA = 2'b00;
        ForwardBranchB = 2'b00;
        
        // Forward from MEM stage (non-load)
        if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == ID_Rs && !MEM_MemRead) begin
            ForwardBranchA = 2'b10;
        end
        else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == ID_Rs) begin
            ForwardBranchA = 2'b01;
        end
        
        if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == ID_Rt && !MEM_MemRead) begin
            ForwardBranchB = 2'b10;
        end
        else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == ID_Rt) begin
            ForwardBranchB = 2'b01;
        end
    end

endmodule