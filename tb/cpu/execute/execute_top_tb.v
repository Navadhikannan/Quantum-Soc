`timescale 1ns/1ps

module execute_top_tb;

parameter XLEN = 32;

//--------------------------------------------------
// Inputs
//--------------------------------------------------

reg clk;
reg reset;

reg [XLEN-1:0] pc;
reg [XLEN-1:0] read_data1;
reg [XLEN-1:0] read_data2;
reg [XLEN-1:0] immediate;

reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;

reg [2:0] funct3;
reg [6:0] funct7;

reg reg_write;
reg alu_src;
reg mem_read;
reg mem_write;
reg mem_to_reg;
reg branch;
reg jump;
reg [1:0] alu_op;

//--------------------------------------------------
// Outputs
//--------------------------------------------------

wire [31:0] alu_result;
wire [31:0] branch_target;
wire [31:0] rs2_data;
wire [4:0] rd_out;

wire branch_taken;

wire reg_write_out;
wire mem_read_out;
wire mem_write_out;
wire mem_to_reg_out;
wire branch_out;

//--------------------------------------------------
// DUT
//--------------------------------------------------

execute_top DUT(

    .clk(clk),
    .reset(reset),

    .pc(pc),
    .read_data1(read_data1),
    .read_data2(read_data2),
    .immediate(immediate),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),

    .funct3(funct3),
    .funct7(funct7),

    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .jump(jump),
    .alu_op(alu_op),

    .alu_result(alu_result),
    .branch_target(branch_target),
    .rs2_data(rs2_data),
    .rd_out(rd_out),

    .branch_taken(branch_taken),

    .reg_write_out(reg_write_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .branch_out(branch_out)

);

//--------------------------------------------------
// Clock Generation
//--------------------------------------------------

always #5 clk = ~clk;

//--------------------------------------------------
// Test Sequence
//--------------------------------------------------

initial begin

    $dumpfile("execute_top.vcd");
    $dumpvars(0, execute_top_tb);

    clk = 0;
    reset = 1;

    pc = 0;
    read_data1 = 0;
    read_data2 = 0;
    immediate = 0;

    rs1 = 0;
    rs2 = 0;
    rd  = 0;

    funct3 = 0;
    funct7 = 0;

    reg_write = 0;
    alu_src = 0;
    mem_read = 0;
    mem_write = 0;
    mem_to_reg = 0;
    branch = 0;
    jump = 0;
    alu_op = 0;

    #10;
    reset = 0;

    //--------------------------------------------------
    // Test 1 : ADD
    //--------------------------------------------------

    pc = 100;
    read_data1 = 20;
    read_data2 = 30;

    alu_src = 0;
    alu_op = 2'b10;

    funct3 = 3'b000;
    funct7 = 7'b0000000;

    reg_write = 1;

    #10;

    //--------------------------------------------------
    // Test 2 : SUB
    //--------------------------------------------------

    read_data1 = 40;
    read_data2 = 15;

    funct3 = 3'b000;
    funct7 = 7'b0100000;

    #10;

    //--------------------------------------------------
    // Test 3 : AND
    //--------------------------------------------------

    read_data1 = 32'hF0F0F0F0;
    read_data2 = 32'h0FF00FF0;

    funct3 = 3'b111;

    #10;

    //--------------------------------------------------
    // Test 4 : OR
    //--------------------------------------------------

    funct3 = 3'b110;

    #10;

    //--------------------------------------------------
    // Test 5 : XOR
    //--------------------------------------------------

    funct3 = 3'b100;

    #10;

    //--------------------------------------------------
    // Test 6 : ADDI
    //--------------------------------------------------

    read_data1 = 25;
    immediate = 10;

    alu_src = 1;

    funct3 = 3'b000;
    funct7 = 7'b0000000;

    #10;

    //--------------------------------------------------
    // Test 7 : Branch Equal
    //--------------------------------------------------

    branch = 1;

    read_data1 = 50;
    read_data2 = 50;

    funct3 = 3'b000;

    pc = 200;
    immediate = 16;

    #10;

    //--------------------------------------------------
    // Test 8 : Branch Not Equal
    //--------------------------------------------------

    read_data1 = 10;
    read_data2 = 20;

    funct3 = 3'b001;

    #10;

    //--------------------------------------------------
    // Test 9 : SLT
    //--------------------------------------------------

    branch = 0;
    alu_src = 0;

    read_data1 = 10;
    read_data2 = 20;

    funct3 = 3'b010;

    #10;

    //--------------------------------------------------
    // Test 10 : SLL
    //--------------------------------------------------

    read_data1 = 4;
    read_data2 = 2;

    funct3 = 3'b001;

    #10;

    $finish;

end

endmodule