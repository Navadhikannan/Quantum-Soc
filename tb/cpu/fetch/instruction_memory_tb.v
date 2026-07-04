`timescale 1ns/1ps
module instruction_memory_tb;

parameter XLEN = 32;

reg  [XLEN-1:0] address;
wire [XLEN-1:0] instruction;

//============================================================
// DUT
//============================================================

instruction_memory #(
    .XLEN(XLEN)
) dut (
    .address(address),
    .instruction(instruction)
);

//============================================================
// Test Sequence
//============================================================

initial begin

    $dumpfile("instruction_memory.vcd");
    $dumpvars(0, instruction_memory_tb);

    // Read Instruction 0
    address = 32'h00000000;
    #10;

    // Read Instruction 1
    address = 32'h00000004;
    #10;

    // Read Instruction 2
    address = 32'h00000008;
    #10;

    // Read Instruction 3
    address = 32'h0000000C;
    #10;

    $finish;

end

endmodule