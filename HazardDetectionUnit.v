// HazardDetectionUnit.v
// Handles: load-use stalls (including stores), optional ALU-ALU stalls when forwarding disabled,
// branch-related stalls, and branch/jump flushes.

module HazardDetectionUnit (
    input  clk,
    input  reset,             // not strictly required, kept for clarity

    // Pipeline signals (from pipeline registers / control)
    input EX_MemRead,        // EX stage is a load
    input EX_RegWrite,       // EX stage will write a register
    input [4:0]  EX_rd,             // EX stage destination register (rt for load, rd for R-type depending on encoding)
    input MEM_MemRead,       // MEM stage is a load (used for branch checks)
    input [4:0] MEM_rd,
    input [4:0] WB_rd,

    input [4:0] ID_rs,
    input [4:0] ID_rt,
    input ID_UsesRtAsSrc,    // 1 if ID instruction uses rt as a source (sw, beq etc.)
    input Branch_ID,         // 1 if ID instruction is a branch (beq/bne)
    input Jump_ID,           // 1 if ID is a jump (for IF/ID flush)

    input Forwarding_Enabled, // 1 if forwarding unit exists (avoids many stalls)

    // Control outputs to pipeline registers / PC
    output reg PC_Write,
    output reg IF_ID_Write,
    output reg ID_EX_Flush,
    output reg IF_ID_Flush
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

        //load use hazard
        if (EX_MemRead) begin
            if ((EX_rd == ID_rs) || (ID_UsesRtAsSrc && (EX_rd == ID_rt))) begin
                load_use_hazard = 1;
            end
        end

        //ALU to ALU dependency
        if (!Forwarding_Enabled) begin
            if (EX_RegWrite && (EX_rd != 5'd0)) begin
                if ((EX_rd == ID_rs) || (ID_UsesRtAsSrc && (EX_rd == ID_rt))) begin
                    alu_dep_hazard = 1;
                end
            end
        end

        //store hazard
        if (ID_UsesRtAsSrc) begin
            if (EX_MemRead && (EX_rd == ID_rt)) begin
                store_data_hazard = 1;
            end
        end

        //branch hazard
    if (Branch_ID) begin
        // Stall for EX stage load
        if (EX_MemRead && ((EX_rd == ID_rs) || (EX_rd == ID_rt))) begin
            branch_dep_hazard = 1;
        end
        // Stall for EX stage ALU op (not an else-if!)
        if (EX_RegWrite && (EX_rd != 5'd0) && !EX_MemRead &&
           ((EX_rd == ID_rs) || (EX_rd == ID_rt))) begin
            branch_dep_hazard = 1;
        end
        // Stall for MEM stage load (not an else-if!)
        if (MEM_MemRead && ((MEM_rd == ID_rs) || (MEM_rd == ID_rt))) begin
            branch_dep_hazard = 1;
        end
    end

        //combine hazards
        if (load_use_hazard || branch_dep_hazard || alu_dep_hazard || store_data_hazard) begin
            PC_Write    = 0;   // stop PC from advancing
            IF_ID_Write = 0;   // freeze IF/ID (so IF instruction remains there)
            ID_EX_Flush = 1;   // insert bubble into EX by turning off control signals in ID/EX
            // Do NOT assert IF_ID_Flush for a stall - we want to keep IF/ID instruction for next cycle
        end

        if (Jump_ID) begin
            IF_ID_Flush = 1;
            // no stall necessary
        end
    end

endmodule
