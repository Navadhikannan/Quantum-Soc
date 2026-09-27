`timescale 1ns/1ps

module quantum_scheduler #(
    parameter KEY_WIDTH = 64,
    parameter MIN_KEY_LENGTH = 16
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  start,

    // ========================================================
    // BB84 Interface
    // ========================================================
    output reg                   bb84_start,
    input  wire                  bb84_done,

    input  wire [KEY_WIDTH-1:0]  bb84_alice_bits,
    input  wire [KEY_WIDTH-1:0]  bb84_alice_basis,
    input  wire [KEY_WIDTH-1:0]  bb84_bob_basis,

    // ========================================================
    // QKD Sifting Engine
    // ========================================================
    output reg                   qkd_start,
    input  wire                  qkd_done,
    input  wire                  qkd_error,

    input  wire [KEY_WIDTH-1:0]  qkd_sifted_key,
    input  wire [6:0]            qkd_key_length,

    // ========================================================
    // Error Correction Engine
    // ========================================================
    output reg                   ec_start,
    input  wire                  ec_done,
    input  wire                  ec_error,

    input  wire [KEY_WIDTH-1:0]  ec_corrected_key,

    // ========================================================
    // Quantum Memory
    // ========================================================
    output reg                   mem_write,
    output reg [KEY_WIDTH-1:0]   mem_key_data,
    output reg [6:0]             mem_key_length,

    // ========================================================
    // Status
    // ========================================================
    output reg                   busy,
    output reg                   done,
    output reg                   error
);

    // ========================================================
    // FSM STATES
    // ========================================================

    localparam S_IDLE       = 4'd0;
    localparam S_START_BB84 = 4'd1;
    localparam S_WAIT_BB84  = 4'd2;
    localparam S_START_QKD  = 4'd3;
    localparam S_WAIT_QKD   = 4'd4;
    localparam S_START_EC   = 4'd5;
    localparam S_WAIT_EC    = 4'd6;
    localparam S_STORE_KEY  = 4'd7;
    localparam S_DONE       = 4'd8;
    localparam S_ERROR      = 4'd9;

    reg [3:0] state;

    // ========================================================
    // INTERNAL REGISTERS
    // ========================================================

    reg [KEY_WIDTH-1:0] corrected_key_reg;
    reg [6:0]           key_length_reg;

    // ========================================================
    // SEQUENTIAL FSM
    // ========================================================

    always @(posedge clk) begin

        if (reset) begin

            state <= S_IDLE;

            // Control signals
            bb84_start <= 1'b0;
            qkd_start  <= 1'b0;
            ec_start   <= 1'b0;
            mem_write  <= 1'b0;

            // Status
            busy  <= 1'b0;
            done  <= 1'b0;
            error <= 1'b0;

            // Memory interface
            mem_key_data   <= {KEY_WIDTH{1'b0}};
            mem_key_length <= 7'd0;

            // Internal registers
            corrected_key_reg <= {KEY_WIDTH{1'b0}};
            key_length_reg    <= 7'd0;

        end

        else begin

            // ------------------------------------------------
            // Default values for one-cycle control pulses
            // ------------------------------------------------

            bb84_start <= 1'b0;
            qkd_start  <= 1'b0;
            ec_start   <= 1'b0;
            mem_write  <= 1'b0;

            // ------------------------------------------------
            // FSM
            // ------------------------------------------------

            case (state)

                // ============================================
                // IDLE
                // ============================================

                S_IDLE: begin

                    busy  <= 1'b0;
                    done  <= 1'b0;
                    error <= 1'b0;

                    if (start) begin
                        busy  <= 1'b1;
                        state <= S_START_BB84;
                    end

                end


                // ============================================
                // START BB84
                // ============================================

                S_START_BB84: begin

                    bb84_start <= 1'b1;

                    state <= S_WAIT_BB84;

                end


                // ============================================
                // WAIT FOR BB84
                // ============================================

                S_WAIT_BB84: begin

                    if (bb84_done) begin
                        state <= S_START_QKD;
                    end

                end


                // ============================================
                // START QKD SIFTING
                // ============================================

                S_START_QKD: begin

                    qkd_start <= 1'b1;

                    state <= S_WAIT_QKD;

                end


                // ============================================
                // WAIT FOR QKD SIFTING
                // ============================================

                S_WAIT_QKD: begin

                    if (qkd_done) begin

                        if (qkd_error ||
                            (qkd_key_length < MIN_KEY_LENGTH)) begin

                            error <= 1'b1;
                            state <= S_ERROR;

                        end

                        else begin

                            key_length_reg <= qkd_key_length;

                            state <= S_START_EC;

                        end

                    end

                end


                // ============================================
                // START ERROR CORRECTION
                // ============================================

                S_START_EC: begin

                    ec_start <= 1'b1;

                    state <= S_WAIT_EC;

                end


                // ============================================
                // WAIT FOR ERROR CORRECTION
                // ============================================

                S_WAIT_EC: begin

                    if (ec_done) begin

                        if (ec_error) begin

                            error <= 1'b1;
                            state <= S_ERROR;

                        end

                        else begin

                            corrected_key_reg <= ec_corrected_key;

                            state <= S_STORE_KEY;

                        end

                    end

                end


                // ============================================
                // STORE KEY
                // ============================================

                S_STORE_KEY: begin

                    mem_key_data   <= corrected_key_reg;
                    mem_key_length <= key_length_reg;

                    mem_write <= 1'b1;

                    state <= S_DONE;

                end


                // ============================================
                // DONE
                // ============================================

                S_DONE: begin

                    busy  <= 1'b0;
                    done  <= 1'b1;
                    error <= 1'b0;

                    // Hold DONE until a new operation is requested
                    if (start) begin

                        busy  <= 1'b1;
                        done  <= 1'b0;
                        error <= 1'b0;

                        state <= S_START_BB84;

                    end

                end


                // ============================================
                // ERROR
                // ============================================

                S_ERROR: begin

                    busy  <= 1'b0;
                    done  <= 1'b1;
                    error <= 1'b1;

                    // Hold ERROR/DONE until a new operation
                    // is requested
                    if (start) begin

                        busy  <= 1'b1;
                        done  <= 1'b0;
                        error <= 1'b0;

                        state <= S_START_BB84;

                    end

                end


                // ============================================
                // DEFAULT
                // ============================================

                default: begin

                    state <= S_IDLE;

                    busy  <= 1'b0;
                    done  <= 1'b0;
                    error <= 1'b0;

                end

            endcase

        end

    end

endmodule