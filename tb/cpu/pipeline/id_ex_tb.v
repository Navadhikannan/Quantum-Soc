`timescale 1ns/1ps

module id_ex_tb;

parameter XLEN = 32;

//==========================================================
// Inputs
//==========================================================

reg clk;
reg reset;
reg write_enable;

// Datapath Inputs

reg [XLEN-1:0] pc_in;
reg [XLEN-1:0] read_data1_in;
reg [XLEN-1:0] read_data2_in;
reg [XLEN-1:0] immediate_in;

reg [4:0] rs1_in;
reg [4:0] rs2_in;
reg [4:0] rd_in;

// Control Inputs

reg reg_write_in;
reg alu_src_in;
reg mem_read_in;
reg mem_write_in;
reg mem_to_reg_in;
reg branch_in;
reg jump_in;
reg [1:0] alu_op_in;

//==========================================================
// Outputs
//==========================================================

wire [XLEN-1:0] pc_out;
wire [XLEN-1:0] read_data1_out;
wire [XLEN-1:0] read_data2_out;
wire [XLEN-1:0] immediate_out;

wire [4:0] rs1_out;
wire [4:0] rs2_out;
wire [4:0] rd_out;

wire reg_write_out;
wire alu_src_out;
wire mem_read_out;
wire mem_write_out;
wire mem_to_reg_out;
wire branch_out;
wire jump_out;
wire [1:0] alu_op_out;

//==========================================================
// DUT
//==========================================================

id_ex #(
    .XLEN(XLEN)
) dut (

    .clk(clk),
    .reset(reset),
    .write_enable(write_enable),

    .pc_in(pc_in),
    .read_data1_in(read_data1_in),
    .read_data2_in(read_data2_in),
    .immediate_in(immediate_in),

    .rs1_in(rs1_in),
    .rs2_in(rs2_in),
    .rd_in(rd_in),

    .reg_write_in(reg_write_in),
    .alu_src_in(alu_src_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_to_reg_in(mem_to_reg_in),
    .branch_in(branch_in),
    .jump_in(jump_in),
    .alu_op_in(alu_op_in),

    .pc_out(pc_out),
    .read_data1_out(read_data1_out),
    .read_data2_out(read_data2_out),
    .immediate_out(immediate_out),

    .rs1_out(rs1_out),
    .rs2_out(rs2_out),
    .rd_out(rd_out),

    .reg_write_out(reg_write_out),
    .alu_src_out(alu_src_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .branch_out(branch_out),
    .jump_out(jump_out),
    .alu_op_out(alu_op_out)

);

//==========================================================
// Clock Generation
//==========================================================

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//==========================================================
// Test Sequence
//==========================================================

initial begin

    $dumpfile("id_ex.vcd");
    $dumpvars(0, id_ex_tb);

    //------------------------------------------------------
    // Initialize
    //------------------------------------------------------

    reset = 1;
    write_enable = 0;

    pc_in = 0;
    read_data1_in = 0;
    read_data2_in = 0;
    immediate_in = 0;

    rs1_in = 0;
    rs2_in = 0;
    rd_in = 0;

    reg_write_in = 0;
    alu_src_in = 0;
    mem_read_in = 0;
    mem_write_in = 0;
    mem_to_reg_in = 0;
    branch_in = 0;
    jump_in = 0;
    alu_op_in = 2'b00;

    #12;

    //------------------------------------------------------
    // Release Reset
    //------------------------------------------------------

    reset = 0;
    write_enable = 1;

    //------------------------------------------------------
    // Test Data Transfer
    //------------------------------------------------------

    pc_in = 32'h00000020;
    read_data1_in = 32'd100;
    read_data2_in = 32'd200;
    immediate_in = 32'd16;

    rs1_in = 5;
    rs2_in = 6;
    rd_in  = 7;

    reg_write_in = 1;
    alu_src_in   = 1;
    mem_read_in  = 1;
    mem_write_in = 0;
    mem_to_reg_in= 1;
    branch_in    = 0;
    jump_in      = 0;
    alu_op_in    = 2'b10;

    #10;

    //------------------------------------------------------
    // Hold Previous Values
    //------------------------------------------------------

    write_enable = 0;

    pc_in = 32'hFFFFFFFF;
    read_data1_in = 32'hAAAAAAAA;
    read_data2_in = 32'hBBBBBBBB;
    immediate_in = 32'hCCCCCCCC;

    rs1_in = 31;
    rs2_in = 30;
    rd_in  = 29;

    reg_write_in = 0;
    alu_src_in   = 0;
    mem_read_in  = 0;
    mem_write_in = 1;
    mem_to_reg_in= 0;
    branch_in    = 1;
    jump_in      = 1;
    alu_op_in    = 2'b01;

    #10;

    //------------------------------------------------------
    // Enable Write Again
    //------------------------------------------------------

    write_enable = 1;

    #10;

    $finish;

end

//==========================================================
// Monitor
//==========================================================

initial begin

$monitor(
"Time=%0t | PC=%h | RD1=%0d | RD2=%0d | IMM=%0d | rs1=%0d | rs2=%0d | rd=%0d | RegWrite=%b | ALUSrc=%b | MemRead=%b | MemWrite=%b | MemToReg=%b | Branch=%b | Jump=%b | ALUOp=%b",
    $time,
    pc_out,
    read_data1_out,
    read_data2_out,
    immediate_out,
    rs1_out,
    rs2_out,
    rd_out,
    reg_write_out,
    alu_src_out,
    mem_read_out,
    mem_write_out,
    mem_to_reg_out,
    branch_out,
    jump_out,
    alu_op_out
);

end

endmodule