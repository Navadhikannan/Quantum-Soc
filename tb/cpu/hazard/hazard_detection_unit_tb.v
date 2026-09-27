`timescale 1ns / 1ps

module hazard_detection_unit_tb;

    // ============================================================
    // Testbench Signals
    // ============================================================

    reg        ex_mem_read;
    reg  [4:0] ex_rd;
    reg  [4:0] id_rs1;
    reg  [4:0] id_rs2;

    wire       pc_write;
    wire       if_id_write;
    wire       control_mux;

    integer test_count;
    integer pass_count;
    integer fail_count;

    // ============================================================
    // DUT
    // ============================================================

    hazard_detection_unit DUT (
        .ex_mem_read (ex_mem_read),
        .ex_rd       (ex_rd),
        .id_rs1      (id_rs1),
        .id_rs2      (id_rs2),

        .pc_write    (pc_write),
        .if_id_write (if_id_write),
        .control_mux (control_mux)
    );

    // ============================================================
    // Test Task
    // ============================================================

    task check_result;

        input expected_pc_write;
        input expected_if_id_write;
        input expected_control_mux;

        begin

            test_count = test_count + 1;

            #1;

            if ((pc_write === expected_pc_write) &&
                (if_id_write === expected_if_id_write) &&
                (control_mux === expected_control_mux)) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS | Test %0d | PC_WRITE=%b IF_ID_WRITE=%b CONTROL_MUX=%b",
                    test_count,
                    pc_write,
                    if_id_write,
                    control_mux
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL | Test %0d | Expected PC_WRITE=%b IF_ID_WRITE=%b CONTROL_MUX=%b | Got PC_WRITE=%b IF_ID_WRITE=%b CONTROL_MUX=%b",
                    test_count,
                    expected_pc_write,
                    expected_if_id_write,
                    expected_control_mux,
                    pc_write,
                    if_id_write,
                    control_mux
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

        ex_mem_read = 1'b0;
        ex_rd       = 5'd0;
        id_rs1      = 5'd0;
        id_rs2      = 5'd0;

        $display("");
        $display("==============================================");
        $display("     HAZARD DETECTION UNIT TESTBENCH");
        $display("==============================================");
        $display("");

        // ========================================================
        // TEST 1
        // No load in EX stage
        // ========================================================

        $display("TEST 1: No load instruction");

        ex_mem_read = 1'b0;
        ex_rd       = 5'd5;
        id_rs1      = 5'd5;
        id_rs2      = 5'd6;

        check_result(1'b1, 1'b1, 1'b0);


        // ========================================================
        // TEST 2
        // Load-use hazard through RS1
        // ========================================================

        $display("TEST 2: Load-use hazard through RS1");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd5;
        id_rs1      = 5'd5;
        id_rs2      = 5'd6;

        check_result(1'b0, 1'b0, 1'b1);


        // ========================================================
        // TEST 3
        // Load-use hazard through RS2
        // ========================================================

        $display("TEST 3: Load-use hazard through RS2");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd5;
        id_rs1      = 5'd6;
        id_rs2      = 5'd5;

        check_result(1'b0, 1'b0, 1'b1);


        // ========================================================
        // TEST 4
        // Load-use hazard through both RS1 and RS2
        // ========================================================

        $display("TEST 4: Load-use hazard through both operands");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd5;
        id_rs1      = 5'd5;
        id_rs2      = 5'd5;

        check_result(1'b0, 1'b0, 1'b1);


        // ========================================================
        // TEST 5
        // Load destination does not match either source
        // ========================================================

        $display("TEST 5: No dependency");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd5;
        id_rs1      = 5'd6;
        id_rs2      = 5'd7;

        check_result(1'b1, 1'b1, 1'b0);


        // ========================================================
        // TEST 6
        // EX destination is x0
        // x0 must never create a hazard
        // ========================================================

        $display("TEST 6: Load destination is x0");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd0;
        id_rs1      = 5'd0;
        id_rs2      = 5'd0;

        check_result(1'b1, 1'b1, 1'b0);


        // ========================================================
        // TEST 7
        // Load to x0 but ID uses another register
        // ========================================================

        $display("TEST 7: x0 load with unrelated operands");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd0;
        id_rs1      = 5'd5;
        id_rs2      = 5'd6;

        check_result(1'b1, 1'b1, 1'b0);


        // ========================================================
        // TEST 8
        // Load-use hazard through RS1 while RS2 is x0
        // ========================================================

        $display("TEST 8: RS1 dependency with RS2=x0");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd10;
        id_rs1      = 5'd10;
        id_rs2      = 5'd0;

        check_result(1'b0, 1'b0, 1'b1);


        // ========================================================
        // TEST 9
        // Load-use hazard through RS2 while RS1 is x0
        // ========================================================

        $display("TEST 9: RS2 dependency with RS1=x0");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd11;
        id_rs1      = 5'd0;
        id_rs2      = 5'd11;

        check_result(1'b0, 1'b0, 1'b1);


        // ========================================================
        // TEST 10
        // Different register numbers
        // ========================================================

        $display("TEST 10: Different register numbers");

        ex_mem_read = 1'b1;
        ex_rd       = 5'd15;
        id_rs1      = 5'd14;
        id_rs2      = 5'd16;

        check_result(1'b1, 1'b1, 1'b0);


        // ========================================================
        // Final Result
        // ========================================================

        $display("");
        $display("==============================================");
        $display("       HAZARD DETECTION TEST RESULT");
        $display("==============================================");

        $display("Total Tests : %0d", test_count);
        $display("Passed      : %0d", pass_count);
        $display("Failed      : %0d", fail_count);

        if (fail_count == 0) begin
            $display("");
            $display("******** HAZARD DETECTION UNIT PASSED ********");
        end
        else begin
            $display("");
            $display("******** HAZARD DETECTION UNIT FAILED ********");
        end

        $display("==============================================");
        $display("");

        $finish;

    end

endmodule