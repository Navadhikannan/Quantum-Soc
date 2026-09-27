//============================================================
// Module      : Instruction Memory
// Project     : QSoc
// Author      : Navadhi Kannan, Monishkanna
// Description : 256 x 32-bit Instruction ROM
//============================================================

module instruction_memory #(
    parameter XLEN = 32,
    parameter DEPTH = 256,
    parameter MEM_FILE = "sim/hex/program.hex"
)(
    input  wire [XLEN-1:0] address,
    output wire [XLEN-1:0] instruction
);

    //========================================================
    // Instruction Memory
    //========================================================

    reg [XLEN-1:0] memory [0:DEPTH-1];

    //========================================================
    // Load Program
    //========================================================

    integer i;

 initial begin
    // Initialize all memory locations to NOP
    for (i = 0; i < DEPTH; i = i + 1)
        memory[i] = 32'h00000013;

    // Load your program over the initialized memory
    $readmemh(MEM_FILE, memory);
    end

    //========================================================
    // Asynchronous Read
    //========================================================

    assign instruction = memory[address[9:2]];

endmodule