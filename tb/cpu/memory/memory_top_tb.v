`timescale 1ns/1ps

module memory_top_tb;

parameter XLEN = 32;

reg clk;
reg reset;

reg [31:0] alu_result;
reg [31:0] rs2_data;
reg [4:0] rd;

reg reg_write;
reg mem_read;
reg mem_write;
reg mem_to_reg;

wire [31:0] read_data_out;
wire [31:0] alu_result_out;
wire [4:0] rd_out;

wire reg_write_out;
wire mem_to_reg_out;


// DUT


memory_top DUT
(
    .clk(clk),
    .reset(reset),

    .alu_result(alu_result),
    .rs2_data(rs2_data),
    .rd(rd),

    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),

    .read_data_out(read_data_out),
    .alu_result_out(alu_result_out),
    .rd_out(rd_out),

    .reg_write_out(reg_write_out),
    .mem_to_reg_out(mem_to_reg_out)
);

//////////////////////////////////////////////////////
// Clock
//////////////////////////////////////////////////////

always #5 clk = ~clk;

//////////////////////////////////////////////////////
// Test
//////////////////////////////////////////////////////

initial
begin

    clk = 0;
    reset = 1;

    alu_result = 0;
    rs2_data = 0;
    rd = 0;

    reg_write = 0;
    mem_read = 0;
    mem_write = 0;
    mem_to_reg = 0;

    #12;
    reset = 0;

    //////////////////////////////////////////////////////
    // Test 1 : Store 100
    //////////////////////////////////////////////////////

    alu_result = 32'h00000000;
    rs2_data = 32'd100;

    mem_write = 1;
    mem_read = 0;

    reg_write = 0;
    mem_to_reg = 0;

    #10;

    mem_write = 0;

    //////////////////////////////////////////////////////
    // Test 2 : Load 100
    //////////////////////////////////////////////////////

    mem_read = 1;
    rd = 5'd10;

    reg_write = 1;
    mem_to_reg = 1;

    #10;

    //////////////////////////////////////////////////////
    // Test 3 : Store DEADBEEF
    //////////////////////////////////////////////////////

    mem_read = 0;
    mem_write = 1;

    alu_result = 32'h00000004;
    rs2_data = 32'hDEADBEEF;

    #10;

    mem_write = 0;

    //////////////////////////////////////////////////////
    // Test 4 : Load DEADBEEF
    //////////////////////////////////////////////////////

    mem_read = 1;

    rd = 5'd20;

    reg_write = 1;
    mem_to_reg = 1;

    #20;

    $finish;

end

//////////////////////////////////////////////////////
// Waveform
//////////////////////////////////////////////////////

initial
begin
    $dumpfile("memory_top.vcd");
    $dumpvars(0,memory_top_tb);
end

endmodule