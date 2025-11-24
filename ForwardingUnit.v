module ForwardingUnit (
    // EX stage register sources
    input  [4:0] EX_rs,
    input  [4:0] EX_rt,

    // Destination registers from later pipeline stages
    input  [4:0] MEM_WriteReg,
    input  [4:0] WB_WriteReg,
    input        MEM_RegWrite,
    input        WB_RegWrite,

    // For store data forwarding
    input        EX_isStore,

    // For branch forwarding (from ID stage)
    input  [4:0] ID_rs,
    input  [4:0] ID_rt,

    // ALU forwarding outputs
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB,

    // Branch comparator forwarding (ID stage)
    output reg [1:0] ForwardBranchA,
    output reg [1:0] ForwardBranchB,
    
    // Store forwarding
    output reg [1:0] ForwardStore
);

    // ---------------------------
    // ALU FORWARDING (EX stage)
    // ---------------------------
    always @(*) begin
    // default: no forwarding
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    // For EX_rs
    if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == EX_rs)
        ForwardA = 2'b10;              // from MEM
    else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == EX_rs)
        ForwardA = 2'b01;              // from WB

    // For EX_rt
    if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == EX_rt)
        ForwardB = 2'b10;
    else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == EX_rt)
        ForwardB = 2'b01;
    end

   

    // ---------------------------
    // STORE FORWARDING (EX stage)
    // ---------------------------
    always @(*) begin
        ForwardStore = 2'b00;  // default: use register file value

        if (EX_isStore) begin
            // store uses rt as data
            if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == EX_rt)
                ForwardStore = 2'b10;   // from MEM stage

            else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == EX_rt)
                ForwardStore = 2'b01;   // from WB stage
        end
    end

    // ---------------------------
    // BRANCH FORWARDING (ID stage)
    // ---------------------------
    always @(*) begin
        ForwardBranchA = 2'b00;
        ForwardBranchB = 2'b00;

        // Compare ID_rs, ID_rt with MEM and WB
        if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == ID_rs)
            ForwardBranchA = 2'b10;
        else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == ID_rs)
            ForwardBranchA = 2'b01;

        if (MEM_RegWrite && MEM_WriteReg != 0 && MEM_WriteReg == ID_rt)
            ForwardBranchB = 2'b10;
        else if (WB_RegWrite && WB_WriteReg != 0 && WB_WriteReg == ID_rt)
            ForwardBranchB = 2'b01;
    end

endmodule
