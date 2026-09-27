`timescale 1ns/1ps

module quantum_memory_controller_tb;

    parameter KEY_WIDTH = 64;

    reg clk;
    reg reset;

    reg                  write_enable;
    reg [KEY_WIDTH-1:0]  key_in;
    reg [6:0]            key_length_in;

    wire [KEY_WIDTH-1:0]  key_out;
    wire [6:0]            key_length_out;
    wire                  key_valid;

    quantum_memory_controller #(
        .KEY_WIDTH(KEY_WIDTH)
    ) DUT (
        .clk(clk),
        .reset(reset),

        .write_enable(write_enable),
        .key_in(key_in),
        .key_length_in(key_length_in),

        .key_out(key_out),
        .key_length_out(key_length_out),
        .key_valid(key_valid)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("quantum_memory_controller.vcd");
        $dumpvars(0, quantum_memory_controller_tb);

        $display("");
        $display("==============================================");
        $display("     QUANTUM MEMORY CONTROLLER TEST");
        $display("==============================================");

        reset        = 1'b1;
        write_enable = 1'b0;
        key_in       = 64'd0;
        key_length_in = 7'd0;

        repeat (2) @(posedge clk);

        reset = 1'b0;

        $display("Reset released.");

        // ------------------------------------------------
        // Write test
        // ------------------------------------------------

        @(negedge clk);

        key_in        = 64'h810314305A280090;
        key_length_in = 7'd32;
        write_enable  = 1'b1;

        @(negedge clk);

        write_enable = 1'b0;

        $display("Key written to memory.");

        // Allow registered write to settle
        @(posedge clk);

        #1;

        $display("");
        $display("---------------- RESULTS ----------------");
        $display("Key Out        = %016h", key_out);
        $display("Key Length     = %0d", key_length_out);
        $display("Key Valid      = %b", key_valid);
        $display("------------------------------------------");

        if ((key_out == 64'h810314305A280090) &&
            (key_length_out == 7'd32) &&
            (key_valid == 1'b1)) begin

            $display("[PASS] Quantum memory write/read successful.");

        end

        else begin

            $display("[FAIL] Quantum memory verification failed.");

        end

        $display("");
        $display("==============================================");
        $display("    QUANTUM MEMORY TEST COMPLETED");
        $display("==============================================");

        #20;
        $finish;

    end

endmodule