module write_back #(parameter XLEN = 32)
(
    // Inputs from MEM/WB Pipeline Register
   

    input [XLEN-1:0] read_data,
    input [XLEN-1:0] alu_result,

    input mem_to_reg,

    
    // Output to Register File
    

    output [XLEN-1:0] write_back_data
);

// Write Back Multiplexer

assign write_back_data =
            (mem_to_reg) ? read_data : alu_result;

endmodule