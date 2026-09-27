`timescale 1ns/1ps

module branch_target_generator_tb;

reg [31:0] pc;
reg [31:0] immediate;

wire [31:0] branch_target;

branch_target_generator dut(

    .pc(pc),
    .immediate(immediate),
    .branch_target(branch_target)

);

initial begin

    $dumpfile("branch_target_generator.vcd");
    $dumpvars(0, branch_target_generator_tb);

    $display("------------------------------------------");
    $display(" BRANCH TARGET GENERATOR TEST STARTED ");
    $display("------------------------------------------");

    // Test Case 1
    pc = 32'd100;
    immediate = 32'd16;
    #10;

    // Test Case 2
    pc = 32'd200;
    immediate = 32'd32;
    #10;

    // Test Case 3
    pc = 32'd500;
    immediate = -32'd20;
    #10;

    // Test Case 4
    pc = 32'h00001000;
    immediate = 32'h00000100;
    #10;

    // Test Case 5
    pc = 32'd0;
    immediate = 32'd4;
    #10;

    $display("------------------------------------------");
    $display(" BRANCH TARGET GENERATOR TEST COMPLETED ");
    $display("------------------------------------------");

    $finish;

end

initial begin

    $monitor("Time=%0t | PC=%0d | Immediate=%0d | Branch Target=%0d",
              $time, pc, immediate, branch_target);

end

endmodule