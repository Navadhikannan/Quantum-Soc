
`timescale 1ns/1ps

module quantum_classical_soc #(
    parameter IMEM_WORDS = 256,
    parameter DMEM_WORDS = 256,
    parameter BASE_ADDR  = 0
) (
    input logic clk,
    input logic reset
);

    // V2 CPU core includes the AXI4-Lite interconnect,
    // AXI RAM slave, and QKD peripheral slave.
    rv32i_core #(
        .IMEM_WORDS(IMEM_WORDS),
        .DMEM_WORDS(DMEM_WORDS),
        .BASE_ADDR(BASE_ADDR)
    ) CPU_CORE (
        .clk   (clk),
        .reset (reset)
    );

endmodule
