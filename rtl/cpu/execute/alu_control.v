module alu_control (

    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,

    output reg [3:0] alu_control

);

always @(*) begin

    case(ALUOp)

        // Load / Store
        2'b00:
            alu_control = 4'b0000;      // ADD

        // Branch
        2'b01:
            alu_control = 4'b0001;      // SUB

        // R-type / I-type Arithmetic
        2'b10:
        begin

            case(funct3)

                3'b000:
        begin
            case(funct7)
                7'b0000000:
                    alu_control = 4'b0000;      // ADD / ADDI

                7'b0100000:
                    alu_control = 4'b0001;      // SUB

        default:
            alu_control = 4'b0000;      // Default to ADD

    endcase
end

                3'b111:
                    alu_control = 4'b0010;          // AND

                3'b110:
                    alu_control = 4'b0011;          // OR

                3'b100:
                    alu_control = 4'b0100;          // XOR

                3'b001:
                    alu_control = 4'b0101;          // SLL

                3'b101:
        begin
            case(funct7)

                7'b0000000:
                    alu_control = 4'b0110;      // SRL / SRLI

                7'b0100000:
                     alu_control = 4'b0111;      // SRA / SRAI

        default:
            alu_control = 4'b0110;

             endcase
        end

                3'b010:
                    alu_control = 4'b1000;          // SLT

                3'b011:
                    alu_control = 4'b1001;          // SLTU

                default:
                    alu_control = 4'b0000;

            endcase

        end

        default:
            alu_control = 4'b0000;

    endcase

end

endmodule