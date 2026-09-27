`timescale 1ns/1ps

module error_correction_engine #(
    parameter KEY_WIDTH = 64,
    parameter BLOCK_SIZE = 8
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  start,

    input  wire [KEY_WIDTH-1:0]  sifted_key,
    input  wire [KEY_WIDTH-1:0]  reference_key,

    output reg  [KEY_WIDTH-1:0]  corrected_key,
    output reg                   error_detected,
    output reg                   done
);

    localparam IDLE  = 2'd0;
    localparam CHECK = 2'd1;
    localparam DONE  = 2'd2;

    reg [1:0] state;

    integer i;
    reg parity_key;
    reg parity_ref;

    always @(posedge clk) begin

        if (reset) begin
            state          <= IDLE;
            corrected_key  <= {KEY_WIDTH{1'b0}};
            error_detected <= 1'b0;
            done           <= 1'b0;
        end

        else begin

            case (state)

                // -----------------------------------------
                // IDLE
                // -----------------------------------------
                IDLE: begin

                    done           <= 1'b0;
                    error_detected <= 1'b0;

                    if (start)
                        state <= CHECK;

                end

                // -----------------------------------------
                // CHECK
                // -----------------------------------------
                CHECK: begin

                    corrected_key  <= sifted_key;
                    error_detected <= 1'b0;

                    /*
                     * Compare each 8-bit block using parity.
                     * This is a simplified reconciliation model
                     * for RTL functional verification.
                     */
                    for (i = 0; i < KEY_WIDTH; i = i + BLOCK_SIZE) begin

                        parity_key = ^sifted_key[i +: BLOCK_SIZE];
                        parity_ref = ^reference_key[i +: BLOCK_SIZE];

                        if (parity_key != parity_ref) begin
                            error_detected <= 1'b1;

                            /*
                             * Simplified correction:
                             * flip the least-significant bit
                             * of the affected block.
                             */
                            corrected_key[i] <= ~sifted_key[i];
                        end

                    end

                    state <= DONE;

                end

                // -----------------------------------------
                // DONE
                // -----------------------------------------
                DONE: begin

                    done <= 1'b1;

                    if (start) begin
                        done  <= 1'b0;
                        state <= CHECK;
                    end

                end

                default: begin
                    state <= IDLE;
                    done  <= 1'b0;
                    error_detected <= 1'b0;
                end

            endcase

        end
    end

endmodule