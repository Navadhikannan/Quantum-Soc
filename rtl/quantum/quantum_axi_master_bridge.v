module quantum_axi_master_bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                     clk,
    input  wire                     reset,

    //========================================================
    // CPU-SIDE QUANTUM INTERFACE
    //========================================================

    input  wire                     quantum_write,
    input  wire                     quantum_read,
    input  wire [ADDR_WIDTH-1:0]    quantum_address,
    input  wire [DATA_WIDTH-1:0]    quantum_write_data,

    output reg  [DATA_WIDTH-1:0]    quantum_read_data,

    //========================================================
    // AXI-LITE MASTER
    //========================================================

    // Write Address Channel
    output reg  [ADDR_WIDTH-1:0]    m_axi_awaddr,
    output reg                      m_axi_awvalid,
    input  wire                     m_axi_awready,

    // Write Data Channel
    output reg  [DATA_WIDTH-1:0]    m_axi_wdata,
    output reg  [DATA_WIDTH/8-1:0]  m_axi_wstrb,
    output reg                      m_axi_wvalid,
    input  wire                     m_axi_wready,

    // Write Response Channel
    input  wire [1:0]                m_axi_bresp,
    input  wire                     m_axi_bvalid,
    output reg                      m_axi_bready,

    // Read Address Channel
    output reg  [ADDR_WIDTH-1:0]    m_axi_araddr,
    output reg                      m_axi_arvalid,
    input  wire                     m_axi_arready,

    // Read Data Channel
    input  wire [DATA_WIDTH-1:0]    m_axi_rdata,
    input  wire [1:0]                m_axi_rresp,
    input  wire                     m_axi_rvalid,
    output reg                      m_axi_rready
);

    //========================================================
    // FSM STATES
    //========================================================

    localparam STATE_IDLE      = 3'd0;
    localparam STATE_WRITE     = 3'd1;
    localparam STATE_WRITE_RESP= 3'd2;
    localparam STATE_READ      = 3'd3;
    localparam STATE_READ_RESP = 3'd4;

    reg [2:0] state;

    //========================================================
    // SEQUENTIAL CONTROL
    //========================================================

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            state <= STATE_IDLE;

            m_axi_awaddr  <= {ADDR_WIDTH{1'b0}};
            m_axi_awvalid <= 1'b0;

            m_axi_wdata   <= {DATA_WIDTH{1'b0}};
            m_axi_wstrb   <= {(DATA_WIDTH/8){1'b0}};
            m_axi_wvalid  <= 1'b0;

            m_axi_bready  <= 1'b0;

            m_axi_araddr  <= {ADDR_WIDTH{1'b0}};
            m_axi_arvalid <= 1'b0;

            m_axi_rready  <= 1'b0;

            quantum_read_data <= {DATA_WIDTH{1'b0}};

        end

        else begin

            case (state)

                //================================================
                // IDLE
                //================================================

                STATE_IDLE: begin

                    m_axi_awvalid <= 1'b0;
                    m_axi_wvalid  <= 1'b0;
                    m_axi_bready  <= 1'b0;

                    m_axi_arvalid <= 1'b0;
                    m_axi_rready  <= 1'b0;

                    // CPU WRITE
                    if (quantum_write) begin

                        m_axi_awaddr  <= quantum_address;
                        m_axi_awvalid <= 1'b1;

                        m_axi_wdata   <= quantum_write_data;
                        m_axi_wstrb   <= 4'b1111;
                        m_axi_wvalid  <= 1'b1;

                        state <= STATE_WRITE;

                    end

                    // CPU READ
                    else if (quantum_read) begin

                        m_axi_araddr  <= quantum_address;
                        m_axi_arvalid <= 1'b1;

                        state <= STATE_READ;

                    end

                end


                //================================================
                // WRITE
                //================================================

                STATE_WRITE: begin

                    // Keep VALID asserted until handshake
                    if (m_axi_awvalid && m_axi_awready)
                        m_axi_awvalid <= 1'b0;

                    if (m_axi_wvalid && m_axi_wready)
                        m_axi_wvalid <= 1'b0;

                    // Both channels completed
                    if ((!m_axi_awvalid || m_axi_awready) &&
                        (!m_axi_wvalid  || m_axi_wready)) begin

                        m_axi_bready <= 1'b1;

                        state <= STATE_WRITE_RESP;

                    end

                end


                //================================================
                // WRITE RESPONSE
                //================================================

                STATE_WRITE_RESP: begin

                    if (m_axi_bvalid && m_axi_bready) begin

                        m_axi_bready <= 1'b0;

                        state <= STATE_IDLE;

                    end

                end


                //================================================
                // READ ADDRESS
                //================================================

                STATE_READ: begin

                    if (m_axi_arvalid && m_axi_arready) begin

                        m_axi_arvalid <= 1'b0;
                        m_axi_rready  <= 1'b1;

                        state <= STATE_READ_RESP;

                    end

                end


                //================================================
                // READ RESPONSE
                //================================================

                STATE_READ_RESP: begin

                    if (m_axi_rvalid && m_axi_rready) begin

                        quantum_read_data <= m_axi_rdata;

                        m_axi_rready <= 1'b0;

                        state <= STATE_IDLE;

                    end

                end


                //================================================
                // DEFAULT
                //================================================

                default: begin

                    state <= STATE_IDLE;

                end

            endcase

        end

    end

endmodule