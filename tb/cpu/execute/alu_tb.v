`timescale 1ns/1ps

module alu_tb;

    // Inputs
    reg [31:0] operand_a;
    reg [31:0] operand_b;
    reg [3:0]  alu_control;

    // Outputs
    wire [31:0] result;
    wire zero;

    // DUT Instantiation
    alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial begin

        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        $display("==========================================");
        $display("        ALU TEST STARTED");
        $display("==========================================");

        // ADD
        operand_a = 32'd20;
        operand_b = 32'd10;
        alu_control = 4'b0000;
        #10;

        // SUB
        operand_a = 32'd20;
        operand_b = 32'd10;
        alu_control = 4'b0001;
        #10;

        // AND
        operand_a = 32'hF0F0F0F0;
        operand_b = 32'h0F0F0F0F;
        alu_control = 4'b0010;
        #10;

        // OR
        operand_a = 32'hF0F0F0F0;
        operand_b = 32'h0F0F0F0F;
        alu_control = 4'b0011;
        #10;

        // XOR
        operand_a = 32'hAAAA5555;
        operand_b = 32'h5555AAAA;
        alu_control = 4'b0100;
        #10;

        // SLL
        operand_a = 32'd8;
        operand_b = 32'd2;
        alu_control = 4'b0101;
        #10;

        // SRL
        operand_a = 32'd32;
        operand_b = 32'd2;
        alu_control = 4'b0110;
        #10;

        // SRA
        operand_a = -32'd16;
        operand_b = 32'd2;
        alu_control = 4'b0111;
        #10;

        // SLT (True)
        operand_a = -32'd5;
        operand_b = 32'd10;
        alu_control = 4'b1000;
        #10;

        // SLT (False)
        operand_a = 32'd20;
        operand_b = 32'd10;
        alu_control = 4'b1000;
        #10;

        // SLTU (True)
        operand_a = 32'd5;
        operand_b = 32'd10;
        alu_control = 4'b1001;
        #10;

        // SLTU (False)
        operand_a = 32'd15;
        operand_b = 32'd10;
        alu_control = 4'b1001;
        #10;

        // Zero Flag Test
        operand_a = 32'd25;
        operand_b = 32'd25;
        alu_control = 4'b0001;   // 25 - 25 = 0
        #10;

        $display("==========================================");
        $display("        ALU TEST COMPLETED");
        $display("==========================================");

        $finish;
    end

    initial begin
        $monitor("Time=%0t | ALUCtrl=%b | A=%0d | B=%0d | Result=%0d | Zero=%b",
                  $time, alu_control, operand_a, operand_b, result, zero);
    end

endmodule