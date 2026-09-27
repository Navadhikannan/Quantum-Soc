`timescale 1ns/1ps

module quantum_scheduler_tb;

    parameter KEY_WIDTH = 64;

    reg clk;
    reg reset;
    reg start;

    // BB84 interface
    wire bb84_start;
    reg  bb84_done;

    reg [KEY_WIDTH-1:0] bb84_alice_bits;
    reg [KEY_WIDTH-1:0] bb84_alice_basis;
    reg [KEY_WIDTH-1:0] bb84_bob_basis;

    // QKD engine
    wire qkd_start;
    reg  qkd_done;
    reg  qkd_error;

    reg [KEY_WIDTH-1:0] qkd_sifted_key;
    reg [6:0] qkd_key_length;

    // Error correction
    wire ec_start;
    reg  ec_done;
    reg  ec_error;

    reg [KEY_WIDTH-1:0] ec_corrected_key;

    // Memory
    wire mem_write;
    wire [KEY_WIDTH-1:0] mem_key_data;
    wire [6:0] mem_key_length;

    // Status
    wire busy;
    wire done;
    wire error;


    // ------------------------------------------------
    // DUT
    // ------------------------------------------------

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


    // ------------------------------------------------
    // Clock
    // ------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ------------------------------------------------
    // Scheduler test
    // ------------------------------------------------

    initial begin

        $dumpfile("quantum_scheduler.vcd");
        $dumpvars(0, quantum_scheduler_tb);

        $display("");
        $display("==============================================");
        $display("        QUANTUM SCHEDULER TEST");
        $display("==============================================");

        // Initial conditions
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

        qkd_sifted_key = 64'h810314305A280090;
        qkd_key_length = 7'd32;

        ec_corrected_key = 64'h810314305A280090;

        repeat (2) @(posedge clk);

        reset = 1'b0;

        $display("Reset released.");

        // ------------------------------------------------
        // Start complete QKD sequence
        // ------------------------------------------------

        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        $display("Scheduler started.");

        // ------------------------------------------------
        // BB84
        // ------------------------------------------------

        wait(bb84_start == 1'b1);

        $display("BB84 start asserted.");

        @(negedge clk);
        bb84_done = 1'b1;

        @(negedge clk);
        bb84_done = 1'b0;

        $display("BB84 completed.");


        // ------------------------------------------------
        // QKD Sifting
        // ------------------------------------------------

        wait(qkd_start == 1'b1);

        $display("QKD sifting start asserted.");

        @(negedge clk);
        qkd_done = 1'b1;

        @(negedge clk);
        qkd_done = 1'b0;

        $display("QKD sifting completed.");


        // ------------------------------------------------
        // Error Reconciliation
        // ------------------------------------------------

        wait(ec_start == 1'b1);

        $display("Error reconciliation start asserted.");

        @(negedge clk);
        ec_done = 1'b1;

        @(negedge clk);
        ec_done = 1'b0;

        $display("Error reconciliation completed.");


        // ------------------------------------------------
        // Wait for final result
        // ------------------------------------------------

        wait(done == 1'b1);

        #1;

        $display("");
        $display("--------------- FINAL RESULT ----------------");
        $display("Busy             = %b", busy);
        $display("Done             = %b", done);
        $display("Error            = %b", error);
        $display("Memory Write     = %b", mem_write);
        $display("Stored Key       = %016h", mem_key_data);
        $display("Stored Key Length= %0d", mem_key_length);
        $display("----------------------------------------------");


        // ------------------------------------------------
        // Verification
        // ------------------------------------------------

        if ((done == 1'b1) &&
            (error == 1'b0) &&
            (mem_key_data == 64'h810314305A280090) &&
            (mem_key_length == 7'd32)) begin

            $display("[PASS] Quantum scheduler completed successfully.");
            $display("[PASS] Corrected key reached memory interface.");

        end
        else begin

            $display("[FAIL] Scheduler result is incorrect.");

        end


        $display("");
        $display("==============================================");
        $display("       QUANTUM SCHEDULER TEST COMPLETED");
        $display("==============================================");

        #20;
        $finish;

    end

endmodule