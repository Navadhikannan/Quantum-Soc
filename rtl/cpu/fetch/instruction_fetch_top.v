//============================================================
// Module      : Instruction Fetch Top
// Project     : QSoc
// Description : Complete Instruction Fetch Stage
//============================================================

module instruction_fetch_top #(
    parameter XLEN = 32
)(
    input  wire             clk,
    input  wire             reset,

    input  wire             branch_taken,
    input  wire [XLEN-1:0]  branch_target,

    input  wire             jump_taken,
    input  wire [XLEN-1:0]  jump_target,

    input  wire             pc_write,
    input  wire             if_id_write,

    output wire [XLEN-1:0]  pc_out,
    output wire [31:0]      instruction_out
);

    //========================================================
    // Internal Signals
    //========================================================

    wire [XLEN-1:0] pc_wire;
    wire [XLEN-1:0] next_pc_wire;
    wire [31:0]     instruction_wire;

    //========================================================
    // Next PC Logic
    //========================================================

    next_pc_logic #(
        .XLEN(XLEN)
    ) next_pc_inst (
        .current_pc   (pc_wire),
        .branch_taken (branch_taken),
        .branch_target(branch_target),
        .jump_taken   (jump_taken),
        .jump_target  (jump_target),
        .next_pc      (next_pc_wire)
    );

    //========================================================
    // Program Counter
    //========================================================

    program_counter #(
        .XLEN(XLEN)
    ) pc_inst (
        .clk      (clk),
        .reset    (reset),
        .pc_write (pc_write),
        .next_pc  (next_pc_wire),
        .pc       (pc_wire)
    );

    //========================================================
    // Instruction Memory
    //========================================================

    instruction_memory #(
        .XLEN(XLEN)
    ) imem_inst (
        .address     (pc_wire),
        .instruction (instruction_wire)
    );

    //========================================================
    // IF/ID Pipeline Register
    //========================================================

    if_id #(
        .XLEN(XLEN)
    ) if_id_inst (
        .clk            (clk),
        .reset          (reset),
        .write_enable   (if_id_write),

        .pc_in          (pc_wire),
        .instruction_in (instruction_wire),

        .pc_out         (pc_out),
        .instruction_out(instruction_out)
    );

endmodule