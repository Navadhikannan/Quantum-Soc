`timescale 1ns/1ps
module next_pc_logic_tb;

parameter XLEN = 32;

reg  [XLEN-1:0] current_pc;
reg             branch_taken;
reg  [XLEN-1:0] branch_target;
reg             jump_taken;
reg  [XLEN-1:0] jump_target;

wire [XLEN-1:0] next_pc;

//============================================================
// DUT
//============================================================

next_pc_logic #(
    .XLEN(XLEN)
) dut (
    .current_pc(current_pc),
    .branch_taken(branch_taken),
    .branch_target(branch_target),
    .jump_taken(jump_taken),
    .jump_target(jump_target),
    .next_pc(next_pc)
);

//============================================================
// Test Sequence
//============================================================

initial begin

    $dumpfile("next_pc_logic.vcd");
    $dumpvars(0, next_pc_logic_tb);

    // Test 1 : Sequential
    current_pc    = 32'd0;
    branch_taken  = 0;
    jump_taken    = 0;
    branch_target = 32'd0;
    jump_target   = 32'd0;

    #10;

    // Test 2 : Sequential
    current_pc = 32'd4;

    #10;

    // Test 3 : Branch
    current_pc    = 32'd8;
    branch_taken  = 1;
    branch_target = 32'd100;

    #10;

    // Test 4 : Jump
    branch_taken = 0;
    jump_taken   = 1;
    jump_target  = 32'd200;

    #10;

    // Test 5 : Jump has higher priority
    branch_taken  = 1;
    jump_taken    = 1;
    branch_target = 32'd300;
    jump_target   = 32'd400;

    #10;

    $finish;

end

endmodule