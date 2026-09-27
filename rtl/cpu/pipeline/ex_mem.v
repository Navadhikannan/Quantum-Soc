module ex_mem(

    input clk,
    input reset,

    // Data Signals
    input [31:0] alu_result_in,
    input [31:0] branch_target_in,
    input [31:0] rs2_data_in,
    input [4:0] rd_in,

    // Status Signal
    input branch_taken_in,

    // Control Signals
    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input branch_in,

    // Outputs
    output reg [31:0] alu_result_out,
    output reg [31:0] branch_target_out,
    output reg [31:0] rs2_data_out,
    output reg [4:0] rd_out,

    output reg branch_taken_out,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg branch_out

);

always @(posedge clk or posedge reset)

begin

    if(reset)

    begin

        alu_result_out    <= 32'd0;
        branch_target_out <= 32'd0;
        rs2_data_out      <= 32'd0;
        rd_out            <= 5'd0;

        branch_taken_out  <= 1'b0;

        reg_write_out     <= 1'b0;
        mem_read_out      <= 1'b0;
        mem_write_out     <= 1'b0;
        mem_to_reg_out    <= 1'b0;
        branch_out        <= 1'b0;

    end

    else

    begin

        alu_result_out    <= alu_result_in;
        branch_target_out <= branch_target_in;
        rs2_data_out      <= rs2_data_in;
        rd_out            <= rd_in;

        branch_taken_out  <= branch_taken_in;

        reg_write_out     <= reg_write_in;
        mem_read_out      <= mem_read_in;
        mem_write_out     <= mem_write_in;
        mem_to_reg_out    <= mem_to_reg_in;
        branch_out        <= branch_in;

    end

end

endmodule