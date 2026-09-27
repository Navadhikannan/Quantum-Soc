`timescale 1ns/1ps

module instruction_decoder_tb;

parameter XLEN = 32;


// Inputs


reg [XLEN-1:0] instruction;


// Outputs


wire [6:0] opcode;
wire [4:0] rd;
wire [2:0] funct3;
wire [4:0] rs1;
wire [4:0] rs2;
wire [6:0] funct7;


// DUT


instruction_decoder #(
    .XLEN(XLEN)
) dut (

    .instruction(instruction),

    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7)

);


// Test Sequence


initial begin

    $dumpfile("instruction_decoder.vcd");
    $dumpvars(0, instruction_decoder_tb);

    
    // R-Type : ADD x5, x6, x7
   

    instruction = 32'b0000000_00111_00110_000_00101_0110011;
    #10;

    
    // R-Type : SUB x5, x6, x7
   

    instruction = 32'b0100000_00111_00110_000_00101_0110011;
    #10;

   
    // I-Type : ADDI x5, x6, 10
  

    instruction = 32'b000000001010_00110_000_00101_0010011;
    #10;


    // Load : LW x5, 8(x6)


    instruction = 32'b000000001000_00110_010_00101_0000011;
    #10;

   
    // Store : SW x7, 8(x6)
   

    instruction = 32'b0000000_00111_00110_010_01000_0100011;
    #10;

  
    // Branch : BEQ x6, x7
   

    instruction = 32'b0000000_00111_00110_000_01000_1100011;
    #10;


    // JAL
  

    instruction = 32'b00000000000000000001_00101_1101111;
    #10;

    $finish;

end

// Monitor


initial begin

$monitor(
"Time=%0t | Instr=%h | Opcode=%b | rd=%0d | funct3=%b | rs1=%0d | rs2=%0d | funct7=%b",
    $time,
    instruction,
    opcode,
    rd,
    funct3,
    rs1,
    rs2,
    funct7
);

end

endmodule