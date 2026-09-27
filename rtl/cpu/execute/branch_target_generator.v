module branch_target_generator(

    input  [31:0] pc,
    input  [31:0] immediate,

    output [31:0] branch_target

);

assign branch_target = pc + immediate;

endmodule