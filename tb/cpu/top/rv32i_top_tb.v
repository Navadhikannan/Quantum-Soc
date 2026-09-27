`timescale 1ns / 1ps

module rv32i_top_tb;

    parameter XLEN = 32;

    reg clk;
    reg reset;

    // ============================================================
    // DUT
    // ============================================================

    rv32i_top #(
        .XLEN(XLEN)
    ) DUT (
        .clk   (clk),
        .reset (reset)
    );

    // ============================================================
    // 100 MHz Clock
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ============================================================
    // Reset
    // ============================================================

    initial begin
        reset = 1'b1;

        $display("");
        $display("==============================================");
        $display("          RV32I CPU SIMULATION");
        $display("==============================================");
        $display("Reset asserted...");

        #20;

        reset = 1'b0;

        $display("Reset released...");
        $display("==============================================");
        $display("");
    end

    // ============================================================
    // Main Pipeline Monitor
    // ============================================================

    always @(posedge clk) begin
        #1;

        $display(
            "T=%0t | PC=%h | INST=%h | BR=%b | TARGET=%h | FA=%b FB=%b | WB_RD=x%0d WB_DATA=%h",
            $time,
            DUT.if_pc,
            DUT.if_instruction,
            DUT.ex_branch_taken_if,
            DUT.ex_branch_target_if,
            DUT.forwardA,
            DUT.forwardB,
            DUT.mem_rd,
            DUT.wb_write_data
        );
    end

    // ============================================================
    // Quantum Peripheral Monitor
    // ============================================================

    always @(posedge clk) begin
        #1;

        if (DUT.quantum_write || DUT.quantum_read) begin

            $display("");
            $display("==============================================");
            $display("          QUANTUM MEMORY ACCESS");
            $display("==============================================");

            $display("TIME       = %0t", $time);
            $display("ADDRESS    = %h", DUT.quantum_address);
            $display("WRITE      = %b", DUT.quantum_write);
            $display("READ       = %b", DUT.quantum_read);
            $display("WRITE DATA = %h", DUT.quantum_write_data);

            $display("==============================================");
            $display("");
        end
    end

    // ============================================================
    // Quantum Status Monitor
    // ============================================================

    always @(posedge clk) begin
        #1;

        if (DUT.quantum_busy ||
            DUT.quantum_done ||
            DUT.quantum_error) begin

            $display(
                "QUANTUM STATUS | BUSY=%b DONE=%b ERROR=%b KEY=%h LENGTH=%0d",
                DUT.quantum_busy,
                DUT.quantum_done,
                DUT.quantum_error,
                DUT.quantum_key,
                DUT.quantum_key_length
            );

        end
    end

    // ============================================================
    // Simulation Control
    // ============================================================

    initial begin

        // Generate waveform
        $dumpfile("rv32i_top.vcd");
        $dumpvars(0, rv32i_top_tb);

        // Run simulation
        #10000;

        $display("");
        $display("==============================================");
        $display("          SIMULATION FINISHED");
        $display("==============================================");
        $display("Time = %0t ns", $time);
        $display("==============================================");

        $finish;
    end

endmodule