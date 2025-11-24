// HazardDetectionUnit.v
// Handles: load-use stalls (including stores), optional ALU-ALU stalls when forwarding disabled,
// branch-related stalls, and branch/jump flushes.

module HazardDetectionUnit (
    input  wire        clk,
    input  wire        reset,             // not strictly required, kept for clarity

    // Pipeline signals (from pipeline registers / control)
    input  wire        EX_MemRead,        // EX stage is a load
    input  wire        EX_RegWrite,       // EX stage will write a register
    input  wire [4:0]  EX_rd,             // EX stage destination register (rt for load, rd for R-type depending on encoding)
    input  wire        MEM_MemRead,       // MEM stage is a load (used for branch checks)
    input  wire [4:0]  MEM_rd,
    input  wire [4:0]  WB_rd,

    input  wire [4:0]  ID_rs,
    input  wire [4:0]  ID_rt,
    input  wire        ID_UsesRtAsSrc,    // 1 if ID instruction uses rt as a source (sw, beq etc.)
    input  wire        Branch_ID,         // 1 if ID instruction is a branch (beq/bne)
    input  wire        Jump_ID,           // 1 if ID is a jump (for IF/ID flush)
    input  wire        BranchTaken_EX,    // 1 if branch in EX resolves to taken

    input  wire        Forwarding_Enabled, // 1 if forwarding unit exists (avoids many stalls)

    // Control outputs to pipeline registers / PC
    output reg         PC_Write,
    output reg         IF_ID_Write,
    output reg         ID_EX_Flush,
    output reg         IF_ID_Flush
);

    // Internal hazard signals
    reg load_use_hazard;
    reg alu_dep_hazard;
    reg store_data_hazard;
    reg branch_dep_hazard;

    always @(*) begin
        // Defaults - no stall, no flush
        PC_Write     = 1;
        IF_ID_Write  = 1;
        ID_EX_Flush  = 0;
        IF_ID_Flush  = 0;

        load_use_hazard   = 0;
        alu_dep_hazard    = 0;
        store_data_hazard = 0;
        branch_dep_hazard = 0;

        //--------------------------------------------------------
        // 1) Load-use hazard (EX stage load → ID instruction uses the loaded reg)
        //    This covers both ALU source usage and store data usage (if ID_UsesRtAsSrc=1)
        //--------------------------------------------------------
        if (EX_MemRead) begin
            if ((EX_rd == ID_rs) || (ID_UsesRtAsSrc && (EX_rd == ID_rt))) begin
                load_use_hazard = 1;
            end
        end

        //--------------------------------------------------------
        // 2) ALU->ALU dependency when forwarding is NOT available
        //    If forwarding exists, this is usually resolved and no stall needed.
        //    When forwarding disabled, stall if EX will write reg that ID needs.
        //--------------------------------------------------------
        if (!Forwarding_Enabled) begin
            if (EX_RegWrite && (EX_rd != 5'd0)) begin
                if ((EX_rd == ID_rs) || (ID_UsesRtAsSrc && (EX_rd == ID_rt))) begin
                    alu_dep_hazard = 1;
                end
            end
        end

        //--------------------------------------------------------
        // 3) Store data hazard
        //    If instruction in ID is SW (ID_UsesRtAsSrc==1 for stores) and EX is load producing that register
        //    this is already covered by load_use_hazard above, but we keep a named signal for clarity.
        //--------------------------------------------------------
        if (ID_UsesRtAsSrc) begin
            if (EX_MemRead && (EX_rd == ID_rt)) begin
                store_data_hazard = 1;
            end
        end

        //--------------------------------------------------------
        // 4) Branch hazard (branch in ID depends on result not yet available)
        //    We conservatively stall if:
        //    - EX is load and will produce register used by branch (EX_MemRead and match)
        //    - EX will write a register needed by branch and forwarding to ID is NOT provided
        //    - MEM stage is a load writing a reg needed by branch (this can also require stall if your design can't forward from MEM to ID)
        //
        //    Many implementations only check EX_MemRead hazard for branch (simple and safe).
        //--------------------------------------------------------
        if (Branch_ID) begin
            // Common: stall when EX is a load writing a register branch needs
            if (EX_MemRead && ((EX_rd == ID_rs) || (EX_rd == ID_rt))) begin
                branch_dep_hazard = 1;
            end
            // If forwarding not available to ID, also stall for EX_RegWrite dependencies
            else if (!Forwarding_Enabled) begin
                if (EX_RegWrite && (EX_rd != 5'd0) &&
                   ((EX_rd == ID_rs) || (EX_rd == ID_rt))) begin
                    branch_dep_hazard = 1;
                end
                // Optionally check MEM stage load if pipeline can't forward from MEM to ID
                if (MEM_MemRead && ((MEM_rd == ID_rs) || (MEM_rd == ID_rt))) begin
                    branch_dep_hazard = 1;
                end
            end
        end

        //--------------------------------------------------------
        // Combine hazard effects
        //--------------------------------------------------------
        // Priority: Branch taken flush (handled below) > Stall (load-use / branch_dep / alu_dep) > normal
        // If any stall condition, freeze IF/ID & PC, and insert bubble into ID/EX.
        if (load_use_hazard || branch_dep_hazard || alu_dep_hazard || store_data_hazard) begin
            PC_Write    = 0;   // stop PC from advancing
            IF_ID_Write = 0;   // freeze IF/ID (so IF instruction remains there)
            ID_EX_Flush = 1;   // insert bubble into EX by turning off control signals in ID/EX
            // Do NOT assert IF_ID_Flush for a stall — we want to keep IF/ID instruction for next cycle
        end

        //--------------------------------------------------------
        // Branch taken in EX stage: flush IF/ID (wrong-path) and ID/EX
        // (this action typically occurs when branch condition is known in EX)
        //--------------------------------------------------------
        if (BranchTaken_EX) begin
            // Branch resolved: flush the instructions that were fetched down the wrong path
            IF_ID_Flush = 1;   // invalidate IF/ID (the instruction fetched after branch)
            ID_EX_Flush = 1;   // flush ID/EX as well (ID instruction was on wrong path)
            // PC_Write stays enabled since PC will be loaded with branch target externally
            // IF_ID_Write can remain 1 (we're flushing the content)
        end

        //--------------------------------------------------------
        // Jump in ID: flush the instruction fetched after jump (IF/ID flush)
        //--------------------------------------------------------
        if (Jump_ID) begin
            IF_ID_Flush = 1;
            // no stall necessary
        end
    end

endmodule
