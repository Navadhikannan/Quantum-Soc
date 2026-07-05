//============================================================
// Module      : IF/ID Pipeline Register
// Project     : QSoc
// Author      : NavadhiKannan, Monishkanna
// Description : Pipeline register between IF and ID stages
//============================================================

module if_id #(
    parameter XLEN = 32
)(
    input  wire             clk,
    input  wire             reset,
    input  wire             write_enable,

    input  wire [XLEN-1:0]  pc_in,
    input  wire [31:0]      instruction_in,

    output reg  [XLEN-1:0]  pc_out,
    output reg  [31:0]      instruction_out
);

always @(posedge clk) begin

    if (reset) begin
        pc_out          <= 0;
        instruction_out <= 0;
    end

    else if (write_enable) begin
        pc_out          <= pc_in;
        instruction_out <= instruction_in;
    end

end

endmodule