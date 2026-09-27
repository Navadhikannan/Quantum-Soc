`timescale 1ns/1ps

module mem_wb_tb;

parameter XLEN = 32;

reg clk;
reg reset;

reg [31:0] read_data_in;
reg [31:0] alu_result_in;
reg [4:0] rd_in;

reg reg_write_in;
reg mem_to_reg_in;

wire [31:0] read_data_out;
wire [31:0] alu_result_out;
wire [4:0] rd_out;

wire reg_write_out;
wire mem_to_reg_out;

mem_wb DUT
(
    .clk(clk),
    .reset(reset),

    .read_data_in(read_data_in),
    .alu_result_in(alu_result_in),
    .rd_in(rd_in),

    .reg_write_in(reg_write_in),
    .mem_to_reg_in(mem_to_reg_in),

    .read_data_out(read_data_out),
    .alu_result_out(alu_result_out),
    .rd_out(rd_out),

    .reg_write_out(reg_write_out),
    .mem_to_reg_out(mem_to_reg_out)
);

//////////////////////////////////////////////////
// Clock
//////////////////////////////////////////////////

always #5 clk = ~clk;

//////////////////////////////////////////////////
// Stimulus
//////////////////////////////////////////////////

initial
begin

    clk = 0;
    reset = 1;

    read_data_in = 0;
    alu_result_in = 0;
    rd_in = 0;

    reg_write_in = 0;
    mem_to_reg_in = 0;

    #12;
    reset = 0;

    //--------------------------------------------------
    // Test 1
    //--------------------------------------------------

    read_data_in = 32'h12345678;
    alu_result_in = 32'hAAAAAAAA;
    rd_in = 5'd10;

    reg_write_in = 1;
    mem_to_reg_in = 1;

    #10;

    //--------------------------------------------------
    // Test 2
    //--------------------------------------------------

    read_data_in = 32'hDEADBEEF;
    alu_result_in = 32'h00000064;
    rd_in = 5'd15;

    reg_write_in = 1;
    mem_to_reg_in = 0;

    #10;

    //--------------------------------------------------
    // Test 3
    //--------------------------------------------------

    read_data_in = 32'h000000FA;
    alu_result_in = 32'h11111111;
    rd_in = 5'd20;

    reg_write_in = 0;
    mem_to_reg_in = 1;

    #10;

    //--------------------------------------------------
    // Test 4
    //--------------------------------------------------

    read_data_in = 32'hCAFEBABE;
    alu_result_in = 32'h22222222;
    rd_in = 5'd31;

    reg_write_in = 1;
    mem_to_reg_in = 1;

    #20;

    $finish;

end

//////////////////////////////////////////////////
// Waveform
//////////////////////////////////////////////////

initial
begin
    $dumpfile("mem_wb.vcd");
    $dumpvars(0, mem_wb_tb);
end

endmodule