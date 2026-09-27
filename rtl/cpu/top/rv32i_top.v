module rv32i_top #(
    parameter XLEN = 32
)(
    input  wire clk,
    input  wire reset
);

//////////////////////////////////////////////////////////////
// IF → ID Signals
//////////////////////////////////////////////////////////////

wire [XLEN-1:0] if_pc;
wire [31:0]     if_instruction;

//////////////////////////////////////////////////////////////
// ID → EX Signals
//////////////////////////////////////////////////////////////

wire [XLEN-1:0] id_pc;
wire [XLEN-1:0] id_read_data1;
wire [XLEN-1:0] id_read_data2;
wire [XLEN-1:0] id_immediate;

wire [4:0] id_rs1;
wire [4:0] id_rs2;
wire [4:0] id_rd;

wire [2:0] id_funct3;
wire [6:0] id_funct7;

wire id_reg_write;
wire id_alu_src;
wire id_mem_read;
wire id_mem_write;
wire id_mem_to_reg;
wire id_branch;
wire id_jump;
wire [1:0] id_alu_op;

//////////////////////////////////////////////////////////////
// EX → MEM Signals
//////////////////////////////////////////////////////////////

wire [31:0] ex_alu_result;
wire [31:0] ex_branch_target;
wire [31:0] ex_rs2_data;

wire [4:0] ex_rd;

wire ex_branch_taken;

wire ex_reg_write;
wire ex_mem_read;
wire ex_mem_write;
wire ex_mem_to_reg;
wire ex_branch;
wire ex_branch_taken_if;
wire [31:0] ex_branch_target_if;

//////////////////////////////////////////////////////////////
// MEM → WB Signals
//////////////////////////////////////////////////////////////

wire [31:0] mem_read_data;
wire [31:0] mem_alu_result;

wire [4:0] mem_rd;

wire mem_reg_write;
wire mem_mem_to_reg;

//////////////////////////////////////////////////////////////
// Quantum Peripheral Signals
//////////////////////////////////////////////////////////////

wire        quantum_write;
wire        quantum_read;
wire [31:0] quantum_address;
wire [31:0] quantum_write_data;
wire [31:0] quantum_read_data;

//////////////////////////////////////////////////////////////
// Quantum AXI-Lite Signals
//////////////////////////////////////////////////////////////

wire [31:0] quantum_axi_awaddr;
wire        quantum_axi_awvalid;
wire        quantum_axi_awready;

wire [31:0] quantum_axi_wdata;
wire [3:0]  quantum_axi_wstrb;
wire        quantum_axi_wvalid;
wire        quantum_axi_wready;

wire [1:0]  quantum_axi_bresp;
wire        quantum_axi_bvalid;
wire        quantum_axi_bready;

wire [31:0] quantum_axi_araddr;
wire        quantum_axi_arvalid;
wire        quantum_axi_arready;

wire [31:0] quantum_axi_rdata;
wire [1:0]  quantum_axi_rresp;
wire        quantum_axi_rvalid;
wire        quantum_axi_rready;

//////////////////////////////////////////////////////////////
// Quantum Domain Signals
//////////////////////////////////////////////////////////////

wire        quantum_start;

wire        quantum_busy;
wire        quantum_done;
wire        quantum_error;

wire [63:0] quantum_key;
wire [6:0]  quantum_key_length;


//////////////////////////////////////////////////////////////
// QUANTUM DOMAIN
//////////////////////////////////////////////////////////////

quantum_domain_top #(
    .KEY_WIDTH(64),
    .MIN_KEY_LENGTH(16)
) QUANTUM_DOMAIN (

    .clk(clk),
    .reset(reset),
    .start(quantum_start),

    .key_data(quantum_key),
    .key_length(quantum_key_length),
    .key_valid(),

    .busy(quantum_busy),
    .done(quantum_done),
    .error(quantum_error)

);

//////////////////////////////////////////////////////////////
// WB Signals
//////////////////////////////////////////////////////////////

wire [31:0] wb_write_data;

//////////////////////////////////////////////////////////////
// Forwarding Signals
//////////////////////////////////////////////////////////////

wire [1:0] forwardA;
wire [1:0] forwardB;

//////////////////////////////////////////////////////////////
// Hazard Control
//////////////////////////////////////////////////////////////

wire pc_write;
wire if_id_write;
wire control_mux;

//////////////////////////////////////////////////////////////
// Forwarding Unit
//////////////////////////////////////////////////////////////

forwarding_unit FORWARDING_UNIT (

    .ex_rs1(id_rs1),
    .ex_rs2(id_rs2),

    .mem_rd(ex_rd),
    .mem_reg_write(ex_reg_write),

    .wb_rd(mem_rd),
    .wb_reg_write(mem_reg_write),

    .forwardA(forwardA),
    .forwardB(forwardB)

);

//////////////////////////////////////////////////////////////
// Hazard Detection Unit
//////////////////////////////////////////////////////////////

hazard_detection_unit HAZARD_UNIT (

    .ex_mem_read(ex_mem_read),
    .ex_rd(ex_rd),

    .id_rs1(id_rs1),
    .id_rs2(id_rs2),

    .pc_write(pc_write),
    .if_id_write(if_id_write),
    .control_mux(control_mux)

);

//////////////////////////////////////////////////////////////
// Jump Signals
//////////////////////////////////////////////////////////////

wire jump_taken_if;
wire [31:0] jump_target_if;

//////////////////////////////////////////////////////////////
// Instruction Fetch Stage
//////////////////////////////////////////////////////////////

instruction_fetch_top #(
    .XLEN(XLEN)
) IF_STAGE (

    .clk(clk),
    .reset(reset),

    .branch_taken(ex_branch_taken_if),
    .branch_target(ex_branch_target_if),

    .jump_taken(jump_taken_if),
    .jump_target(jump_target_if),

    .pc_write(pc_write),
    .if_id_write(if_id_write),

    .pc_out(if_pc),
    .instruction_out(if_instruction)

);

//////////////////////////////////////////////////////////////
// Decode Stage
//////////////////////////////////////////////////////////////

decode_top #(
    .XLEN(XLEN)
) ID_STAGE (

    .clk(clk),
    .reset(reset),

    .write_enable(1'b1),
    .branch_taken(ex_branch_taken_if),

    .instruction(if_instruction),
    .pc(if_pc),

    .reg_write_wb(mem_reg_write),
    .rd_wb(mem_rd),
    .write_data_wb(wb_write_data),

    .pc_out(id_pc),

    .read_data1_out(id_read_data1),
    .read_data2_out(id_read_data2),
    .immediate_out(id_immediate),

    .rs1_out(id_rs1),
    .rs2_out(id_rs2),
    .rd_out(id_rd),

    .funct3_out(id_funct3),
    .funct7_out(id_funct7),

    .reg_write_out(id_reg_write),
    .alu_src_out(id_alu_src),
    .mem_read_out(id_mem_read),
    .mem_write_out(id_mem_write),
    .mem_to_reg_out(id_mem_to_reg),
    .branch_out(id_branch),
    .jump_out(id_jump),
    .alu_op_out(id_alu_op),

    .pc_write(pc_write),
    .if_id_write(if_id_write),
    .control_mux(control_mux)

);

//////////////////////////////////////////////////////////////
// Execute Stage
//////////////////////////////////////////////////////////////

execute_top #(
    .XLEN(XLEN)
) EX_STAGE (

    .clk(clk),
    .reset(reset),

    .pc(id_pc),

    .read_data1(id_read_data1),
    .read_data2(id_read_data2),

    .immediate(id_immediate),

    .rs1(id_rs1),
    .rs2(id_rs2),
    .rd(id_rd),

    .forwardA(forwardA),
    .forwardB(forwardB),

    .ex_mem_data(ex_alu_result),
    .mem_wb_data(wb_write_data),

    .funct3(id_funct3),
    .funct7(id_funct7),

    .reg_write(id_reg_write),
    .alu_src(id_alu_src),
    .mem_read(id_mem_read),
    .mem_write(id_mem_write),
    .mem_to_reg(id_mem_to_reg),
    .branch(id_branch),
    .jump(id_jump),
    .alu_op(id_alu_op),

    .alu_result(ex_alu_result),
    .branch_target(ex_branch_target),
    .rs2_data(ex_rs2_data),

    .rd_out(ex_rd),

    .branch_taken(ex_branch_taken),

    .reg_write_out(ex_reg_write),
    .mem_read_out(ex_mem_read),
    .mem_write_out(ex_mem_write),
    .mem_to_reg_out(ex_mem_to_reg),
    .branch_out(ex_branch),
    .branch_target_if(ex_branch_target_if),
    .branch_taken_if(ex_branch_taken_if),

    .jump_taken_if(jump_taken_if),
    .jump_target_if(jump_target_if)

);

//////////////////////////////////////////////////////////////
// Memory Stage
//////////////////////////////////////////////////////////////

memory_top #(
    .XLEN(XLEN)
) MEM_STAGE (

    .clk(clk),
    .reset(reset),

    //========================================================
    // EX/MEM → Memory
    //========================================================

    .alu_result(ex_alu_result),
    .rs2_data(ex_rs2_data),
    .rd(ex_rd),

    .reg_write(ex_reg_write),
    .mem_read(ex_mem_read),
    .mem_write(ex_mem_write),
    .mem_to_reg(ex_mem_to_reg),

    //========================================================
    // Quantum Peripheral Interface
    //========================================================

    .quantum_write(quantum_write),
    .quantum_read(quantum_read),
    .quantum_address(quantum_address),
    .quantum_write_data(quantum_write_data),
    .quantum_read_data(quantum_read_data),

    //========================================================
    // Memory → WB
    //========================================================

    .read_data_out(mem_read_data),
    .alu_result_out(mem_alu_result),

    .rd_out(mem_rd),

    .reg_write_out(mem_reg_write),
    .mem_to_reg_out(mem_mem_to_reg)

);

//////////////////////////////////////////////////////////////
// Quantum AXI-Lite Master Bridge
//////////////////////////////////////////////////////////////

quantum_axi_master_bridge #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
) QUANTUM_AXI_BRIDGE (

    .clk(clk),
    .reset(reset),

    //========================================================
    // CPU / Memory Side
    //========================================================

    .quantum_write(quantum_write),
    .quantum_read(quantum_read),
    .quantum_address(quantum_address),
    .quantum_write_data(quantum_write_data),
    .quantum_read_data(quantum_read_data),

    //========================================================
    // AXI Write Address
    //========================================================

    .m_axi_awaddr(quantum_axi_awaddr),
    .m_axi_awvalid(quantum_axi_awvalid),
    .m_axi_awready(quantum_axi_awready),

    //========================================================
    // AXI Write Data
    //========================================================

    .m_axi_wdata(quantum_axi_wdata),
    .m_axi_wstrb(quantum_axi_wstrb),
    .m_axi_wvalid(quantum_axi_wvalid),
    .m_axi_wready(quantum_axi_wready),

    //========================================================
    // AXI Write Response
    //========================================================

    .m_axi_bresp(quantum_axi_bresp),
    .m_axi_bvalid(quantum_axi_bvalid),
    .m_axi_bready(quantum_axi_bready),

    //========================================================
    // AXI Read Address
    //========================================================

    .m_axi_araddr(quantum_axi_araddr),
    .m_axi_arvalid(quantum_axi_arvalid),
    .m_axi_arready(quantum_axi_arready),

    //========================================================
    // AXI Read Data
    //========================================================

    .m_axi_rdata(quantum_axi_rdata),
    .m_axi_rresp(quantum_axi_rresp),
    .m_axi_rvalid(quantum_axi_rvalid),
    .m_axi_rready(quantum_axi_rready)

);

//////////////////////////////////////////////////////////////
// Quantum AXI-Lite Slave
//////////////////////////////////////////////////////////////

quantum_axi_slave #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
) QUANTUM_AXI_SLAVE (

    .clk(clk),
    .reset(reset),

    //========================================================
    // AXI Write Address
    //========================================================

    .s_axi_awaddr(quantum_axi_awaddr),
    .s_axi_awvalid(quantum_axi_awvalid),
    .s_axi_awready(quantum_axi_awready),

    //========================================================
    // AXI Write Data
    //========================================================

    .s_axi_wdata(quantum_axi_wdata),
    .s_axi_wstrb(quantum_axi_wstrb),
    .s_axi_wvalid(quantum_axi_wvalid),
    .s_axi_wready(quantum_axi_wready),

    //========================================================
    // AXI Write Response
    //========================================================

    .s_axi_bresp(quantum_axi_bresp),
    .s_axi_bvalid(quantum_axi_bvalid),
    .s_axi_bready(quantum_axi_bready),

    //========================================================
    // AXI Read Address
    //========================================================

    .s_axi_araddr(quantum_axi_araddr),
    .s_axi_arvalid(quantum_axi_arvalid),
    .s_axi_arready(quantum_axi_arready),

    //========================================================
    // AXI Read Data
    //========================================================

    .s_axi_rdata(quantum_axi_rdata),
    .s_axi_rresp(quantum_axi_rresp),
    .s_axi_rvalid(quantum_axi_rvalid),
    .s_axi_rready(quantum_axi_rready),

    //========================================================
    // Quantum Domain
    //========================================================

    .quantum_start(quantum_start),

    .quantum_busy(quantum_busy),
    .quantum_done(quantum_done),
    .quantum_error(quantum_error),

    .quantum_key(quantum_key),
    .quantum_key_length(quantum_key_length)

);

//////////////////////////////////////////////////////////////
// WRITE BACK STAGE
//////////////////////////////////////////////////////////////

write_back #(
    .XLEN(XLEN)
) WB_STAGE (

    .read_data(mem_read_data),
    .alu_result(mem_alu_result),

    .mem_to_reg(mem_mem_to_reg),

    .write_back_data(wb_write_data)

);

//////////////////////////////////////////////////////////////
// CPU DEBUG
//////////////////////////////////////////////////////////////

always @(posedge clk) begin

    $display("------------------------------------");

    $display("PC              = %h", id_pc);
    $display("Instruction     = %h", if_instruction);

    $display("id_jump         = %b", id_jump);
    $display("jump_taken_if   = %b", jump_taken_if);
    $display("jump_target_if  = %h", jump_target_if);

    $display("branch_taken_if = %b",
             ex_branch_taken_if);

    $display("branch_target_if = %h",
             ex_branch_target_if);

end

//////////////////////////////////////////////////////////////
// QUANTUM MEMORY-MAPPED DEBUG
//////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if (quantum_write || quantum_read) begin

        $display("");
        $display("==============================================");
        $display("        QUANTUM MEMORY ACCESS");
        $display("==============================================");

        $display("TIME          = %0t", $time);
        $display("ADDRESS       = %h", quantum_address);
        $display("WRITE         = %b", quantum_write);
        $display("READ          = %b", quantum_read);
        $display("WRITE DATA    = %h", quantum_write_data);

        $display("==============================================");

    end

end

//////////////////////////////////////////////////////////////
// AXI DEBUG
//////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if (quantum_axi_awvalid ||
        quantum_axi_wvalid ||
        quantum_axi_bvalid ||
        quantum_axi_arvalid ||
        quantum_axi_rvalid) begin

        $display("");
        $display("==============================================");
        $display("          QUANTUM AXI-LITE TRANSACTION");
        $display("==============================================");

        $display("AW : VALID=%b READY=%b ADDR=%h",
                 quantum_axi_awvalid,
                 quantum_axi_awready,
                 quantum_axi_awaddr);

        $display("W  : VALID=%b READY=%b DATA=%h",
                 quantum_axi_wvalid,
                 quantum_axi_wready,
                 quantum_axi_wdata);

        $display("B  : VALID=%b READY=%b RESP=%b",
                 quantum_axi_bvalid,
                 quantum_axi_bready,
                 quantum_axi_bresp);

        $display("AR : VALID=%b READY=%b ADDR=%h",
                 quantum_axi_arvalid,
                 quantum_axi_arready,
                 quantum_axi_araddr);

        $display("R  : VALID=%b READY=%b DATA=%h RESP=%b",
                 quantum_axi_rvalid,
                 quantum_axi_rready,
                 quantum_axi_rdata,
                 quantum_axi_rresp);

        $display("QUANTUM START = %b", quantum_start);

        $display("==============================================");

    end

end

always @(posedge clk) begin
    if (id_branch) begin
        $display("");
        $display("*************** BRANCH DEBUG ***************");
        $display("PC              = %h", id_pc);
        $display("RS1             = x%0d", id_rs1);
        $display("RS2             = x%0d", id_rs2);
        $display("READ_DATA1      = %h", id_read_data1);
        $display("READ_DATA2      = %h", id_read_data2);
        $display("FORWARD_A       = %b", forwardA);
        $display("FORWARD_B       = %b", forwardB);
        $display("EX_ALU_RESULT    = %h", ex_alu_result);
        $display("WB_WRITE_DATA    = %h", wb_write_data);
        $display("BRANCH_TAKEN_IF  = %b", ex_branch_taken_if);
        $display("BRANCH_TARGET_IF = %h", ex_branch_target_if);
        $display("*********************************************");
    end
end

endmodule