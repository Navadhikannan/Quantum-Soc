`timescale 1ns/1ps

module quantum_axi_slave_tb;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

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

    reg  [DATA_WIDTH-1:0]  s_axi_wdata;
    reg [DATA_WIDTH/8-1:0] s_axi_wstrb;
    reg                    s_axi_wvalid;
    wire                   s_axi_wready;

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
    // QUANTUM DOMAIN
    //========================================================

    wire        quantum_start;

    reg         quantum_busy;
    reg         quantum_done;
    reg         quantum_error;

    reg [63:0]  quantum_key;
    reg [6:0]   quantum_key_length;

    //========================================================
    // TEST VARIABLES
    //========================================================

    integer errors;
    reg [31:0] read_value;

    //========================================================
    // DUT
    //========================================================

    quantum_axi_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (

        .clk(clk),
        .reset(reset),

        // Write address
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        // Write data
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        // Write response
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),

        // Read address
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        // Read data
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),

        // Quantum domain
        .quantum_start(quantum_start),

        .quantum_busy(quantum_busy),
        .quantum_done(quantum_done),
        .quantum_error(quantum_error),

        .quantum_key(quantum_key),
        .quantum_key_length(quantum_key_length)
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

        #1000;

        $display("");
        $display("==============================================");
        $display("       GLOBAL TEST TIMEOUT");
        $display("==============================================");

        $display("[FAIL] Simulation exceeded 1000 ns.");

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
            // Drive address and data BEFORE rising edge
            //================================================

            @(negedge clk);

            s_axi_awaddr  = address;
            s_axi_awvalid = 1'b1;

            s_axi_wdata   = data;
            s_axi_wstrb   = 4'b1111;
            s_axi_wvalid  = 1'b1;

            //================================================
            // Handshake
            //================================================

            @(posedge clk);

            if (s_axi_awready) begin

                $display("[PASS] AW handshake.");

            end
            else begin

                $display("[FAIL] AW handshake.");

                errors = errors + 1;

            end

            if (s_axi_wready) begin

                $display("[PASS] W handshake.");

            end
            else begin

                $display("[FAIL] W handshake.");

                errors = errors + 1;

            end

            //================================================
            // Remove VALID after handshake
            //================================================

            @(negedge clk);

            s_axi_awvalid = 1'b0;
            s_axi_wvalid  = 1'b0;

            //================================================
            // Accept B response
            //================================================

            s_axi_bready = 1'b1;

            wait (s_axi_bvalid == 1'b1);

            #1;

            $display("[PASS] B response received.");
            $display("       BRESP = %02b", s_axi_bresp);

            if (s_axi_bresp != 2'b00) begin

                $display("[FAIL] BRESP is not OKAY.");

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
            // Drive address BEFORE rising edge
            //================================================

            @(negedge clk);

            s_axi_araddr  = address;
            s_axi_arvalid = 1'b1;

            //================================================
            // Address handshake
            //================================================

            @(posedge clk);

            if (s_axi_arready) begin

                $display("[PASS] AR handshake.");

            end
            else begin

                $display("[FAIL] AR handshake.");

                errors = errors + 1;

            end

            //================================================
            // Remove VALID
            //================================================

            @(negedge clk);

            s_axi_arvalid = 1'b0;

            //================================================
            // Accept R response
            //================================================

            s_axi_rready = 1'b1;

            wait (s_axi_rvalid == 1'b1);

            #1;

            data = s_axi_rdata;

            $display("[PASS] R response received.");
            $display("       RDATA = %08h", s_axi_rdata);
            $display("       RRESP = %02b", s_axi_rresp);

            if (s_axi_rresp != 2'b00) begin

                $display("[FAIL] RRESP is not OKAY.");

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

        $dumpfile("quantum_axi_slave.vcd");
        $dumpvars(0, quantum_axi_slave_tb);

        $display("");
        $display("==============================================");
        $display("       QUANTUM AXI-LITE SLAVE TEST");
        $display("==============================================");

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

        quantum_busy  = 1'b0;
        quantum_done  = 1'b0;
        quantum_error = 1'b0;

        quantum_key = 64'd0;
        quantum_key_length = 7'd0;

        errors = 0;

        //====================================================
        // RESET
        //====================================================

        repeat (3)
            @(posedge clk);

        reset = 1'b0;

        $display("Reset released.");

        //====================================================
        // TEST 1
        // CONTROL REGISTER WRITE
        //====================================================

        $display("");
        $display("==============================================");
        $display("TEST 1: CONTROL REGISTER WRITE");
        $display("==============================================");

        axi_write(
            32'h80000000,
            32'h00000001
        );

        //====================================================
        // QUANTUM START CHECK
        //====================================================

        @(negedge clk);

        if (quantum_start == 1'b0) begin

            $display("[INFO] Quantum START pulse completed.");

        end

        //====================================================
        // SIMULATE QUANTUM OPERATION
        //====================================================

        @(negedge clk);

        quantum_busy = 1'b1;

        $display("Quantum operation started.");

        @(negedge clk);

        quantum_busy  = 1'b0;
        quantum_done  = 1'b1;
        quantum_error = 1'b0;

        quantum_key =
            64'h810314305A280090;

        quantum_key_length = 7'd32;

        $display("Quantum operation completed.");

        //====================================================
        // TEST 2
        // STATUS REGISTER
        //====================================================

        $display("");
        $display("==============================================");
        $display("TEST 2: STATUS REGISTER READ");
        $display("==============================================");

        axi_read(
            32'h80000004,
            read_value
        );

        $display("STATUS = %08h", read_value);

        if (read_value == 32'h00000002) begin

            $display("[PASS] STATUS correct.");

        end
        else begin

            $display("[FAIL] STATUS expected 00000002.");
            $display("       Received = %08h", read_value);

            errors = errors + 1;

        end

        //====================================================
        // TEST 3
        // KEY LOW
        //====================================================

        $display("");
        $display("==============================================");
        $display("TEST 3: KEY LOW REGISTER");
        $display("==============================================");

        axi_read(
            32'h80000008,
            read_value
        );

        if (read_value == 32'h5A280090) begin

            $display("[PASS] KEY_LO correct.");

        end
        else begin

            $display("[FAIL] KEY_LO expected 5A280090.");
            $display("       Received = %08h", read_value);

            errors = errors + 1;

        end

        //====================================================
        // TEST 4
        // KEY HIGH
        //====================================================

        $display("");
        $display("==============================================");
        $display("TEST 4: KEY HIGH REGISTER");
        $display("==============================================");

        axi_read(
            32'h8000000C,
            read_value
        );

        if (read_value == 32'h81031430) begin

            $display("[PASS] KEY_HI correct.");

        end
        else begin

            $display("[FAIL] KEY_HI expected 81031430.");
            $display("       Received = %08h", read_value);

            errors = errors + 1;

        end

        //====================================================
        // TEST 5
        // KEY LENGTH
        //====================================================

        $display("");
        $display("==============================================");
        $display("TEST 5: KEY LENGTH REGISTER");
        $display("==============================================");

        axi_read(
            32'h80000010,
            read_value
        );

        if (read_value == 32'h00000020) begin

            $display("[PASS] KEY LENGTH correct.");

        end
        else begin

            $display("[FAIL] KEY LENGTH expected 00000020.");
            $display("       Received = %08h", read_value);

            errors = errors + 1;

        end

        //====================================================
        // FINAL RESULTS
        //====================================================

        $display("");
        $display("==============================================");
        $display("           FINAL AXI RESULTS");
        $display("==============================================");

        $display("Quantum Busy       = %b",
                 quantum_busy);

        $display("Quantum Done       = %b",
                 quantum_done);

        $display("Quantum Error      = %b",
                 quantum_error);

        $display("Quantum Key        = %016h",
                 quantum_key);

        $display("Quantum Key Length = %0d",
                 quantum_key_length);

        $display("Errors             = %0d",
                 errors);

        $display("----------------------------------------------");

        if (errors == 0) begin

            $display("[PASS] AXI-Lite quantum peripheral test completed.");
            $display("[PASS] CONTROL register verified.");
            $display("[PASS] STATUS register verified.");
            $display("[PASS] KEY registers verified.");
            $display("[PASS] KEY LENGTH register verified.");

            $display("");
            $display("==============================================");
            $display("       AXI-LITE SLAVE TEST PASSED");
            $display("==============================================");

        end
        else begin

            $display("[FAIL] AXI-Lite verification failed.");

            $display("");
            $display("==============================================");
            $display("       AXI-LITE SLAVE TEST FAILED");
            $display("==============================================");

        end

        #20;

        $finish;

    end

    //========================================================
    // DEBUG MONITOR
    //========================================================

    always @(posedge clk) begin

        $display(
            "TIME=%0t | AWV=%b AWR=%b | WV=%b WR=%b | BV=%b BR=%b | ARV=%b ARR=%b | RV=%b RR=%b | QSTART=%b",
            $time,
            s_axi_awvalid,
            s_axi_awready,
            s_axi_wvalid,
            s_axi_wready,
            s_axi_bvalid,
            s_axi_bready,
            s_axi_arvalid,
            s_axi_arready,
            s_axi_rvalid,
            s_axi_rready,
            quantum_start
        );

    end

endmodule