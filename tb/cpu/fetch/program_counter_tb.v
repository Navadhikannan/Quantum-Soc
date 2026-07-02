`timescale 1ns/1ps

module program_counter_tb;

parameter XLEN = 32;
parameter RESET_PC = 32'h00000000;

reg clk;
reg reset;
reg pc_write;
reg [XLEN-1:0] next_pc;

wire [XLEN-1:0] pc;

// Instantiate DUT (Device Under Test)
program_counter #(
    .XLEN(XLEN),
    .RESET_PC(RESET_PC)
) dut (
    .clk(clk),
    .reset(reset),
    .pc_write(pc_write),
    .next_pc(next_pc),
    .pc(pc)
);

// Clock Generation
always #5 clk = ~clk;

initial begin

    // Dump waveform
    $dumpfile("program_counter.vcd");
    $dumpvars(0, program_counter_tb);

    // Initialize
    clk = 0;
    reset = 1;
    pc_write = 0;
    next_pc = 0;

    // Hold reset
    #10;

    // Release reset
    reset = 0;

    // Write 4
    pc_write = 1;
    next_pc = 32'd4;
    #10;

    // Write 8
    next_pc = 32'd8;
    #10;

    // Hold PC
    pc_write = 0;
    next_pc = 32'd100;
    #10;

    // Write 16
    pc_write = 1;
    next_pc = 32'd16;
    #10;

    $finish;

end

endmodule