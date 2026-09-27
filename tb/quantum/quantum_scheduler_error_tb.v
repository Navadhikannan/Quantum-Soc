`timescale 1ns/1ps

module quantum_scheduler_error_tb;

    parameter KEY_WIDTH = 64;

    reg clk;
    reg reset;
    reg start;

    // BB84
    wire bb84_start;
    reg  bb84_done;
    reg  [KEY_WIDTH-1:0] bb84_alice_bits;
    reg  [KEY_WIDTH-1:0] bb84_alice_basis;
    reg  [KEY_WIDTH-1:0] bb84_bob_basis;

    // QKD
    wire qkd_start;
    reg  qkd_done;
    reg  qkd_error;
    reg  [KEY_WIDTH-1:0] qkd_sifted_key;
    reg  [6:0] qkd_key_length;

    // Error correction
    wire ec_start;
    reg  ec_done;
    reg  ec_error;
    reg  [KEY_WIDTH-1:0] ec_corrected_key;

    // Memory
    wire mem_write;
    wire [KEY_WIDTH-1:0] mem_key_data;
    wire [6:0] mem_key_length;

    // Status
    wire busy;
    wire done;
    wire error;


    // ========================================================
    // DUT
    // ========================================================

    quantum_scheduler #(
        .KEY_WIDTH(KEY_WIDTH),
        .MIN_KEY_LENGTH(16)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .start(start),

        .bb84_start(bb84_start),
        .bb84_done(bb84_done),
        .bb84_alice_bits(bb84_alice_bits),
        .bb84_alice_basis(bb84_alice_basis),
        .bb84_bob_basis(bb84_bob_basis),

        .qkd_start(qkd_start),
        .qkd_done(qkd_done),
        .qkd_error(qkd_error),
        .qkd_sifted_key(qkd_sifted_key),
        .qkd_key_length(qkd_key_length),

        .ec_start(ec_start),
        .ec_done(ec_done),
        .ec_error(ec_error),
        .ec_corrected_key(ec_corrected_key),

        .mem_write(mem_write),
        .mem_key_data(mem_key_data),
        .mem_key_length(mem_key_length),

        .busy(busy),
        .done(done),
        .error(error)
    );


    // ========================================================
    // CLOCK
    // ========================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ========================================================
    // TEST
    // ========================================================

    initial begin

        $dumpfile("quantum_scheduler_error.vcd");
        $dumpvars(0, quantum_scheduler_error_tb);

        $display("");
        $display("==============================================");
        $display("      QUANTUM SCHEDULER ERROR TEST");
        $display("==============================================");

        // Initial values
        reset = 1'b1;
        start = 1'b0;

        bb84_done = 1'b0;

        qkd_done  = 1'b0;
        qkd_error = 1'b0;

        ec_done  = 1'b0;
        ec_error = 1'b0;

        bb84_alice_bits  = 64'hA5C396F05A3C69F0;
        bb84_alice_basis = 64'h5A96C30FA5C30F69;
        bb84_bob_basis   = 64'h3C5A69C3A596F00F;

        qkd_sifted_key = 64'h0000000000000000;

        // Deliberately insufficient key
        qkd_key_length = 7'd10;

        ec_corrected_key = 64'h0000000000000000;


        // Reset
        repeat (2) @(posedge clk);

        reset = 1'b0;

        $display("Reset released.");


        // ====================================================
        // Start scheduler
        // ====================================================

        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        $display("Scheduler started.");


        // ====================================================
        // BB84 completion
        // ====================================================

        wait(bb84_start == 1'b1);

        $display("BB84 start asserted.");

        @(negedge clk);
        bb84_done = 1'b1;

        @(negedge clk);
        bb84_done = 1'b0;

        $display("BB84 completed.");


        // ====================================================
        // QKD completion with insufficient key
        // ====================================================

        wait(qkd_start == 1'b1);

        $display("QKD sifting started.");
        $display("QKD Key Length = %0d", qkd_key_length);

        @(negedge clk);
        qkd_done = 1'b1;

        @(negedge clk);
        qkd_done = 1'b0;

        $display("QKD sifting completed.");


        // ====================================================
        // Wait for scheduler error
        // ====================================================

        wait(done == 1'b1);

        #1;

        $display("");
        $display("--------------- ERROR RESULT ----------------");
        $display("Done                    = %b", done);
        $display("Error                   = %b", error);
        $display("Error Correction Start  = %b", ec_start);
        $display("Memory Write            = %b", mem_write);
        $display("----------------------------------------------");


        // ====================================================
        // Verification
        // ====================================================

        if ((done == 1'b1) &&
            (error == 1'b1) &&
            (ec_start == 1'b0) &&
            (mem_write == 1'b0)) begin

            $display("");
            $display("[PASS] Insufficient-key error handled correctly.");
            $display("[PASS] Error correction was skipped.");
            $display("[PASS] Invalid key was not written to memory.");

        end

        else begin

            $display("");
            $display("[FAIL] Error-path verification failed.");

        end


        $display("");
        $display("==============================================");
        $display("     SCHEDULER ERROR TEST COMPLETED");
        $display("==============================================");

        #20;
        $finish;

    end

endmodule