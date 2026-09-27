`timescale 1ns/1ps

module ex_mem_tb;

reg clk;
reg reset;

reg [31:0] alu_result_in;
reg [31:0] branch_target_in;
reg [31:0] rs2_data_in;
reg [4:0] rd_in;

reg branch_taken_in;

reg reg_write_in;
reg mem_read_in;
reg mem_write_in;
reg mem_to_reg_in;
reg branch_in;

wire [31:0] alu_result_out;
wire [31:0] branch_target_out;
wire [31:0] rs2_data_out;
wire [4:0] rd_out;

wire branch_taken_out;

wire reg_write_out;
wire mem_read_out;
wire mem_write_out;
wire mem_to_reg_out;
wire branch_out;

ex_mem dut(

    .clk(clk),
    .reset(reset),

    .alu_result_in(alu_result_in),
    .branch_target_in(branch_target_in),
    .rs2_data_in(rs2_data_in),
    .rd_in(rd_in),

    .branch_taken_in(branch_taken_in),

    .reg_write_in(reg_write_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_to_reg_in(mem_to_reg_in),
    .branch_in(branch_in),

    .alu_result_out(alu_result_out),
    .branch_target_out(branch_target_out),
    .rs2_data_out(rs2_data_out),
    .rd_out(rd_out),

    .branch_taken_out(branch_taken_out),

    .reg_write_out(reg_write_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .branch_out(branch_out)

);

always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    alu_result_in = 0;
    branch_target_in = 0;
    rs2_data_in = 0;
    rd_in = 0;

    branch_taken_in = 0;

    reg_write_in = 0;
    mem_read_in = 0;
    mem_write_in = 0;
    mem_to_reg_in = 0;
    branch_in = 0;

    $dumpfile("ex_mem.vcd");
    $dumpvars(0,ex_mem_tb);

    #10;
    reset = 0;

    // Test Case 1
    alu_result_in    = 32'd100;
    branch_target_in = 32'd200;
    rs2_data_in      = 32'd300;
    rd_in            = 5'd10;

    branch_taken_in  = 1'b1;

    reg_write_in     = 1'b1;
    mem_read_in      = 1'b0;
    mem_write_in     = 1'b1;
    mem_to_reg_in    = 1'b0;
    branch_in        = 1'b1;

    #10;

    // Test Case 2
    alu_result_in    = 32'd500;
    branch_target_in = 32'd600;
    rs2_data_in      = 32'd700;
    rd_in            = 5'd15;

    branch_taken_in  = 1'b0;

    reg_write_in     = 1'b1;
    mem_read_in      = 1'b1;
    mem_write_in     = 1'b0;
    mem_to_reg_in    = 1'b1;
    branch_in        = 1'b0;

    #20;

    $finish;

end

initial begin

$monitor("Time=%0t | ALU=%0d | Target=%0d | RD=%0d | BranchTaken=%b | RegWrite=%b | MemRead=%b | MemWrite=%b",
          $time,
          alu_result_out,
          branch_target_out,
          rd_out,
          branch_taken_out,
          reg_write_out,
          mem_read_out,
          mem_write_out);

end

endmodule