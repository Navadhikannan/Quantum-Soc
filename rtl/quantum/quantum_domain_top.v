module quantum_domain_top #(
    parameter KEY_WIDTH = 64,
    parameter MIN_KEY_LENGTH = 16
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 start,

    // Final quantum-domain outputs
    output wire [KEY_WIDTH-1:0] key_data,
    output wire [6:0]           key_length,
    output wire                 key_valid,

    output wire                 busy,
    output wire                 done,
    output wire                 error
);

    // ========================================================
    // BB84 signals
    // ========================================================

    wire bb84_start;
    wire bb84_done;

    wire [KEY_WIDTH-1:0] alice_bits;
    wire [KEY_WIDTH-1:0] alice_basis;
    wire [KEY_WIDTH-1:0] bob_basis;
    wire [KEY_WIDTH-1:0] bob_measurement;


    // ========================================================
    // QKD signals
    // ========================================================

    wire qkd_start;
    wire qkd_done;
    wire qkd_error;

    wire [KEY_WIDTH-1:0] sifted_key;
    wire [KEY_WIDTH-1:0] basis_match_mask;
    wire [6:0] qkd_key_length;


    // ========================================================
    // Error reconciliation signals
    // ========================================================

    wire ec_start;
    wire ec_done;
    wire ec_error;

    wire [KEY_WIDTH-1:0] corrected_key;


    // ========================================================
    // Memory signals
    // ========================================================

    wire mem_write;
    wire [KEY_WIDTH-1:0] mem_key_data;
    wire [6:0] mem_key_length;


    // ========================================================
    // BB84 INTERFACE
    // ========================================================

    bb84_interface #(
        .KEY_WIDTH(KEY_WIDTH)
    ) u_bb84 (
        .clk(clk),
        .reset(reset),
        .start(bb84_start),

        .alice_bits(alice_bits),
        .alice_basis(alice_basis),

        .bob_basis(bob_basis),
        .bob_measurement(bob_measurement),

        .done(bb84_done)
    );


    // ========================================================
    // QKD SIFTING ENGINE
    // ========================================================

    qkd_engine #(
        .KEY_WIDTH(KEY_WIDTH),
        .MIN_KEY_LENGTH(MIN_KEY_LENGTH)
    ) u_qkd (
        .clk(clk),
        .reset(reset),
        .start(qkd_start),

        .alice_bits(alice_bits),
        .alice_basis(alice_basis),
        .bob_basis(bob_basis),

        .sifted_key(sifted_key),
        .basis_match_mask(basis_match_mask),
        .key_length(qkd_key_length),

        .done(qkd_done),
        .error(qkd_error)
    );


    // ========================================================
    // ERROR RECONCILIATION
    // ========================================================

    /*
     * For this initial integration, the reference key is
     * connected to the sifted key. This represents the
     * no-error reference case for functional verification.
     *
     * A later version can replace this with an independently
     * generated/authenticated reference sequence.
     */

    error_correction_engine #(
        .KEY_WIDTH(KEY_WIDTH),
        .BLOCK_SIZE(8)
    ) u_error_correction (
        .clk(clk),
        .reset(reset),
        .start(ec_start),

        .sifted_key(sifted_key),
        .reference_key(sifted_key),

        .corrected_key(corrected_key),
        .error_detected(ec_error),
        .done(ec_done)
    );


    // ========================================================
    // QUANTUM MEMORY CONTROLLER
    // ========================================================

    quantum_memory_controller #(
        .KEY_WIDTH(KEY_WIDTH)
    ) u_memory (
        .clk(clk),
        .reset(reset),

        .write_enable(mem_write),
        .key_in(mem_key_data),
        .key_length_in(mem_key_length),

        .key_out(key_data),
        .key_length_out(key_length),
        .key_valid(key_valid)
    );


    // ========================================================
    // QUANTUM SCHEDULER
    // ========================================================

    quantum_scheduler #(
        .KEY_WIDTH(KEY_WIDTH),
        .MIN_KEY_LENGTH(MIN_KEY_LENGTH)
    ) u_scheduler (
        .clk(clk),
        .reset(reset),
        .start(start),

        // BB84
        .bb84_start(bb84_start),
        .bb84_done(bb84_done),

        .bb84_alice_bits(alice_bits),
        .bb84_alice_basis(alice_basis),
        .bb84_bob_basis(bob_basis),

        // QKD
        .qkd_start(qkd_start),
        .qkd_done(qkd_done),
        .qkd_error(qkd_error),

        .qkd_sifted_key(sifted_key),
        .qkd_key_length(qkd_key_length),

        // Error correction
        .ec_start(ec_start),
        .ec_done(ec_done),
        .ec_error(ec_error),

        .ec_corrected_key(corrected_key),

        // Memory
        .mem_write(mem_write),
        .mem_key_data(mem_key_data),
        .mem_key_length(mem_key_length),

        // Status
        .busy(busy),
        .done(done),
        .error(error)
    );

endmodule