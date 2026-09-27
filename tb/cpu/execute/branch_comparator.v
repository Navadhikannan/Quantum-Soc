module branch_comparator(

    input  [31:0] rs1_data,
    input  [31:0] rs2_data,
    input  [2:0]  funct3,

    output reg branch_taken

);

always @(*) begin

    case(funct3)

        3'b000:    // BEQ
            branch_taken = (rs1_data == rs2_data);

        3'b001:    // BNE
            branch_taken = (rs1_data != rs2_data);

        3'b100:    // BLT
            branch_taken = ($signed(rs1_data) < $signed(rs2_data));

        3'b101:    // BGE
            branch_taken = ($signed(rs1_data) >= $signed(rs2_data));

        3'b110:    // BLTU
            branch_taken = (rs1_data < rs2_data);

        3'b111:    // BGEU
            branch_taken = (rs1_data >= rs2_data);

        default:
            branch_taken = 1'b0;

    endcase

end

endmodule