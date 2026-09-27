`timescale 1ns / 1ps

module forwarding_unit_tb;

    // ============================================================
    // Testbench Signals
    // ============================================================

    reg  [4:0] ex_rs1;
    reg  [4:0] ex_rs2;

    reg  [4:0] mem_rd;
    reg        mem_reg_write;

    reg  [4:0] wb_rd;
    reg        wb_reg_write;

    wire [1:0] forwardA;
    wire [1:0] forwardB;

    integer test_count;
    integer pass_count;
    integer fail_count;

    // ============================================================
    // DUT
    // ============================================================

    forwarding_unit DUT (
        .ex_rs1       (ex_rs1),
        .ex_rs2       (ex_rs2),

        .mem_rd       (mem_rd),
        .mem_reg_write(mem_reg_write),

        .wb_rd        (wb_rd),
        .wb_reg_write (wb_reg_write),

        .forwardA     (forwardA),
        .forwardB     (forwardB)
    );

    // ============================================================
    // Test Task
    // ============================================================

    task check_result;

        input [1:0] expected_A;
        input [1:0] expected_B;

        begin

            test_count = test_count + 1;

            #1;

            if ((forwardA === expected_A) &&
                (forwardB === expected_B)) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS | Test %0d | FA=%b FB=%b",
                    test_count,
                    forwardA,
                    forwardB
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL | Test %0d | Expected FA=%b FB=%b | Got FA=%b FB=%b",
                    test_count,
                    expected_A,
                    expected_B,
                    forwardA,
                    forwardB
                );

            end

        end

    endtask

    // ============================================================
    // Test Sequence
    // ============================================================

    initial begin

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        // --------------------------------------------------------
        // Initial values
        // --------------------------------------------------------

        ex_rs1        = 5'd0;
        ex_rs2        = 5'd0;

        mem_rd        = 5'd0;
        mem_reg_write = 1'b0;

        wb_rd         = 5'd0;
        wb_reg_write  = 1'b0;

        $display("");
        $display("==============================================");
        $display("       FORWARDING UNIT TESTBENCH");
        $display("==============================================");
        $display("");

        // ========================================================
        // TEST 1
        // No forwarding
        // ========================================================

        $display("TEST 1: No forwarding");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd7;
        mem_reg_write = 1'b1;

        wb_rd = 5'd8;
        wb_reg_write = 1'b1;

        check_result(2'b00, 2'b00);


        // ========================================================
        // TEST 2
        // EX/MEM forwarding to RS1
        // ========================================================

        $display("TEST 2: EX/MEM forwarding to RS1");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd5;
        mem_reg_write = 1'b1;

        wb_rd = 5'd8;
        wb_reg_write = 1'b1;

        check_result(2'b10, 2'b00);


        // ========================================================
        // TEST 3
        // EX/MEM forwarding to RS2
        // ========================================================

        $display("TEST 3: EX/MEM forwarding to RS2");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd6;
        mem_reg_write = 1'b1;

        wb_rd = 5'd8;
        wb_reg_write = 1'b1;

        check_result(2'b00, 2'b10);


        // ========================================================
        // TEST 4
        // MEM/WB forwarding to RS1
        // ========================================================

        $display("TEST 4: MEM/WB forwarding to RS1");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd7;
        mem_reg_write = 1'b1;

        wb_rd = 5'd5;
        wb_reg_write = 1'b1;

        check_result(2'b01, 2'b00);


        // ========================================================
        // TEST 5
        // MEM/WB forwarding to RS2
        // ========================================================

        $display("TEST 5: MEM/WB forwarding to RS2");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd7;
        mem_reg_write = 1'b1;

        wb_rd = 5'd6;
        wb_reg_write = 1'b1;

        check_result(2'b00, 2'b01);


        // ========================================================
        // TEST 6
        // Both RS1 and RS2 forwarded from EX/MEM
        // ========================================================

        $display("TEST 6: EX/MEM forwarding to both operands");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd5;
        mem_reg_write = 1'b1;

        wb_rd = 5'd7;
        wb_reg_write = 1'b1;

        check_result(2'b10, 2'b00);


        // ========================================================
        // TEST 7
        // Both RS1 and RS2 forwarded from MEM/WB
        // ========================================================

        $display("TEST 7: MEM/WB forwarding to both operands");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd7;
        mem_reg_write = 1'b1;

        wb_rd = 5'd5;
        wb_reg_write = 1'b1;

        // RS2 does not match WB in this configuration.
        check_result(2'b01, 2'b00);


        // ========================================================
        // TEST 8
        // EX/MEM and MEM/WB both match RS1
        // EX/MEM must have priority
        // ========================================================

        $display("TEST 8: EX/MEM priority over MEM/WB");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd5;
        mem_reg_write = 1'b1;

        wb_rd = 5'd5;
        wb_reg_write = 1'b1;

        check_result(2'b10, 2'b00);


        // ========================================================
        // TEST 9
        // EX/MEM match but RegWrite disabled
        // ========================================================

        $display("TEST 9: EX/MEM match with RegWrite disabled");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd5;
        mem_reg_write = 1'b0;

        wb_rd = 5'd8;
        wb_reg_write = 1'b1;

        check_result(2'b00, 2'b00);


        // ========================================================
        // TEST 10
        // MEM/WB match but RegWrite disabled
        // ========================================================

        $display("TEST 10: MEM/WB match with RegWrite disabled");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd8;
        mem_reg_write = 1'b1;

        wb_rd = 5'd5;
        wb_reg_write = 1'b0;

        check_result(2'b00, 2'b00);


        // ========================================================
        // TEST 11
        // x0 must never be forwarded
        // ========================================================

        $display("TEST 11: x0 should not be forwarded");

        ex_rs1 = 5'd0;
        ex_rs2 = 5'd0;

        mem_rd = 5'd0;
        mem_reg_write = 1'b1;

        wb_rd = 5'd0;
        wb_reg_write = 1'b1;

        check_result(2'b00, 2'b00);


        // ========================================================
        // TEST 12
        // Different dependencies on RS1 and RS2
        // ========================================================

        $display("TEST 12: Different forwarding sources");

        ex_rs1 = 5'd5;
        ex_rs2 = 5'd6;

        mem_rd = 5'd5;
        mem_reg_write = 1'b1;

        wb_rd = 5'd6;
        wb_reg_write = 1'b1;

        check_result(2'b10, 2'b01);


        // ========================================================
        // Final Result
        // ========================================================

        $display("");
        $display("==============================================");
        $display("           FORWARDING TEST RESULT");
        $display("==============================================");

        $display("Total Tests : %0d", test_count);
        $display("Passed      : %0d", pass_count);
        $display("Failed      : %0d", fail_count);

        if (fail_count == 0) begin
            $display("");
            $display("******** FORWARDING UNIT PASSED ********");
        end
        else begin
            $display("");
            $display("******** FORWARDING UNIT FAILED ********");
        end

        $display("==============================================");
        $display("");

        $finish;

    end

endmodule