`timescale 1ns/1ps

module quantum_axi_quantum_top #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter KEY_WIDTH = 64,
    parameter MIN_KEY_LENGTH = 16
)(
    input wire clk,
    input wire reset,

    input wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output wire s_axi_awready,

    input wire [DATA_WIDTH-1:0] s_axi_wdata,
    input wire [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,

    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    input wire s_axi_bready,

    input wire [ADDR_WIDTH-1:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output wire s_axi_arready,

    output wire [DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    input wire s_axi_rready
);

    wire quantum_start;

    wire quantum_busy;
    wire quantum_done;
    wire quantum_error;

    wire [KEY_WIDTH-1:0] quantum_key;
    wire [6:0] quantum_key_length;
    wire quantum_key_valid;

    //========================================================
    // AXI-LITE SLAVE
    //========================================================

    quantum_axi_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_axi_slave (
        .clk(clk),
        .reset(reset),

        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),

        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),

        .quantum_start(quantum_start),

        .quantum_busy(quantum_busy),
        .quantum_done(quantum_done),
        .quantum_error(quantum_error),

        .quantum_key(quantum_key),
        .quantum_key_length(quantum_key_length)
    );

    //========================================================
    // QUANTUM DOMAIN
    //========================================================

    quantum_domain_top #(
        .KEY_WIDTH(KEY_WIDTH),
        .MIN_KEY_LENGTH(MIN_KEY_LENGTH)
    ) u_quantum_domain (
        .clk(clk),
        .reset(reset),
        .start(quantum_start),

        .key_data(quantum_key),
        .key_length(quantum_key_length),
        .key_valid(quantum_key_valid),

        .busy(quantum_busy),
        .done(quantum_done),
        .error(quantum_error)
    );

endmodule