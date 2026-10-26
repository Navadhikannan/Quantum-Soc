
`timescale 1ns/1ps

module quantum_classical_soc_tb;

    logic clk = 0;
    logic reset = 1;

    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    quantum_classical_soc dut (
        .clk   (clk),
        .reset (reset)
    );

    always #5 clk = ~clk;

    task automatic check(input logic condition, input string message);
        begin
            if (condition === 1'b1) begin
                $display("[PASS] %s", message);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s", message);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("======================================");
        $display(" QUANTUM-CLASSICAL SOC TOP TEST");
        $display("======================================");

        // Hold the design in reset.
        repeat (3) @(posedge clk);
        @(negedge clk);
        check(reset === 1'b1, "Reset asserted");

        // Initialize the CPU instruction memory with NOPs.
        // ADDI x0, x0, 0 = 0x00000013
        for (i = 0; i < 256; i = i + 1)
            dut.CPU_CORE.FETCH_STAGE.instruction_memory_unit.memory[i]
                = 32'h00000013;

        // Program:
        // x1 = 10
        // x2 = 20
        // x3 = x1 + x2
        // Infinite loop
        dut.CPU_CORE.FETCH_STAGE.instruction_memory_unit.memory[0]
            = 32'h00A00093;
        dut.CPU_CORE.FETCH_STAGE.instruction_memory_unit.memory[1]
            = 32'h01400113;
        dut.CPU_CORE.FETCH_STAGE.instruction_memory_unit.memory[2]
            = 32'h002081B3;
        dut.CPU_CORE.FETCH_STAGE.instruction_memory_unit.memory[3]
            = 32'h0000006F;

        @(negedge clk);
        reset = 0;

        // Allow the CPU pipeline to execute the program.
        repeat (25) @(posedge clk);
        #1;

        check(dut.CPU_CORE.DECODE_STAGE.register_file_unit.registers[1]
                  === 32'd10, "CPU register x1 = 10");

        check(dut.CPU_CORE.DECODE_STAGE.register_file_unit.registers[2]
                  === 32'd20, "CPU register x2 = 20");

        check(dut.CPU_CORE.DECODE_STAGE.register_file_unit.registers[3]
                  === 32'd30, "CPU register x3 = 30");

        $display("--------------------------------------");
        $display("PASS COUNT = %0d", pass_count);
        $display("FAIL COUNT = %0d", fail_count);

        if (fail_count == 0) begin
            $display("SOC TOP TEST: PASS");
        end else begin
            $display("SOC TOP TEST: FAIL");
        end

        $finish;
    end

    initial begin
        #5000;
        $display("[FAIL] Watchdog timeout");
        $finish;
    end

endmodule
