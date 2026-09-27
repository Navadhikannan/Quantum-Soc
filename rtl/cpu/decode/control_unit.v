module control_unit(

    input  wire [6:0] opcode,

    output reg reg_write,
    output reg alu_src,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch,
    output reg jump,
    output reg [1:0] alu_op

);

always @(*) begin

    //==========================================================
    // Default Values
    //==========================================================

    reg_write = 0;
    alu_src   = 0;
    mem_read  = 0;
    mem_write = 0;
    mem_to_reg= 0;
    branch    = 0;
    jump      = 0;
    alu_op    = 2'b00;

    case(opcode)

    //----------------------------------------------------------
    // R-Type
    //----------------------------------------------------------

    7'b0110011: begin

        reg_write = 1;
        alu_src   = 0;
        alu_op    = 2'b10;

    end

    //----------------------------------------------------------
    // I-Type (ADDI, ANDI...)
    //----------------------------------------------------------

    7'b0010011: begin

        reg_write = 1;
        alu_src   = 1;
        alu_op    = 2'b10;

    end

    //----------------------------------------------------------
    // LOAD
    //----------------------------------------------------------

    7'b0000011: begin

        reg_write = 1;
        alu_src   = 1;
        mem_read  = 1;
        mem_to_reg= 1;
        alu_op    = 2'b00;

    end

    //----------------------------------------------------------
    // STORE
    //----------------------------------------------------------

    7'b0100011: begin

        alu_src   = 1;
        mem_write = 1;
        alu_op    = 2'b00;

    end

    //----------------------------------------------------------
    // BRANCH
    //----------------------------------------------------------

    7'b1100011: begin

        branch = 1;
        alu_op = 2'b01;

    end

    //----------------------------------------------------------
    // JAL / JALR
    //----------------------------------------------------------

    7'b1101111,
    7'b1100111: begin

        reg_write = 1;
        jump      = 1;

    end

    //----------------------------------------------------------
    // LUI / AUIPC
    //----------------------------------------------------------

    7'b0110111,
    7'b0010111: begin

        reg_write = 1;
        alu_src   = 1;

    end

    default: begin

        // Default signals already assigned

    end

    endcase

end

endmodule