module forwarding_unit(

    input [4:0] ex_rs1,
    input [4:0] ex_rs2,

    input [4:0] mem_rd,
    input mem_reg_write,

    input [4:0] wb_rd,
    input wb_reg_write,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB

);

always @(*) begin

    // Default: No forwarding
    forwardA = 2'b00;
    forwardB = 2'b00;

    // EX/MEM forwarding
    if (mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs1))
        forwardA = 2'b10;

    if (mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs2))
        forwardB = 2'b10;

    // MEM/WB forwarding
    if (wb_reg_write &&
        (wb_rd != 0) &&
        !(mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs1)) &&
        (wb_rd == ex_rs1))
        forwardA = 2'b01;

    if (wb_reg_write &&
        (wb_rd != 0) &&
        !(mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs2)) &&
        (wb_rd == ex_rs2))
        forwardB = 2'b01;

end

endmodule