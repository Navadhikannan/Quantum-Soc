`timescale 1ns/1ps

module data_memory_tb;

parameter XLEN = 32;

reg clk;
reg mem_read;
reg mem_write;
reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

data_memory DUT(

    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .address(address),
    .write_data(write_data),

    .read_data(read_data)

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

    mem_read = 0;
    mem_write = 0;

    address = 0;
    write_data = 0;

    //------------------------------------------------
    // Test 1
    // Store 100
    //------------------------------------------------

    #10;

    mem_write = 1;
    address = 32'h00000000;
    write_data = 32'd100;

    #10;

    mem_write = 0;

    //------------------------------------------------
    // Read 100
    //------------------------------------------------

    #10;

    mem_read = 1;
    address = 32'h00000000;

    #10;

    //------------------------------------------------
    // Store 250
    //------------------------------------------------

    mem_read = 0;

    #10;

    mem_write = 1;
    address = 32'h00000004;
    write_data = 32'd250;

    #10;

    mem_write = 0;

    //------------------------------------------------
    // Read 250
    //------------------------------------------------

    #10;

    mem_read = 1;
    address = 32'h00000004;

    #10;

    //------------------------------------------------
    // Store DEADBEEF
    //------------------------------------------------

    mem_read = 0;

    #10;

    mem_write = 1;
    address = 32'h00000008;
    write_data = 32'hDEADBEEF;

    #10;

    mem_write = 0;

    //------------------------------------------------
    // Read DEADBEEF
    //------------------------------------------------

    #10;

    mem_read = 1;
    address = 32'h00000008;

    #20;

    $finish;

end

//////////////////////////////////////////////////////
// Waveform
//////////////////////////////////////////////////////

initial
begin
    $dumpfile("data_memory.vcd");
    $dumpvars(0,data_memory_tb);
end

endmodule