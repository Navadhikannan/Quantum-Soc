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

    initial begin
        $readmemh(MEM_FILE, memory);
    end

    //========================================================
    // Asynchronous Read
    //========================================================

    assign instruction = memory[address[9:2]];

endmodule