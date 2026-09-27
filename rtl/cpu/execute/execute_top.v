module execute_top #(parameter XLEN = 32)(

    input clk,
    input reset,

    //==================================================
    // Inputs from ID/EX Pipeline Register
    //==================================================

    input [XLEN-1:0] pc,
    input [XLEN-1:0] read_data1,
    input [XLEN-1:0] read_data2,
    input [XLEN-1:0] immediate,

    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,

// Forwarding Control
input [1:0] forwardA,
input [1:0] forwardB,

// Forwarding Data
    input [31:0] ex_mem_data,
    input [31:0] mem_wb_data,

    input [2:0] funct3,
    input [6:0] funct7,

    // Control Signals
    input reg_write,
    input alu_src,
    input mem_read,
    input mem_write,
    input mem_to_reg,
    input branch,
    input jump,
    input [1:0] alu_op,

    //==================================================
    // Outputs from EX/MEM
    //==================================================

    output [31:0] alu_result,

    // Existing outputs (to EX/MEM)
output [31:0] branch_target,
output branch_taken,

// New outputs (directly to IF)
output [31:0] branch_target_if,
output branch_taken_if,

output [31:0] rs2_data,
output [4:0] rd_out,

    output reg_write_out,
    output mem_read_out,
    output mem_write_out,
    output mem_to_reg_out,
    output branch_out,
    output jump_taken_if,
    output [31:0] jump_target_if

);

//////////////////////////////////////////////////////////
// Internal Signals
//////////////////////////////////////////////////////////

wire [3:0] alu_ctrl;

wire [31:0] operand_a_forward;
wire [31:0] operand_b_forward;
wire [31:0] operand_b;

wire [31:0] alu_result_wire;
wire zero;

wire branch_taken_wire;
wire [31:0] branch_target_wire;

// Signals going into EX/MEM
wire [31:0] ex_branch_target;
wire ex_branch_taken;

//////////////////////////////////////////////////////////
// ALU Operand MUX
//////////////////////////////////////////////////////////

// Forward Operand A
assign operand_a_forward =
        (forwardA == 2'b00) ? read_data1 :
        (forwardA == 2'b10) ? ex_mem_data :
        (forwardA == 2'b01) ? mem_wb_data :
                              read_data1;

// Forward Operand B
assign operand_b_forward =
        (forwardB == 2'b00) ? read_data2 :
        (forwardB == 2'b10) ? ex_mem_data :
        (forwardB == 2'b01) ? mem_wb_data :
                              read_data2;
assign operand_b = (alu_src) ? immediate : operand_b_forward;                       

//////////////////////////////////////////////////////////
// Branch Gating
//////////////////////////////////////////////////////////

assign ex_branch_target = branch ? branch_target_wire : 32'd0;
assign ex_branch_taken  = branch & branch_taken_wire;

assign branch_target_if = ex_branch_target;
assign branch_taken_if  = ex_branch_taken;

// Jump handling
assign jump_taken_if  = jump;
assign jump_target_if = branch_target_wire;

//////////////////////////////////////////////////////////
// ALU Control
//////////////////////////////////////////////////////////

alu_control ALU_CONTROL(

    .ALUOp(alu_op),
    .funct3(funct3),
    .funct7(funct7),
    .alu_control(alu_ctrl)

);

//////////////////////////////////////////////////////////
// ALU
//////////////////////////////////////////////////////////

alu ALU(

    .operand_a(operand_a_forward),
    .operand_b(operand_b),
    .alu_control(alu_ctrl),

    .result(alu_result_wire),
    .zero(zero)

);

//////////////////////////////////////////////////////////
// Branch Comparator
//////////////////////////////////////////////////////////

branch_comparator BC(

    .rs1_data(operand_a_forward),
    .rs2_data(operand_b_forward),
    .funct3(funct3),

    .branch_taken(branch_taken_wire)

);

//////////////////////////////////////////////////////////
// Branch Target Generator
//////////////////////////////////////////////////////////

branch_target_generator BTG(

    .pc(pc),
    .immediate(immediate),

    .branch_target(branch_target_wire)

);

//////////////////////////////////////////////////////////
// EX/MEM Pipeline Register
//////////////////////////////////////////////////////////

ex_mem EX_MEM(

    .clk(clk),
    .reset(reset),

    .alu_result_in(alu_result_wire),
    .branch_target_in(ex_branch_target),
    .rs2_data_in(operand_b_forward),
    .rd_in(rd),

    .branch_taken_in(ex_branch_taken),

    .reg_write_in(reg_write),
    .mem_read_in(mem_read),
    .mem_write_in(mem_write),
    .mem_to_reg_in(mem_to_reg),
    .branch_in(branch),

    .alu_result_out(alu_result),
    .branch_target_out(branch_target),
    .rs2_data_out(rs2_data),
    .rd_out(rd_out),

    .branch_taken_out(branch_taken),

    .reg_write_out(reg_write_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .branch_out(branch_out)

);

endmodule