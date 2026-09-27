`timescale 1ns/1ps

module quantum_memory_controller #(
    parameter KEY_WIDTH = 64
)(
    input  wire                  clk,
    input  wire                  reset,

    // Write interface
    input  wire                  write_enable,
    input  wire [KEY_WIDTH-1:0]  key_in,
    input  wire [6:0]            key_length_in,

    // Read interface
    output reg  [KEY_WIDTH-1:0]  key_out,
    output reg  [6:0]            key_length_out,
    output reg                   key_valid
);

    // --------------------------------------------------------
    // Quantum key storage
    // --------------------------------------------------------

    reg [KEY_WIDTH-1:0] key_memory;
    reg [6:0] key_length_memory;

    // --------------------------------------------------------
    // Write operation
    // --------------------------------------------------------

    always @(posedge clk) begin

        if (reset) begin

            key_memory        <= {KEY_WIDTH{1'b0}};
            key_length_memory <= 7'd0;
            key_valid         <= 1'b0;

        end

        else begin

            if (write_enable) begin

                key_memory        <= key_in;
                key_length_memory <= key_length_in;
                key_valid         <= 1'b1;

            end

        end

    end

    // --------------------------------------------------------
    // Read operation
    // --------------------------------------------------------

    always @(*) begin

        key_out        = key_memory;
        key_length_out = key_length_memory;

    end

endmodule