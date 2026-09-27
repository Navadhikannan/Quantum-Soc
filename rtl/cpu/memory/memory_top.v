`timescale 1ns/1ps

module memory_top #(
    parameter XLEN = 32
)(
    input  wire                  clk,
    input  wire                  reset,

    //==========================================================
    // Inputs from EX/MEM Pipeline Register
    //==========================================================

    input  wire [XLEN-1:0]       alu_result,
    input  wire [XLEN-1:0]       rs2_data,
    input  wire [4:0]            rd,

    input  wire                  reg_write,
    input  wire                  mem_read,
    input  wire                  mem_write,
    input  wire                  mem_to_reg,

    //==========================================================
    // Quantum Peripheral Interface
    //==========================================================

    output reg                   quantum_write,
    output reg                   quantum_read,
    output reg  [31:0]           quantum_address,
    output reg  [31:0]           quantum_write_data,

    input  wire [31:0]            quantum_read_data,

    //==========================================================
    // Outputs to Write-Back Stage
    //==========================================================

    output wire [XLEN-1:0]       read_data_out,
    output wire [XLEN-1:0]       alu_result_out,
    output wire [4:0]             rd_out,

    output wire                  reg_write_out,
    output wire                  mem_to_reg_out
);

    //==========================================================
    // Quantum Peripheral Address Range
    //
    // 0x80000000 - 0x8000001F
    //==========================================================

    localparam [31:0] QUANTUM_BASE = 32'h80000000;
    localparam [31:0] QUANTUM_MASK = 32'hFFFFFFE0;

    //==========================================================
    // Internal Signals
    //==========================================================

    wire quantum_access;

    wire normal_mem_read;
    wire normal_mem_write;

    wire [XLEN-1:0] memory_read_data;
    wire [XLEN-1:0] selected_read_data;

    //==========================================================
    // Address Decoder
    //==========================================================

    assign quantum_access =
        ((alu_result & QUANTUM_MASK) == QUANTUM_BASE);

    // Normal RAM must NOT receive quantum peripheral accesses
    assign normal_mem_read =
        mem_read && !quantum_access;

    assign normal_mem_write =
        mem_write && !quantum_access;

    //==========================================================
    // Read Data Selection
    //
    // Normal RAM access:
    //     memory_read_data
    //
    // Quantum peripheral access:
    //     quantum_read_data
    //==========================================================

    assign selected_read_data =
        quantum_access ? quantum_read_data : memory_read_data;

    //==========================================================
    // Quantum Peripheral Interface
    //==========================================================

    always @(*) begin

        // Default values
        quantum_write      = 1'b0;
        quantum_read       = 1'b0;

        quantum_address    = alu_result;
        quantum_write_data = rs2_data;

        // Generate quantum transaction
        if (quantum_access) begin

            if (mem_write)
                quantum_write = 1'b1;

            if (mem_read)
                quantum_read = 1'b1;

        end

    end

    //==========================================================
    // Normal Data Memory
    //==========================================================

    data_memory #(
        .XLEN(XLEN),
        .MEM_DEPTH(256)
    ) DATA_MEMORY
    (
        .clk(clk),

        .mem_read(normal_mem_read),
        .mem_write(normal_mem_write),

        .address(alu_result),
        .write_data(rs2_data),

        .read_data(memory_read_data)
    );

    //==========================================================
    // MEM/WB Pipeline Register
    //==========================================================

    mem_wb #(
        .XLEN(XLEN)
    ) MEM_WB
    (
        .clk(clk),
        .reset(reset),

        .read_data_in(selected_read_data),
        .alu_result_in(alu_result),
        .rd_in(rd),

        .reg_write_in(reg_write),
        .mem_to_reg_in(mem_to_reg),

        .read_data_out(read_data_out),
        .alu_result_out(alu_result_out),
        .rd_out(rd_out),

        .reg_write_out(reg_write_out),
        .mem_to_reg_out(mem_to_reg_out)
    );

endmodule