`timescale 1ns/1ps

module bb84_interface #(
    parameter KEY_WIDTH = 64
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 start,

    output reg  [KEY_WIDTH-1:0] alice_bits,
    output reg  [KEY_WIDTH-1:0] alice_basis,

    output reg  [KEY_WIDTH-1:0] bob_basis,
    output reg  [KEY_WIDTH-1:0] bob_measurement,

    output reg                  done
);

    // FSM states
    localparam IDLE    = 3'd0;
    localparam GENERATE = 3'd1;
    localparam MEASURE = 3'd2;
    localparam DONE    = 3'd3;

    reg [2:0] state;

    /*
     * Deterministic test vectors.
     *
     * These values are used only for RTL functional verification.
     * They are NOT intended to represent a cryptographically
     * secure randomness source.
     */
    localparam [KEY_WIDTH-1:0] TEST_ALICE_BITS =
        64'hA5C3_96F0_5A3C_69F0;

    localparam [KEY_WIDTH-1:0] TEST_ALICE_BASIS =
        64'h5A96_C30F_A5C3_0F69;

    localparam [KEY_WIDTH-1:0] TEST_BOB_BASIS =
        64'h3C5A_69C3_A596_F00F;

    integer i;

    always @(posedge clk) begin

        if (reset) begin

            state           <= IDLE;

            alice_bits      <= {KEY_WIDTH{1'b0}};
            alice_basis     <= {KEY_WIDTH{1'b0}};

            bob_basis       <= {KEY_WIDTH{1'b0}};
            bob_measurement <= {KEY_WIDTH{1'b0}};

            done            <= 1'b0;

        end
        else begin

            case (state)

                // ------------------------------------------------
                // IDLE
                // ------------------------------------------------
                IDLE: begin

                    done <= 1'b0;

                    if (start)
                        state <= GENERATE;

                end


                // ------------------------------------------------
                // GENERATE
                // Alice prepares bits and basis choices
                // ------------------------------------------------
                GENERATE: begin

                    alice_bits  <= TEST_ALICE_BITS;
                    alice_basis <= TEST_ALICE_BASIS;

                    bob_basis   <= TEST_BOB_BASIS;

                    state <= MEASURE;

                end


                // ------------------------------------------------
                // MEASURE
                // Bob measures according to his selected basis.
                //
                // For the RTL abstraction:
                //   matching basis -> Alice bit is recovered
                //   different basis -> deterministic test value
                // ------------------------------------------------
                MEASURE: begin

                    for (i = 0; i < KEY_WIDTH; i = i + 1) begin

                        if (alice_basis[i] == bob_basis[i])
                            bob_measurement[i] <= alice_bits[i];
                        else
                            bob_measurement[i] <= 1'b0;

                    end

                    state <= DONE;

                end


                // ------------------------------------------------
                // DONE
                // ------------------------------------------------
                DONE: begin

                    done <= 1'b1;

                    /*
                     * Hold all generated data until a new
                     * start operation is requested.
                     */
                    if (start) begin
                        done  <= 1'b0;
                        state <= GENERATE;
                    end

                end


                default: begin

                    state <= IDLE;
                    done  <= 1'b0;

                end

            endcase

        end

    end

endmodule