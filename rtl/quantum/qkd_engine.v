module qkd_engine #(
    parameter KEY_WIDTH = 64,
    parameter MIN_KEY_LENGTH = 16
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  start,

    input  wire [KEY_WIDTH-1:0]  alice_bits,
    input  wire [KEY_WIDTH-1:0]  alice_basis,
    input  wire [KEY_WIDTH-1:0]  bob_basis,

    output reg  [KEY_WIDTH-1:0]  sifted_key,
    output reg  [KEY_WIDTH-1:0]  basis_match_mask,
    output reg  [6:0]            key_length,

    output reg                   done,
    output reg                   error
);

    localparam IDLE    = 2'd0;
    localparam SIFT    = 2'd1;
    localparam CHECK   = 2'd2;
    localparam DONE    = 2'd3;

    reg [1:0] state;

    integer i;
    integer count;

    always @(posedge clk) begin

        if (reset) begin
            state            <= IDLE;
            sifted_key       <= {KEY_WIDTH{1'b0}};
            basis_match_mask <= {KEY_WIDTH{1'b0}};
            key_length       <= 7'd0;
            done              <= 1'b0;
            error             <= 1'b0;
        end
        else begin

            case (state)

                // --------------------------------------------
                // IDLE
                // --------------------------------------------
                IDLE: begin
                    done  <= 1'b0;
                    error <= 1'b0;

                    if (start)
                        state <= SIFT;
                end

                // --------------------------------------------
                // SIFT
                // --------------------------------------------
                SIFT: begin

                    sifted_key       <= {KEY_WIDTH{1'b0}};
                    basis_match_mask <= {KEY_WIDTH{1'b0}};

                    count = 0;

                    for (i = 0; i < KEY_WIDTH; i = i + 1) begin

                        if (alice_basis[i] == bob_basis[i]) begin
                            sifted_key[i]       <= alice_bits[i];
                            basis_match_mask[i] <= 1'b1;
                            count = count + 1;
                        end

                    end

                    key_length <= count;

                    state <= CHECK;
                end

                // --------------------------------------------
                // CHECK
                // --------------------------------------------
                CHECK: begin

                    if (key_length < MIN_KEY_LENGTH)
                        error <= 1'b1;
                    else
                        error <= 1'b0;

                    state <= DONE;
                end

                // --------------------------------------------
                // DONE
                // --------------------------------------------
                DONE: begin

                    done <= 1'b1;

                    if (start) begin
                        done  <= 1'b0;
                        error <= 1'b0;
                        state <= SIFT;
                    end

                end

                default: begin
                    state <= IDLE;
                    done  <= 1'b0;
                    error <= 1'b0;
                end

            endcase

        end
    end

endmodule