`timescale 1ns/1ps

module qkd_engine_tb;

    parameter KEY_WIDTH = 64;

    reg clk;
    reg reset;
    reg start;

    reg [KEY_WIDTH-1:0] alice_bits;
    reg [KEY_WIDTH-1:0] alice_basis;
    reg [KEY_WIDTH-1:0] bob_basis;

    wire [KEY_WIDTH-1:0] sifted_key;
    wire [KEY_WIDTH-1:0] basis_match_mask;
    wire [6:0] key_length;

    wire done;
    wire error;

    qkd_engine #(
        .KEY_WIDTH(KEY_WIDTH),
        .MIN_KEY_LENGTH(16)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .start(start),

        .alice_bits(alice_bits),
        .alice_basis(alice_basis),
        .bob_basis(bob_basis),

        .sifted_key(sifted_key),
        .basis_match_mask(basis_match_mask),
        .key_length(key_length),

        .done(done),
        .error(error)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("qkd_engine.vcd");
        $dumpvars(0, qkd_engine_tb);

        $display("");
        $display("==============================================");
        $display("          QKD SIFTING ENGINE TEST");
        $display("==============================================");

        reset = 1'b1;
        start = 1'b0;

        alice_bits  = 64'hA5C396F05A3C69F0;
        alice_basis = 64'h5A96C30FA5C30F69;
        bob_basis   = 64'h3C5A69C3A596F00F;

        repeat (2) @(posedge clk);

        reset = 1'b0;

        // Start sifting
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        $display("Sifting operation started.");

        // Wait maximum 10 cycles
        repeat (10) begin

            @(posedge clk);

            if (done) begin

                $display("");
                $display("--------------- QKD RESULTS -----------------");
                $display("Alice Bits       = %016h", alice_bits);
                $display("Alice Basis      = %016h", alice_basis);
                $display("Bob Basis        = %016h", bob_basis);
                $display("Match Mask       = %016h", basis_match_mask);
                $display("Sifted Key       = %016h", sifted_key);
                $display("Key Length       = %0d", key_length);
                $display("Error            = %b", error);
                $display("DONE             = %b", done);
                $display("----------------------------------------------");

                if (key_length >= 16 && error == 1'b0)
                    $display("[PASS] QKD sifting completed successfully.");
                else
                    $display("[FAIL] Unexpected sifted-key result.");

                $display("");
                $display("==============================================");
                $display("          QKD TEST COMPLETED");
                $display("==============================================");

                $finish;
            end
        end

        $display("");
        $display("[FAIL] QKD engine timeout.");
        $display("DONE never became HIGH.");

        $finish;

    end

endmodule