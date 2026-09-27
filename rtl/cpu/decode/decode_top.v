module decode_top #(
    parameter XLEN = 32
)(
    
    // Clock & Reset
   
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire branch_taken,

   
    // Inputs from IF Stage
   
    input wire [XLEN-1:0] instruction,
    input wire [XLEN-1:0] pc,

   
    // Write Back Interface
   
    input wire reg_write_wb,
    input wire [4:0] rd_wb,
    input wire [XLEN-1:0] write_data_wb,

   
    // Outputs to Execute Stage
    
    output wire [XLEN-1:0] pc_out,
    output wire [XLEN-1:0] read_data1_out,
    output wire [XLEN-1:0] read_data2_out,
    output wire [XLEN-1:0] immediate_out,

    output wire [4:0] rs1_out,
    output wire [4:0] rs2_out,
    output wire [4:0] rd_out,

    output wire [2:0] funct3_out,
    output wire [6:0] funct7_out,

    output wire reg_write_out,
    output wire alu_src_out,
    output wire mem_read_out,
    output wire mem_write_out,
    output wire mem_to_reg_out,
    output wire branch_out,
    output wire jump_out,
    output wire [1:0] alu_op_out,

    input wire pc_write,
    input wire if_id_write,
    input wire control_mux
);

   
    // Internal Signals
   

    wire [6:0] opcode;

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [2:0] funct3;
    wire [6:0] funct7;

    wire [XLEN-1:0] read_data1;
    wire [XLEN-1:0] read_data2;
    wire [XLEN-1:0] immediate;

    wire reg_write;
    wire alu_src;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire branch;
    wire jump;
    wire [1:0] alu_op;

   
    // Instruction Decoder
   

    instruction_decoder decoder (

        .instruction(instruction),

        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)

    );

    
    // Register File
    

    register_file #(
        .XLEN(XLEN)
    ) regfile (

        .clk(clk),
        .reset(reset),

        .reg_write(reg_write_wb),

        .rs1(rs1),
        .rs2(rs2),

        .rd(rd_wb),
        .write_data(write_data_wb),

        .read_data1(read_data1),
        .read_data2(read_data2)

    );

   
    // Immediate Generator
   

    immediate_generator #(
        .XLEN(XLEN)
    ) imm_gen (

        .instruction(instruction),
        .immediate(immediate)

    );

   
    // Control Unit
   

    control_unit control (

        .opcode(opcode),

        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .alu_op(alu_op)

    );
    //==========================================================
// Final Control Signals (After Hazard Detection)
//==========================================================

wire reg_write_final;
wire alu_src_final;
wire mem_read_final;
wire mem_write_final;
wire mem_to_reg_final;
wire branch_final;
wire jump_final;
wire [1:0] alu_op_final;

assign reg_write_final = control_mux ? 1'b0 : reg_write;
assign alu_src_final   = control_mux ? 1'b0 : alu_src;
assign mem_read_final  = control_mux ? 1'b0 : mem_read;
assign mem_write_final = control_mux ? 1'b0 : mem_write;
assign mem_to_reg_final= control_mux ? 1'b0 : mem_to_reg;
assign branch_final    = control_mux ? 1'b0 : branch;
assign jump_final      = control_mux ? 1'b0 : jump;
assign alu_op_final    = control_mux ? 2'b00 : alu_op;
  
    
    // ID/EX Pipeline Register
   
    id_ex #(
        .XLEN(XLEN)
    ) id_ex_reg (

        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .flush(branch_taken),

        .pc_in(pc),

        .read_data1_in(read_data1),
        .read_data2_in(read_data2),

        .immediate_in(immediate),

        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),

        

        .pc_out(pc_out),
        .read_data1_out(read_data1_out),
        .read_data2_out(read_data2_out),
        .immediate_out(immediate_out),

        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .rd_out(rd_out),
     //altered
        .reg_write_out(reg_write_out),
.alu_src_out(alu_src_out),
.mem_read_out(mem_read_out),
.mem_write_out(mem_write_out),
.mem_to_reg_out(mem_to_reg_out),
.branch_out(branch_out),
.jump_out(jump_out),
.alu_op_out(alu_op_out),
.funct3_out(funct3_out),
.funct7_out(funct7_out),

        .reg_write_in(reg_write_final),
        .alu_src_in(alu_src_final),
        .mem_read_in(mem_read_final),
        .mem_write_in(mem_write_final),
        .mem_to_reg_in(mem_to_reg_final),
        .branch_in(branch_final),
        .jump_in(jump_final),
        .alu_op_in(alu_op_final),
        .funct3_in(funct3),
        .funct7_in(funct7)
        

    );

endmodule