`timescale 1ns/1ps

module error_correction_engine_tb;

    parameter KEY_WIDTH = 64;

    reg clk;
    reg reset;
    reg start;

    reg [KEY_WIDTH-1:0] sifted_key;
    reg [KEY_WIDTH-1:0] reference_key;

    wire [KEY_WIDTH-1:0] corrected_key;
    wire error_detected;
    wire done;

    error_correction_engine #(
        .KEY_WIDTH(KEY_WIDTH)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .start(start),
        .sifted_key(sifted_key),
        .reference_key(reference_key),
        .corrected_key(corrected_key),
        .error_detected(error_detected),
        .done(done)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("error_correction_engine.vcd");
        $dumpvars(0, error_correction_engine_tb);

        $display("");
        $display("==============================================");
        $display("      ERROR RECONCILIATION TEST");
        $display("==============================================");

        reset = 1'b1;
        start = 1'b0;

        sifted_key   = 64'h810314305A280090;

        // Initially identical reference
        reference_key = 64'h810314305A280090;

        repeat (2) @(posedge clk);

        reset = 1'b0;

        // Start reconciliation
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        $display("Reconciliation started.");

        // Wait for completion
        repeat (10) begin

            @(posedge clk);

            if (done) begin

                $display("");
                $display("------------- RESULTS ----------------");
                $display("Sifted Key       = %016h", sifted_key);
                $display("Reference Key    = %016h", reference_key);
                $display("Corrected Key    = %016h", corrected_key);
                $display("Error Detected   = %b", error_detected);
                $display("DONE             = %b", done);
                $display("--------------------------------------");

                if (error_detected == 1'b1) begin
    $display("[PASS] Error was correctly detected.");
end
else begin
    $display("[FAIL] Error was not detected.");
end

                $display("");
                $display("==============================================");
                $display("     ERROR RECONCILIATION TEST PASSED");
                $display("==============================================");

                $finish;
            end
        end

        $display("[FAIL] Reconciliation timeout.");
        $finish;

    end

endmodule