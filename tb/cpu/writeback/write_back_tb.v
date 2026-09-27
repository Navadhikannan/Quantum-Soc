`timescale 1ns/1ps

module write_back_tb;

parameter XLEN = 32;

reg [31:0] read_data;
reg [31:0] alu_result;

reg mem_to_reg;

wire [31:0] write_back_data;


// DUT


write_back DUT
(
    .read_data(read_data),
    .alu_result(alu_result),

    .mem_to_reg(mem_to_reg),

    .write_back_data(write_back_data)
);


// Test Cases


initial
begin

    
    // Test 1
    // ALU Result
   

    alu_result = 32'd50;
    read_data = 32'd100;

    mem_to_reg = 0;

    #10;

    
    // Test 2
    // Memory Read


    alu_result = 32'd250;
    read_data = 32'd500;

    mem_to_reg = 1;

    #10;

    // Test 3
    // ALU Result
    

    alu_result = 32'hDEADBEEF;
    read_data = 32'hAAAAAAAA;

    mem_to_reg = 0;

    #10;

    
    // Test 4
    // Memory Read
   

    alu_result = 32'h11111111;
    read_data = 32'hCAFEBABE;

    mem_to_reg = 1;

    #10;

    //------------------------------------------------

    $finish;

end

// Waveform


initial
begin
    $dumpfile("write_back.vcd");
    $dumpvars(0,write_back_tb);
end

endmodule