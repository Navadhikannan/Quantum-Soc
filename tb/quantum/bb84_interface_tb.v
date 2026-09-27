`timescale 1ns/1ps

module bb84_interface_tb;

    parameter KEY_WIDTH = 64;

    reg clk;
    reg reset;
    reg start;

    wire [KEY_WIDTH-1:0] alice_bits;
    wire [KEY_WIDTH-1:0] alice_basis;
    wire [KEY_WIDTH-1:0] bob_basis;
    wire [KEY_WIDTH-1:0] bob_measurement;
    wire done;

    bb84_interface #(
        .KEY_WIDTH(KEY_WIDTH)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .start(start),
        .alice_bits(alice_bits),
        .alice_basis(alice_basis),
        .bob_basis(bob_basis),
        .bob_measurement(bob_measurement),
        .done(done)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("bb84_interface.vcd");
        $dumpvars(0, bb84_interface_tb);

        $display("");
        $display("==============================================");
        $display("        BB84 INTERFACE TESTBENCH");
        $display("==============================================");

        reset = 1'b1;
        start = 1'b0;

        // Reset for two clock cycles
        repeat (2) @(posedge clk);

        reset = 1'b0;

        $display("Reset released.");

        // Start BB84
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        $display("BB84 operation started.");

        // Give the DUT a maximum of 20 cycles
        repeat (20) begin

            @(posedge clk);

            if (done) begin

                $display("");
                $display("--------------- BB84 RESULTS ----------------");
                $display("Alice Bits       = %016h", alice_bits);
                $display("Alice Basis      = %016h", alice_basis);
                $display("Bob Basis        = %016h", bob_basis);
                $display("Bob Measurement  = %016h", bob_measurement);
                $display("DONE             = %b", done);
                $display("----------------------------------------------");

                $display("[PASS] BB84 operation completed.");

                $display("");
                $display("==============================================");
                $display("          BB84 TEST PASSED");
                $display("==============================================");

                $finish;
            end
        end

        // If we reach here, DONE never asserted
        $display("");
        $display("[FAIL] BB84 timeout.");
        $display("DONE never became HIGH.");
        $display("");
        $display("==============================================");
        $display("          BB84 TEST FAILED");
        $display("==============================================");

        $finish;

    end

endmodule