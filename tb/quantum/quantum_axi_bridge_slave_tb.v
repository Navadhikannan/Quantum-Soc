`timescale 1ns/1ps

module quantum_axi_bridge_slave_tb;

    reg clk;
    reg reset;

    //========================================================
    // CPU-SIDE INTERFACE
    //========================================================

    reg        quantum_write;
    reg        quantum_read;
    reg [31:0] quantum_address;
    reg [31:0] quantum_write_data;
    wire [31:0] quantum_read_data;

    //========================================================
    // BRIDGE ↔ SLAVE AXI-LITE
    //========================================================

    wire [31:0] awaddr;
    wire        awvalid;
    wire        awready;

    wire [31:0] wdata;
    wire [3:0]  wstrb;
    wire        wvalid;
    wire        wready;

    wire [1:0]  bresp;
    wire        bvalid;
    wire        bready;

    wire [31:0] araddr;
    wire        arvalid;
    wire        arready;

    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    wire        rready;

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
    // CLOCK
    //========================================================

    always #5 clk = ~clk;

    //========================================================
    // MASTER BRIDGE
    //========================================================

    quantum_axi_master_bridge MASTER (

        .clk(clk),
        .reset(reset),

        .quantum_write(quantum_write),
        .quantum_read(quantum_read),
        .quantum_address(quantum_address),
        .quantum_write_data(quantum_write_data),
        .quantum_read_data(quantum_read_data),

        .m_axi_awaddr(awaddr),
        .m_axi_awvalid(awvalid),
        .m_axi_awready(awready),

        .m_axi_wdata(wdata),
        .m_axi_wstrb(wstrb),
        .m_axi_wvalid(wvalid),
        .m_axi_wready(wready),

        .m_axi_bresp(bresp),
        .m_axi_bvalid(bvalid),
        .m_axi_bready(bready),

        .m_axi_araddr(araddr),
        .m_axi_arvalid(arvalid),
        .m_axi_arready(arready),

        .m_axi_rdata(rdata),
        .m_axi_rresp(rresp),
        .m_axi_rvalid(rvalid),
        .m_axi_rready(rready)
    );

    //========================================================
    // AXI SLAVE
    //========================================================

    quantum_axi_slave SLAVE (

        .clk(clk),
        .reset(reset),

        .s_axi_awaddr(awaddr),
        .s_axi_awvalid(awvalid),
        .s_axi_awready(awready),

        .s_axi_wdata(wdata),
        .s_axi_wstrb(wstrb),
        .s_axi_wvalid(wvalid),
        .s_axi_wready(wready),

        .s_axi_bresp(bresp),
        .s_axi_bvalid(bvalid),
        .s_axi_bready(bready),

        .s_axi_araddr(araddr),
        .s_axi_arvalid(arvalid),
        .s_axi_arready(arready),

        .s_axi_rdata(rdata),
        .s_axi_rresp(rresp),
        .s_axi_rvalid(rvalid),
        .s_axi_rready(rready),

        .quantum_start(quantum_start),

        .quantum_busy(quantum_busy),
        .quantum_done(quantum_done),
        .quantum_error(quantum_error),

        .quantum_key(quantum_key),
        .quantum_key_length(quantum_key_length)
    );

    //========================================================
    // TEST
    //========================================================


reg quantum_start_seen;

always @(posedge clk) begin
    if (quantum_start) begin
        quantum_start_seen <= 1'b1;
        $display("[PASS] QUANTUM START PULSE DETECTED");
    end
end
    initial begin

        clk = 0;
        reset = 1;

        quantum_start_seen = 1'b0;

        quantum_write      = 0;
        quantum_read       = 0;
        quantum_address    = 0;
        quantum_write_data = 0;

        quantum_busy       = 0;
        quantum_done       = 0;
        quantum_error      = 0;
        quantum_key        = 64'h810314305A280090;
        quantum_key_length = 7'd32;

        //====================================================
        // RESET
        //====================================================

        repeat (3) @(negedge clk);
        reset = 0;

        $display("");
        $display("==============================================");
        $display(" BRIDGE + AXI SLAVE INTEGRATION TEST");
        $display("==============================================");

        //====================================================
        // CPU WRITE → CONTROL
        //====================================================

        @(negedge clk);

        quantum_address    = 32'h80000000;
        quantum_write_data = 32'h00000001;
        quantum_write      = 1'b1;

        @(posedge clk);
        #1;

        quantum_write = 1'b0;

        $display("");
        $display("[TEST] CPU WRITE");
        $display("ADDRESS = %h", quantum_address);
        $display("DATA    = %h", quantum_write_data);

        //====================================================
        // WAIT FOR QUANTUM START
        //====================================================

if (quantum_start) begin
    $display("[PASS] QUANTUM START PULSE");
end
else begin

    @(posedge clk);
    #1;

    if (quantum_start) begin
        $display("[PASS] QUANTUM START PULSE");
    end
    else begin

        @(posedge clk);
        #1;

        if (quantum_start)
            $display("[PASS] QUANTUM START PULSE");
        else
            $display("[FAIL] QUANTUM START PULSE");

    end

end

        //====================================================
        // WAIT FOR WRITE RESPONSE TO COMPLETE
        //====================================================

        repeat (3) @(posedge clk);

        //====================================================
        // SIMULATE QUANTUM COMPLETION
        //====================================================

        quantum_done = 1'b1;

        $display("");
        $display("[TEST] QUANTUM DOMAIN COMPLETED");

        //====================================================
        // READ STATUS
        //====================================================

        @(negedge clk);

        quantum_address = 32'h80000004;
        quantum_read    = 1'b1;

        @(posedge clk);
        #1;

        quantum_read = 1'b0;

        // Wait for AXI read response
        wait (rvalid == 1'b1);

        #1;

        $display("");
        $display("[TEST] STATUS READ");
        $display("ADDRESS = %h", quantum_address);
        $display("RDATA   = %h", rdata);

        @(posedge clk);
        #1;

        repeat (2) @(posedge clk);

        if (quantum_read_data == 32'h00000002)
            $display("[PASS] STATUS READ CORRECT");
        else
            $display("[FAIL] STATUS READ = %h",
                     quantum_read_data);

        //====================================================
        // READ KEY LOW
        //====================================================

        @(negedge clk);

        quantum_address = 32'h80000008;
        quantum_read    = 1'b1;

        @(posedge clk);
        #1;

        quantum_read = 1'b0;

        wait (rvalid == 1'b1);

        #1;

        $display("");
        $display("[TEST] KEY LOW READ");
        $display("RDATA = %h", rdata);

        @(posedge clk);
        #1;

        repeat (2) @(posedge clk);

        if (quantum_read_data == 32'h5A280090)
            $display("[PASS] KEY LOW CORRECT");
        else
            $display("[FAIL] KEY LOW INCORRECT");

        //====================================================
        // READ KEY HIGH
        //====================================================

        @(negedge clk);

        quantum_address = 32'h8000000C;
        quantum_read    = 1'b1;

        @(posedge clk);
        #1;

        quantum_read = 1'b0;

        wait (rvalid == 1'b1);

        #1;

        $display("");
        $display("[TEST] KEY HIGH READ");
        $display("RDATA = %h", rdata);

        @(posedge clk);
        #1;

        repeat (2) @(posedge clk);

        if (quantum_read_data == 32'h81031430)
            $display("[PASS] KEY HIGH CORRECT");
        else
            $display("[FAIL] KEY HIGH INCORRECT");

        //====================================================
        // READ KEY LENGTH
        //====================================================

        @(negedge clk);

        quantum_address = 32'h80000010;
        quantum_read    = 1'b1;

        @(posedge clk);
        #1;

        quantum_read = 1'b0;

        wait (rvalid == 1'b1);

        #1;

        $display("");
        $display("[TEST] KEY LENGTH READ");
        $display("RDATA = %h", rdata);

        @(posedge clk);
        #1;

        repeat (2) @(posedge clk);

        if (quantum_read_data == 32'h00000020)
            $display("[PASS] KEY LENGTH CORRECT");
        else
            $display("[FAIL] KEY LENGTH INCORRECT");

        //====================================================
        // FINAL
        //====================================================

        $display("");
        $display("==============================================");
        $display(" BRIDGE + AXI SLAVE TEST COMPLETE");
        $display("==============================================");

        $finish;

    end

endmodule