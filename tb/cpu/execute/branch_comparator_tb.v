`timescale 1ns/1ps

module branch_comparator_tb;

reg [31:0] rs1_data;
reg [31:0] rs2_data;
reg [2:0]  funct3;

wire branch_taken;

branch_comparator dut(

    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .funct3(funct3),
    .branch_taken(branch_taken)

);

initial begin

    $dumpfile("branch_comparator.vcd");
    $dumpvars(0,branch_comparator_tb);

    $display("----------------------------------------");
    $display(" BRANCH COMPARATOR TEST STARTED ");
    $display("----------------------------------------");

    // BEQ (True)
    rs1_data = 32'd25;
    rs2_data = 32'd25;
    funct3   = 3'b000;
    #10;

    // BNE (True)
    rs1_data = 32'd20;
    rs2_data = 32'd30;
    funct3   = 3'b001;
    #10;

    // BLT (True)
    rs1_data = -32'd5;
    rs2_data = 32'd10;
    funct3   = 3'b100;
    #10;

    // BGE (True)
    rs1_data = 32'd15;
    rs2_data = 32'd10;
    funct3   = 3'b101;
    #10;

    // BLTU (True)
    rs1_data = 32'd5;
    rs2_data = 32'd10;
    funct3   = 3'b110;
    #10;

    // BGEU (True)
    rs1_data = 32'd20;
    rs2_data = 32'd10;
    funct3   = 3'b111;
    #10;

    // BEQ (False)
    rs1_data = 32'd10;
    rs2_data = 32'd20;
    funct3   = 3'b000;
    #10;

    // BNE (False)
    rs1_data = 32'd30;
    rs2_data = 32'd30;
    funct3   = 3'b001;
    #10;

    $display("----------------------------------------");
    $display(" BRANCH COMPARATOR TEST COMPLETED ");
    $display("----------------------------------------");

    $finish;

end

initial begin

    $monitor("Time=%0t | funct3=%b | rs1=%0d | rs2=%0d | branch_taken=%b",
              $time,funct3,rs1_data,rs2_data,branch_taken);

end

endmodule