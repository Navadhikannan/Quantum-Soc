module mem_wb #(parameter XLEN = 32)
(
    input clk,
    input reset,

    //==============================
    // Inputs from MEM Stage
    //==============================

    input [XLEN-1:0] read_data_in,
    input [XLEN-1:0] alu_result_in,
    input [4:0] rd_in,

    input reg_write_in,
    input mem_to_reg_in,

    //==============================
    // Outputs to WB Stage
    //==============================

    output reg [XLEN-1:0] read_data_out,
    output reg [XLEN-1:0] alu_result_out,
    output reg [4:0] rd_out,

    output reg reg_write_out,
    output reg mem_to_reg_out
);

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        read_data_out <= 32'd0;
        alu_result_out <= 32'd0;
        rd_out <= 5'd0;

        reg_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
    end
    else
    begin
        read_data_out <= read_data_in;
        alu_result_out <= alu_result_in;
        rd_out <= rd_in;

        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;
    end
end

endmodule