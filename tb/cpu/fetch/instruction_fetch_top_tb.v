`timescale 1ns/1ps
module instruction_fetch_top_tb;

parameter XLEN = 32;

//============================================================
// Inputs
//============================================================

reg clk;
reg reset;

reg branch_taken;
reg jump_taken;

reg [XLEN-1:0] branch_target;
reg [XLEN-1:0] jump_target;

reg pc_write;
reg if_id_write;

//============================================================
// Outputs
//============================================================

wire [XLEN-1:0] pc_out;
wire [31:0] instruction_out;

//============================================================
// DUT
//============================================================

instruction_fetch_top #(
    .XLEN(XLEN)
) dut (

    .clk(clk),
    .reset(reset),

    .branch_taken(branch_taken),
    .branch_target(branch_target),

    .jump_taken(jump_taken),
    .jump_target(jump_target),

    .pc_write(pc_write),
    .if_id_write(if_id_write),

    .pc_out(pc_out),
    .instruction_out(instruction_out)

);

//============================================================
// Clock Generation
//============================================================

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//============================================================
// Test Sequence
//============================================================

initial begin

    $dumpfile("instruction_fetch_top.vcd");
    $dumpvars(0, instruction_fetch_top_tb);

    //--------------------------------------------------------
    // Initialize
    //--------------------------------------------------------

    reset         = 1;
    branch_taken  = 0;
    jump_taken    = 0;
    branch_target = 32'd0;
    jump_target   = 32'd0;
    pc_write      = 1;
    if_id_write   = 1;

    #12;

    //--------------------------------------------------------
    // Release Reset
    //--------------------------------------------------------

    reset = 0;

    //--------------------------------------------------------
    // Sequential Fetch
    //--------------------------------------------------------

    #40;

    //--------------------------------------------------------
    // Branch Test
    //--------------------------------------------------------

    branch_taken  = 1;
    branch_target = 32'd16;

    #10;

    branch_taken = 0;

    #20;

    //--------------------------------------------------------
    // Jump Test
    //--------------------------------------------------------

    jump_taken  = 1;
    jump_target = 32'd32;

    #10;

    jump_taken = 0;

    #20;

    //--------------------------------------------------------
    // PC Stall
    //--------------------------------------------------------

    pc_write = 0;

    #20;

    pc_write = 1;

    #20;

    //--------------------------------------------------------
    // IF/ID Stall
    //--------------------------------------------------------

    if_id_write = 0;

    #20;

    if_id_write = 1;

    #20;

    $finish;

end

//============================================================
// Monitor
//============================================================

initial begin

$monitor("Time=%0t | PC=%h | Instruction=%h | Branch=%b | Jump=%b",
          $time,
          pc_out,
          instruction_out,
          branch_taken,
          jump_taken);

end

endmodule