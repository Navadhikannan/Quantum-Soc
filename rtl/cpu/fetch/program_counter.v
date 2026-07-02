//============================================================
// Module      : Program Counter
// Project     : QCP-32
// Author      : NavadhiKannan, Monishkanna
// Description : 32-bit Program Counter for QCP-32 Processor
//============================================================

module program_counter #(
    parameter XLEN = 32,
    parameter RESET_PC = 32'h00000000
)(
    input                  clk,
    input                  reset,
    input                  pc_write,
    input      [XLEN-1:0]  next_pc,
    output reg [XLEN-1:0]  pc
);

always @(posedge clk) begin
    if (reset)
        pc <= RESET_PC;
    else if (pc_write)
        pc <= next_pc;
    else
        pc <= pc;      // Hold current PC
end

endmodule