`timescale 1ns/1ps

module quantum_axi_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                     clk,
    input  wire                     reset,

    //========================================================
    // AXI-Lite WRITE ADDRESS CHANNEL
    //========================================================
    input  wire [ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  wire                     s_axi_awvalid,
    output wire                     s_axi_awready,

    //========================================================
    // AXI-Lite WRITE DATA CHANNEL
    //========================================================
    input  wire [DATA_WIDTH-1:0]    s_axi_wdata,
    input  wire [DATA_WIDTH/8-1:0]  s_axi_wstrb,
    input  wire                     s_axi_wvalid,
    output wire                     s_axi_wready,

    //========================================================
    // AXI-Lite WRITE RESPONSE CHANNEL
    //========================================================
    output reg [1:0]                s_axi_bresp,
    output reg                      s_axi_bvalid,
    input  wire                     s_axi_bready,

    //========================================================
    // AXI-Lite READ ADDRESS CHANNEL
    //========================================================
    input  wire [ADDR_WIDTH-1:0]    s_axi_araddr,
    input  wire                     s_axi_arvalid,
    output wire                     s_axi_arready,

    //========================================================
    // AXI-Lite READ DATA CHANNEL
    //========================================================
    output reg [DATA_WIDTH-1:0]     s_axi_rdata,
    output reg [1:0]                s_axi_rresp,
    output reg                      s_axi_rvalid,
    input  wire                     s_axi_rready,

    //========================================================
    // QUANTUM DOMAIN INTERFACE
    //========================================================
    output reg                      quantum_start,

    input  wire                     quantum_busy,
    input  wire                     quantum_done,
    input  wire                     quantum_error,

    input  wire [63:0]               quantum_key,
    input  wire [6:0]                quantum_key_length
);

    //========================================================
    // REGISTER MAP
    //========================================================

    localparam [ADDR_WIDTH-1:0] CONTROL_ADDR =
        32'h80000000;

    localparam [ADDR_WIDTH-1:0] STATUS_ADDR =
        32'h80000004;

    localparam [ADDR_WIDTH-1:0] KEY_LO_ADDR =
        32'h80000008;

    localparam [ADDR_WIDTH-1:0] KEY_HI_ADDR =
        32'h8000000C;

    localparam [ADDR_WIDTH-1:0] KEY_LENGTH_ADDR =
        32'h80000010;

    //========================================================
    // WRITE CHANNEL REGISTERS
    //========================================================

    reg [ADDR_WIDTH-1:0]   awaddr_reg;
    reg                     awaddr_valid;

    reg [DATA_WIDTH-1:0]    wdata_reg;
    reg [DATA_WIDTH/8-1:0]  wstrb_reg;
    reg                     wdata_valid;

    //========================================================
    // AXI READY
    //
    // Address and data channels are independent.
    //========================================================

    assign s_axi_awready =
        !awaddr_valid &&
        !s_axi_bvalid;

    assign s_axi_wready =
        !wdata_valid &&
        !s_axi_bvalid;

    assign s_axi_arready =
        !s_axi_rvalid;

    //========================================================
    // SEQUENTIAL LOGIC
    //========================================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            // Write state
            awaddr_reg   <= {ADDR_WIDTH{1'b0}};
            awaddr_valid <= 1'b0;

            wdata_reg    <= {DATA_WIDTH{1'b0}};
            wstrb_reg    <= {(DATA_WIDTH/8){1'b0}};
            wdata_valid  <= 1'b0;

            // Write response
            s_axi_bresp  <= 2'b00;
            s_axi_bvalid <= 1'b0;

            // Read response
            s_axi_rdata  <= {DATA_WIDTH{1'b0}};
            s_axi_rresp  <= 2'b00;
            s_axi_rvalid <= 1'b0;

            // Quantum control
            quantum_start <= 1'b0;

        end

        else begin

            //================================================
            // DEFAULT QUANTUM START
            //
            // One-clock pulse.
            //================================================

            quantum_start <= 1'b0;

            //================================================
            // WRITE ADDRESS HANDSHAKE
            //================================================

            if (s_axi_awvalid && s_axi_awready) begin

                awaddr_reg   <= s_axi_awaddr;
                awaddr_valid <= 1'b1;

            end

            //================================================
            // WRITE DATA HANDSHAKE
            //================================================

            if (s_axi_wvalid && s_axi_wready) begin

                wdata_reg   <= s_axi_wdata;
                wstrb_reg   <= s_axi_wstrb;
                wdata_valid <= 1'b1;

            end

            //================================================
            // WRITE EXECUTION
            //
            // Because AW and W are independent, this block
            // waits until both have been captured.
            //================================================

            if (awaddr_valid &&
                wdata_valid &&
                !s_axi_bvalid) begin

                case (awaddr_reg)

                    //========================================
                    // CONTROL REGISTER
                    // bit 0 = START
                    //========================================

                    CONTROL_ADDR: begin

                        if (wdata_reg[0] &&
                            wstrb_reg[0]) begin

                            quantum_start <= 1'b1;

                        end

                    end

                    //========================================
                    // Other registers are currently read-only.
                    //========================================

                    default: begin

                        // No action.
                        // Still return AXI OKAY response.

                    end

                endcase

                // Generate OKAY response
                s_axi_bresp  <= 2'b00;
                s_axi_bvalid <= 1'b1;

                // Clear captured transaction
                awaddr_valid <= 1'b0;
                wdata_valid  <= 1'b0;

            end

            //================================================
            // WRITE RESPONSE HANDSHAKE
            //================================================

            if (s_axi_bvalid &&
                s_axi_bready) begin

                s_axi_bvalid <= 1'b0;

            end

            //================================================
            // READ ADDRESS HANDSHAKE
            //================================================

            if (s_axi_arvalid &&
                s_axi_arready) begin

                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= 2'b00;

                case (s_axi_araddr)

                    //========================================
                    // STATUS REGISTER
                    //
                    // bit 0 = BUSY
                    // bit 1 = DONE
                    // bit 2 = ERROR
                    //========================================

                    STATUS_ADDR: begin

                        s_axi_rdata <= {
                            29'd0,
                            quantum_error,
                            quantum_done,
                            quantum_busy
                        };

                    end

                    //========================================
                    // KEY LOW
                    //========================================

                    KEY_LO_ADDR: begin

                        s_axi_rdata <= quantum_key[31:0];

                    end

                    //========================================
                    // KEY HIGH
                    //========================================

                    KEY_HI_ADDR: begin

                        s_axi_rdata <= quantum_key[63:32];

                    end

                    //========================================
                    // KEY LENGTH
                    //========================================

                    KEY_LENGTH_ADDR: begin

                        s_axi_rdata <= {
                            25'd0,
                            quantum_key_length
                        };

                    end

                    //========================================
                    // INVALID ADDRESS
                    //========================================

                    default: begin

                        s_axi_rdata <= 32'd0;
                        s_axi_rresp <= 2'b11;

                    end

                endcase

            end

            //================================================
            // READ RESPONSE HANDSHAKE
            //================================================

            if (s_axi_rvalid &&
                s_axi_rready) begin

                s_axi_rvalid <= 1'b0;

            end

        end

    end

endmodule