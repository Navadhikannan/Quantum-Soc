`timescale 1ns/1ps

module immediate_generator #(
    parameter XLEN = 32
)(
    input  wire [31:0] instruction,

    output reg [XLEN-1:0] immediate
);

    //==========================================================
    // Opcode Extraction
    //==========================================================

    wire [6:0] opcode;

    assign opcode = instruction[6:0];

    //==========================================================
    // Immediate Generation
    //==========================================================

    always @(*) begin

        case(opcode)

        //------------------------------------------------------
        // I-Type
        //------------------------------------------------------

        7'b0010011,   // ADDI
        7'b0000011,   // LOAD
        7'b1100111:   // JALR
        begin
            immediate = {{20{instruction[31]}},
                         instruction[31:20]};
        end

        //------------------------------------------------------
        // S-Type
        //------------------------------------------------------

        7'b0100011:
        begin
            immediate = {{20{instruction[31]}},
                         instruction[31:25],
                         instruction[11:7]};
        end

        //------------------------------------------------------
        // B-Type
        //------------------------------------------------------

        7'b1100011:
        begin
            immediate = {{19{instruction[31]}},
                         instruction[31],
                         instruction[7],
                         instruction[30:25],
                         instruction[11:8],
                         1'b0};
        end

        //------------------------------------------------------
        // U-Type
        //------------------------------------------------------

        7'b0110111,   // LUI
        7'b0010111:   // AUIPC
        begin
            immediate = {instruction[31:12],
                         12'b0};
        end

        //------------------------------------------------------
        // J-Type
        //------------------------------------------------------

        7'b1101111:
        begin
            immediate = {{11{instruction[31]}},
                         instruction[31],
                         instruction[19:12],
                         instruction[20],
                         instruction[30:21],
                         1'b0};
        end

        //------------------------------------------------------
        // Default
        //------------------------------------------------------

        default:
            immediate = 32'd0;

        endcase

    end

endmodule