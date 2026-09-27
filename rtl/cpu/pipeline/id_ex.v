module id_ex #(
    parameter XLEN = 32
)(
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire flush,

    //==========================================================
    // Datapath Inputs
    //==========================================================

    input wire [XLEN-1:0] pc_in,
    input wire [XLEN-1:0] read_data1_in,
    input wire [XLEN-1:0] read_data2_in,
    input wire [XLEN-1:0] immediate_in,

    input wire [4:0] rs1_in,
    input wire [4:0] rs2_in,
    input wire [4:0] rd_in,

    //==========================================================
    // Control Inputs
    //==========================================================

    input wire reg_write_in,
    input wire alu_src_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,
    input wire branch_in,
    input wire jump_in,
    input wire [1:0] alu_op_in,
    // Datapath Inputs
    input wire [2:0] funct3_in,
    input wire [6:0] funct7_in,

    //==========================================================
    // Datapath Outputs
    //==========================================================

    output reg [XLEN-1:0] pc_out,
    output reg [XLEN-1:0] read_data1_out,
    output reg [XLEN-1:0] read_data2_out,
    output reg [XLEN-1:0] immediate_out,

    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,

    //==========================================================
    // Control Outputs
    //==========================================================

    output reg reg_write_out,
    output reg alu_src_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg branch_out,
    output reg jump_out,
    output reg [1:0] alu_op_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out
);

always @(posedge clk) begin
    

    //----------------------------------------------------------
    // Reset
    //----------------------------------------------------------

    if (reset || flush) begin

        pc_out          <= 0;
        read_data1_out  <= 0;
        read_data2_out  <= 0;
        immediate_out   <= 0;

        rs1_out <= 0;
        rs2_out <= 0;
        rd_out  <= 0;

        reg_write_out <= 0;
        alu_src_out   <= 0;
        mem_read_out  <= 0;
        mem_write_out <= 0;
        mem_to_reg_out<= 0;
        branch_out    <= 0;
        jump_out      <= 0;
        alu_op_out    <= 2'b00;
        funct3_out <= 3'b000;
        funct7_out <= 7'b0000000;

    end

    //----------------------------------------------------------
    // Pipeline Register Update
    //----------------------------------------------------------

    else if (write_enable) begin

        pc_out          <= pc_in;
        read_data1_out  <= read_data1_in;
        read_data2_out  <= read_data2_in;
        immediate_out   <= immediate_in;

        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out  <= rd_in;

        reg_write_out <= reg_write_in;
        alu_src_out   <= alu_src_in;
        mem_read_out  <= mem_read_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out<= mem_to_reg_in;
        branch_out    <= branch_in;
        jump_out      <= jump_in;
        alu_op_out    <= alu_op_in;
        funct3_out <= funct3_in;
        funct7_out <= funct7_in;

    end
    $display("T=%0t reset=%b flush=%b write_enable=%b rd_in=%0d rd_out=%0d",
             $time, reset, flush, write_enable, rd_in, rd_out);

end

endmodule