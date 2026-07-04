//============================================================
// Module      : Next PC Logic
// Project     : QSoc
// Author      : Navadhi Kannan, Monishkanna
// Description : Selects the next Program Counter value
//============================================================

module next_pc_logic #(
    parameter XLEN = 32
)(
    input  wire [XLEN-1:0] current_pc,
    input  wire            branch_taken,
    input  wire [XLEN-1:0] branch_target,
    input  wire            jump_taken,
    input  wire [XLEN-1:0] jump_target,

    output reg [XLEN-1:0] next_pc
);

    // Size of one instruction (RV32I = 4 bytes)
    localparam [XLEN-1:0] INSTR_SIZE = 32'd4;

    // Combinational Next-PC Logic
    always @(*) begin

        if (jump_taken)
            next_pc = jump_target;

        else if (branch_taken)
            next_pc = branch_target;

        else
            next_pc = current_pc + INSTR_SIZE;

    end

endmodule