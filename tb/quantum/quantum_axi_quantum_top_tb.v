`timescale 1ns/1ps

module quantum_axi_quantum_top_tb;

    //========================================================
    // PARAMETERS
    //========================================================

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter KEY_WIDTH  = 64;

    //========================================================
    // CLOCK / RESET
    //========================================================

    reg clk;
    reg reset;

    //========================================================
    // AXI-LITE WRITE ADDRESS
    //========================================================

    reg  [ADDR_WIDTH-1:0] s_axi_awaddr;
    reg                   s_axi_awvalid;
    wire                  s_axi_awready;

    //========================================================
    // AXI-LITE WRITE DATA
    //========================================================

    reg  [DATA_WIDTH-1:0]   s_axi_wdata;
    reg [DATA_WIDTH/8-1:0]  s_axi_wstrb;
    reg                     s_axi_wvalid;
    wire                    s_axi_wready;

    //========================================================
    // AXI-LITE WRITE RESPONSE
    //========================================================

    wire [1:0] s_axi_bresp;
    wire       s_axi_bvalid;
    reg        s_axi_bready;

    //========================================================
    // AXI-LITE READ ADDRESS
    //========================================================

    reg  [ADDR_WIDTH-1:0] s_axi_araddr;
    reg                   s_axi_arvalid;
    wire                  s_axi_arready;

    //========================================================
    // AXI-LITE READ DATA
    //========================================================

    wire [DATA_WIDTH-1:0] s_axi_rdata;
    wire [1:0]            s_axi_rresp;
    wire                  s_axi_rvalid;
    reg                   s_axi_rready;

    //========================================================
    // TEST VARIABLES
    //========================================================

    integer errors;
    integer timeout_count;

    reg [31:0] read_value;

    //========================================================
    // DUT
    //========================================================

    quantum_axi_quantum_top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .KEY_WIDTH(KEY_WIDTH),
        .MIN_KEY_LENGTH(16)
    ) DUT (

        .clk(clk),
        .reset(reset),

        // AXI Write Address
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        // AXI Write Data
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        // AXI Write Response
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),

        // AXI Read Address
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        // AXI Read Data
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready)
    );

    //========================================================
    // CLOCK
    //========================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    //========================================================
    // GLOBAL TIMEOUT
    //========================================================

    initial begin

        #2000;

        $display("");
        $display("==============================================");
        $display("       GLOBAL INTEGRATION TIMEOUT");
        $display("==============================================");

        $display("[FAIL] Simulation exceeded 2000 ns.");
        $display("Errors = %0d", errors);

        $finish;

    end

    //========================================================
    // AXI WRITE TASK
    //========================================================

    task axi_write;

        input [31:0] address;
        input [31:0] data;

        begin

            $display("");
            $display("----------------------------------------------");
            $display("AXI WRITE");
            $display("----------------------------------------------");

            $display("Address = %08h", address);
            $display("Data    = %08h", data);

            //================================================
            // Drive address and data
            //================================================

            @(negedge clk);

            s_axi_awaddr  = address;
            s_axi_awvalid = 1'b1;

            s_axi_wdata   = data;
            s_axi_wstrb   = 4'b1111;
            s_axi_wvalid  = 1'b1;

            //================================================
            // Wait for AWREADY
            //================================================

            timeout_count = 0;

            while (!s_axi_awready &&
                   timeout_count < 20) begin

                @(posedge clk);

                timeout_count = timeout_count + 1;

            end

            if (s_axi_awready) begin

                $display("[PASS] AW handshake.");

            end
            else begin

                $display("[FAIL] AW handshake timeout.");

                errors = errors + 1;

            end

            //================================================
            // Wait for WREADY
            //================================================

            timeout_count = 0;

            while (!s_axi_wready &&
                   timeout_count < 20) begin

                @(posedge clk);

                timeout_count = timeout_count + 1;

            end

            if (s_axi_wready) begin

                $display("[PASS] W handshake.");

            end
            else begin

                $display("[FAIL] W handshake timeout.");

                errors = errors + 1;

            end

            //================================================
            // Complete write handshake
            //================================================

            @(posedge clk);

            @(negedge clk);

            s_axi_awvalid = 1'b0;
            s_axi_wvalid  = 1'b0;

            //================================================
            // B RESPONSE
            //================================================

            s_axi_bready = 1'b1;

            timeout_count = 0;

            while (!s_axi_bvalid &&
                   timeout_count < 20) begin

                @(posedge clk);

                timeout_count = timeout_count + 1;

            end

            if (s_axi_bvalid) begin

                $display("[PASS] B response received.");
                $display("       BRESP = %02b", s_axi_bresp);

                if (s_axi_bresp != 2'b00) begin

                    $display("[FAIL] BRESP is not OKAY.");

                    errors = errors + 1;

                end

            end
            else begin

                $display("[FAIL] B response timeout.");

                errors = errors + 1;

            end

            //================================================
            // Complete B handshake
            //================================================

            @(posedge clk);

            @(negedge clk);

            s_axi_bready = 1'b0;

        end

    endtask

    //========================================================
    // AXI READ TASK
    //========================================================

    task axi_read;

        input  [31:0] address;
        output [31:0] data;

        begin

            data = 32'd0;

            $display("");
            $display("----------------------------------------------");
            $display("AXI READ");
            $display("----------------------------------------------");

            $display("Address = %08h", address);

            //================================================
            // Drive address
            //================================================

            @(negedge clk);

            s_axi_araddr  = address;
            s_axi_arvalid = 1'b1;

            //================================================
            // Wait for ARREADY
            //================================================

            timeout_count = 0;

            while (!s_axi_arready &&
                   timeout_count < 20) begin

                @(posedge clk);

                timeout_count = timeout_count + 1;

            end

            if (s_axi_arready) begin

                $display("[PASS] AR handshake.");

            end
            else begin

                $display("[FAIL] AR handshake timeout.");

                errors = errors + 1;

            end

            //================================================
            // Complete AR handshake
            //================================================

            @(posedge clk);

            @(negedge clk);

            s_axi_arvalid = 1'b0;

            //================================================
            // R RESPONSE
            //================================================

            s_axi_rready = 1'b1;

            timeout_count = 0;

            while (!s_axi_rvalid &&
                   timeout_count < 20) begin

                @(posedge clk);

                timeout_count = timeout_count + 1;

            end

            if (s_axi_rvalid) begin

                #1;

                data = s_axi_rdata;

                $display("[PASS] R response received.");
                $display("       RDATA = %08h", s_axi_rdata);
                $display("       RRESP = %02b", s_axi_rresp);

                if (s_axi_rresp != 2'b00) begin

                    $display("[FAIL] RRESP is not OKAY.");

                    errors = errors + 1;

                end

            end
            else begin

                $display("[FAIL] R response timeout.");

                errors = errors + 1;

            end

            //================================================
            // Complete R handshake
            //================================================

            @(posedge clk);

            @(negedge clk);

            s_axi_rready = 1'b0;

        end

    endtask

    //========================================================
    // MAIN TEST
    //========================================================

    initial begin

        $dumpfile("quantum_axi_quantum_top.vcd");
        $dumpvars(0, quantum_axi_quantum_top_tb);

        $display("");
        $display("================================================");
        $display("   AXI-LITE + QUANTUM DOMAIN INTEGRATION TEST");
        $display("================================================");

        //====================================================
        // INITIAL VALUES
        //====================================================

        reset = 1'b1;

        s_axi_awaddr  = 32'd0;
        s_axi_awvalid = 1'b0;

        s_axi_wdata   = 32'd0;
        s_axi_wstrb   = 4'd0;
        s_axi_wvalid  = 1'b0;

        s_axi_bready  = 1'b0;

        s_axi_araddr  = 32'd0;
        s_axi_arvalid = 1'b0;

        s_axi_rready  = 1'b0;

        errors = 0;
        timeout_count = 0;
        read_value = 32'd0;

        //====================================================
        // RESET
        //====================================================

        repeat (3)
            @(posedge clk);

        reset = 1'b0;

        $display("Reset released.");

        //====================================================
        // TEST 1
        // START QUANTUM DOMAIN THROUGH AXI
        //====================================================

        $display("");
        $display("================================================");
        $display("TEST 1: AXI CONTROL WRITE");
        $display("================================================");

        axi_write(
            32'h80000000,
            32'h00000001
        );

        $display("[PASS] Quantum operation requested through AXI.");

        //====================================================
        // WAIT FOR QUANTUM BUSY
        //====================================================

        $display("");
        $display("================================================");
        $display("WAITING FOR QUANTUM DOMAIN");
        $display("================================================");

        timeout_count = 0;

        while (!DUT.quantum_busy &&
               timeout_count < 100) begin

            @(posedge clk);

            timeout_count = timeout_count + 1;

        end

        if (DUT.quantum_busy) begin

            $display(
                "TIME=%0t : Quantum domain BUSY",
                $time
            );

            $display("[PASS] Quantum domain started.");

        end
        else begin

            $display(
                "[INFO] Quantum BUSY was not observed."
            );

        end

        //====================================================
        // WAIT FOR DONE
        //====================================================

        timeout_count = 0;

        while (!DUT.quantum_done &&
               timeout_count < 100) begin

            @(posedge clk);

            timeout_count = timeout_count + 1;

        end

        if (DUT.quantum_done) begin

            $display("");
            $display("[PASS] Quantum domain completed.");

        end
        else begin

            $display("");
            $display("[FAIL] Quantum domain completion timeout.");

            errors = errors + 1;

        end

        //====================================================
        // TEST 2
        // STATUS REGISTER
        //====================================================

        $display("");
        $display("================================================");
        $display("TEST 2: AXI STATUS READ");
        $display("================================================");

        axi_read(
            32'h80000004,
            read_value
        );

        $display("STATUS = %08h", read_value);

        if ((read_value[1] == 1'b1) &&
            (read_value[2] == 1'b0)) begin

            $display("[PASS] STATUS indicates DONE.");

        end
        else begin

            $display("[FAIL] STATUS verification failed.");
            $display("       Expected DONE=1 ERROR=0.");

            errors = errors + 1;

        end

        //====================================================
        // TEST 3
        // KEY LOW
        //====================================================

        $display("");
        $display("================================================");
        $display("TEST 3: AXI KEY LOW READ");
        $display("================================================");

        axi_read(
            32'h80000008,
            read_value
        );

        $display("KEY LOW = %08h", read_value);

        if (read_value == 32'h5A280090) begin

            $display("[PASS] KEY LOW correct.");

        end
        else begin

            $display("[FAIL] KEY LOW mismatch.");
            $display("       Expected = 5A280090");
            $display("       Received = %08h",
                     read_value);

            errors = errors + 1;

        end

        //====================================================
        // TEST 4
        // KEY HIGH
        //====================================================

        $display("");
        $display("================================================");
        $display("TEST 4: AXI KEY HIGH READ");
        $display("================================================");

        axi_read(
            32'h8000000C,
            read_value
        );

        $display("KEY HIGH = %08h", read_value);

        if (read_value == 32'h81031430) begin

            $display("[PASS] KEY HIGH correct.");

        end
        else begin

            $display("[FAIL] KEY HIGH mismatch.");
            $display("       Expected = 81031430");
            $display("       Received = %08h",
                     read_value);

            errors = errors + 1;

        end

        //====================================================
        // TEST 5
        // KEY LENGTH
        //====================================================

        $display("");
        $display("================================================");
        $display("TEST 5: AXI KEY LENGTH READ");
        $display("================================================");

        axi_read(
            32'h80000010,
            read_value
        );

        $display("KEY LENGTH = %0d",
                 read_value);

        if (read_value == 32'd32) begin

            $display("[PASS] KEY LENGTH correct.");

        end
        else begin

            $display("[FAIL] KEY LENGTH mismatch.");
            $display("       Expected = 32");
            $display("       Received = %0d",
                     read_value);

            errors = errors + 1;

        end

        //====================================================
        // FINAL RESULT
        //====================================================

        $display("");
        $display("================================================");
        $display("       FINAL INTEGRATION RESULT");
        $display("================================================");

        $display("Quantum Busy       = %b",
                 DUT.quantum_busy);

        $display("Quantum Done       = %b",
                 DUT.quantum_done);

        $display("Quantum Error      = %b",
                 DUT.quantum_error);

        $display("Quantum Key        = %016h",
                 DUT.quantum_key);

        $display("Quantum Key Length = %0d",
                 DUT.quantum_key_length);

        $display("Quantum Key Valid  = %b",
                 DUT.quantum_key_valid);

        $display("Errors             = %0d",
                 errors);

        $display("----------------------------------------------");

        if (errors == 0) begin

            $display("[PASS] AXI successfully controlled quantum domain.");
            $display("[PASS] Quantum domain completed.");
            $display("[PASS] Final key successfully read through AXI.");
            $display("[PASS] End-to-end integration verified.");

            $display("");
            $display("================================================");
            $display("    AXI + QUANTUM DOMAIN TEST PASSED");
            $display("================================================");

        end
        else begin

            $display("[FAIL] AXI + quantum integration failed.");

            $display("");
            $display("================================================");
            $display("    AXI + QUANTUM DOMAIN TEST FAILED");
            $display("================================================");

        end

        #20;

        $finish;

    end

endmodule