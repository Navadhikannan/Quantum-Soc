module branch_unit (
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,

    input  wire        branch,
    input  wire        branch_ne,

    output wire        branch_taken
);

assign branch_taken =
        (branch    && (rs1_data == rs2_data)) ||
        (branch_ne && (rs1_data != rs2_data));

endmodule