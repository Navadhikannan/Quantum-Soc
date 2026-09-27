`timescale 1ns/1ps

module quantum_domain_top_tb;

    parameter KEY_WIDTH = 64;

    reg clk;
    reg reset;
    reg start;

    wire [KEY_WIDTH-1:0] key_data;
    wire [6:0]           key_length;
    wire                 key_valid;

    wire busy;
    wire done;
    wire error;

    // ========================================================
    // DUT
    // ========================================================

    quantum_domain_top #(
        .KEY_WIDTH(KEY_WIDTH),
        .MIN_KEY_LENGTH(16)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .start(start),

        .key_data(key_data),
        .key_length(key_length),
        .key_valid(key_valid),

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

        $dumpfile("quantum_domain_top.vcd");
        $dumpvars(0, quantum_domain_top_tb);

        $display("");
        $display("================================================");
        $display("       QUANTUM DOMAIN INTEGRATION TEST");
        $display("================================================");

        // ----------------------------------------------------
        // Initial conditions
        // ----------------------------------------------------

        reset = 1'b1;
        start = 1'b0;

        // ----------------------------------------------------
        // Reset
        // ----------------------------------------------------

        repeat (2) @(posedge clk);

        reset = 1'b0;

        $display("Reset released.");

        // ----------------------------------------------------
        // Start quantum-domain operation
        // ----------------------------------------------------

        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        $display("Quantum-domain operation started.");

        // ----------------------------------------------------
        // Wait for scheduler completion
        // ----------------------------------------------------

        wait(done == 1'b1);

        #1;

        $display("");
        $display("---------------- FINAL RESULT ----------------");
        $display("Busy              = %b", busy);
        $display("Done              = %b", done);
        $display("Error             = %b", error);
        $display("Key Valid         = %b", key_valid);
        $display("Final Key         = %016h", key_data);
        $display("Final Key Length  = %0d", key_length);
        $display("----------------------------------------------");


        // ----------------------------------------------------
        // Verification
        // ----------------------------------------------------

        if ((done == 1'b1) &&
            (error == 1'b0) &&
            (key_valid == 1'b1) &&
            (key_length >= 16)) begin

            $display("");
            $display("[PASS] Quantum domain completed successfully.");
            $display("[PASS] Final key stored in quantum memory.");

            $display("");
            $display("================================================");
            $display("       QUANTUM DOMAIN TEST PASSED");
            $display("================================================");

        end

        else begin

            $display("");
            $display("[FAIL] Quantum domain verification failed.");

            $display("");
            $display("================================================");
            $display("       QUANTUM DOMAIN TEST FAILED");
            $display("================================================");

        end

        #20;
        $finish;

    end

endmodule