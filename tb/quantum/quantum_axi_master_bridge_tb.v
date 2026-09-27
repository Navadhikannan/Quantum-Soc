`timescale 1ns/1ps

module quantum_axi_master_bridge_tb;

    //========================================================
    // CLOCK / RESET
    //========================================================

    reg clk;
    reg reset;

    always #5 clk = ~clk;

    //========================================================
    // CPU-SIDE SIGNALS
    //========================================================

    reg        quantum_write;
    reg        quantum_read;
    reg [31:0] quantum_address;
    reg [31:0] quantum_write_data;

    wire [31:0] quantum_read_data;

    //========================================================
    // AXI-LITE SIGNALS
    //========================================================

    wire [31:0] m_axi_awaddr;
    wire        m_axi_awvalid;
    reg         m_axi_awready;

    wire [31:0] m_axi_wdata;
    wire [3:0]  m_axi_wstrb;
    wire        m_axi_wvalid;
    reg         m_axi_wready;

    reg  [1:0]  m_axi_bresp;
    reg         m_axi_bvalid;
    wire        m_axi_bready;

    wire [31:0] m_axi_araddr;
    wire        m_axi_arvalid;
    reg         m_axi_arready;

    reg  [31:0] m_axi_rdata;
    reg  [1:0]  m_axi_rresp;
    reg         m_axi_rvalid;
    wire        m_axi_rready;

    //========================================================
    // DUT
    //========================================================

    quantum_axi_master_bridge DUT (

        .clk(clk),
        .reset(reset),

        .quantum_write(quantum_write),
        .quantum_read(quantum_read),
        .quantum_address(quantum_address),
        .quantum_write_data(quantum_write_data),
        .quantum_read_data(quantum_read_data),

        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),

        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),

        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),

        .m_axi_araddr(m_axi_araddr),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),

        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready)
    );

    //========================================================
    // TEST
    //========================================================

    initial begin

        clk = 0;
        reset = 1;

        quantum_write      = 0;
        quantum_read       = 0;
        quantum_address    = 0;
        quantum_write_data = 0;

        m_axi_awready = 0;
        m_axi_wready  = 0;

        m_axi_bresp  = 2'b00;
        m_axi_bvalid = 0;

        m_axi_arready = 0;

        m_axi_rdata  = 0;
        m_axi_rresp  = 2'b00;
        m_axi_rvalid = 0;

        //====================================================
        // RESET
        //====================================================

        repeat (2) @(negedge clk);

        reset = 0;

        $display("");
        $display("==============================================");
        $display(" QUANTUM AXI MASTER BRIDGE TEST");
        $display("==============================================");

        //====================================================
        // CPU WRITE REQUEST
        // Drive signals BEFORE posedge
        //====================================================

        @(negedge clk);

        quantum_address    = 32'h80000000;
        quantum_write_data = 32'h00000001;
        quantum_write      = 1'b1;

        @(posedge clk);

        #1;

        quantum_write = 1'b0;

        $display("");
        $display("[TEST] CPU WRITE REQUEST");
        $display("ADDRESS = %h", quantum_address);
        $display("DATA    = %h", quantum_write_data);

        //====================================================
        // AXI ADDRESS + DATA READY
        //====================================================

        @(negedge clk);

        m_axi_awready = 1'b1;
        m_axi_wready  = 1'b1;

        @(posedge clk);

        #1;

        $display("");
        $display("[TEST] AXI WRITE HANDSHAKE");
        $display("AWADDR  = %h", m_axi_awaddr);
        $display("WDATA   = %h", m_axi_wdata);
        $display("WSTRB   = %b", m_axi_wstrb);

        m_axi_awready = 1'b0;
        m_axi_wready  = 1'b0;

        //====================================================
        // WAIT FOR BREADY
        //====================================================

        @(negedge clk);

        #1;

        if (m_axi_bready) begin
            $display("[PASS] AXI BREADY asserted");
        end
        else begin
            $display("[FAIL] AXI BREADY not asserted");
        end

        //====================================================
        // AXI WRITE RESPONSE
        //====================================================

        m_axi_bresp  = 2'b00;
        m_axi_bvalid = 1'b1;

        @(posedge clk);

        #1;

        if (m_axi_bready) begin
            $display("[PASS] AXI BREADY handshake");
        end
        else begin
            $display("[FAIL] AXI BREADY handshake");
        end

        @(negedge clk);

        m_axi_bvalid = 1'b0;

        //====================================================
        // WAIT
        //====================================================

        repeat (2) @(posedge clk);

        //====================================================
        // CPU READ REQUEST
        //====================================================

        @(negedge clk);

        quantum_address = 32'h80000004;
        quantum_read    = 1'b1;

        @(posedge clk);

        #1;

        quantum_read = 1'b0;

        $display("");
        $display("[TEST] CPU READ REQUEST");
        $display("ADDRESS = %h", quantum_address);

        //====================================================
        // AXI READ ADDRESS READY
        //====================================================

        @(negedge clk);

        m_axi_arready = 1'b1;

        @(posedge clk);

        #1;

        $display("");
        $display("[TEST] AXI READ ADDRESS");
        $display("ARADDR  = %h", m_axi_araddr);

        if (m_axi_araddr == 32'h80000004)
            $display("[PASS] ARADDR CORRECT");
        else
            $display("[FAIL] ARADDR INCORRECT");

        @(negedge clk);

        m_axi_arready = 1'b0;

        //====================================================
        // WAIT FOR RREADY
        //====================================================

        @(negedge clk);

        #1;

        if (m_axi_rready) begin
            $display("[PASS] AXI RREADY asserted");
        end
        else begin
            $display("[FAIL] AXI RREADY not asserted");
        end

        //====================================================
        // AXI READ DATA RESPONSE
        //====================================================

        m_axi_rdata  = 32'h00000002;
        m_axi_rresp  = 2'b00;
        m_axi_rvalid = 1'b1;

        @(posedge clk);

        #1;

        if (m_axi_rready) begin
            $display("[PASS] AXI RREADY handshake");
        end
        else begin
            $display("[FAIL] AXI RREADY handshake");
        end

        @(negedge clk);

        m_axi_rvalid = 1'b0;

        //====================================================
        // CHECK READ DATA
        //====================================================

        repeat (2) @(posedge clk);

        $display("");
        $display("==============================================");
        $display(" READ DATA = %h", quantum_read_data);
        $display("==============================================");

        if (quantum_read_data == 32'h00000002)
            $display("[PASS] READ DATA CORRECT");
        else
            $display("[FAIL] READ DATA INCORRECT");

        //====================================================
        // COMPLETE
        //====================================================

        $display("");
        $display("==============================================");
        $display(" BRIDGE TEST COMPLETE");
        $display("==============================================");

        $finish;

    end

endmodule