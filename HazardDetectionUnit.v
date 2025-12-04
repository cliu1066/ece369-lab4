// HazardDetectionUnit.v
// Handles: load-use stalls (including stores), optional ALU-ALU stalls when forwarding disabled,
// branch-related stalls, and branch/jump flushes.

module HazardDetectionUnit (
    input EX_MemRead,        // EX stage is a load
    input EX_RegWrite,       // EX stage will write a register
    input [4:0]  EX_Rd,      // EX stage destination register (rt for load, rd for R-type depending on encoding)
    input MEM_MemRead,       // MEM stage is a load (used for branch checks)
    input [4:0] MEM_Rd,
    input [4:0] WB_Rd,

    input [4:0] ID_Rs,
    input [4:0] ID_Rt,
    input ID_UsesRtAsSrc,    // 1 if ID instruction uses rt as a source (sw, beq)
    input Branch_ID,         // 1 if ID instruction is a branch (beq/bne)
    input Jump_ID,           // 1 if ID is a jump (for IF/ID flush)

    output reg PC_Write,
    output reg IF_ID_Write,
    output reg ID_EX_Flush,
    output reg IF_ID_Flush
);

    // internal hazard signals
    reg load_use_hazard;
    reg alu_dep_hazard;
    reg store_data_hazard;
    reg branch_dep_hazard;

    always @(*) begin
        // no stall or flush
        PC_Write     = 1;
        IF_ID_Write  = 1;
        ID_EX_Flush  = 0;
        IF_ID_Flush  = 0;

        load_use_hazard   = 0;
        alu_dep_hazard    = 0;
        store_data_hazard = 0;
        branch_dep_hazard = 0;

        // load use hazard
        if (EX_MemRead) begin
            if ((EX_Rd == ID_Rs) || (ID_UsesRtAsSrc && (EX_Rd == ID_Rt))) begin
                load_use_hazard = 1;
            end
        end

        // store hazard
        if (ID_UsesRtAsSrc) begin
            if (EX_MemRead && (EX_Rd == ID_Rt)) begin
                store_data_hazard = 1;
            end
        end

        // branch hazard
        if (Branch_ID) begin
            // stall for EX stage load
            if (EX_MemRead && ((EX_Rd == ID_Rs) || (EX_Rd == ID_Rt))) begin
                branch_dep_hazard = 1;
            end
            // stall for EX stage ALU op
            if (EX_RegWrite && (EX_Rd != 5'd0) && !EX_MemRead &&
               ((EX_Rd == ID_Rs) || (EX_Rd == ID_Rt))) begin
                branch_dep_hazard = 1;
            end
            // stall for MEM stage load
            if (MEM_MemRead && ((MEM_Rd == ID_Rs) || (MEM_Rd == ID_Rt))) begin
                branch_dep_hazard = 1;
            end
        end

        // combine hazards
        if (load_use_hazard || branch_dep_hazard || alu_dep_hazard || store_data_hazard) begin
            PC_Write    = 0;   // stop PC from advancing
            IF_ID_Write = 0;   // freeze IF/ID (so IF instruction remains there)
            ID_EX_Flush = 1;   // insert bubble into EX by turning off control signals in ID/EX
        end

        if (Jump_ID) begin
            IF_ID_Flush = 1;
        end
    end

endmodule