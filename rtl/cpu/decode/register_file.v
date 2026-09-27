module register_file #(
    parameter XLEN = 32,
    parameter REG_COUNT = 32
)(
    input wire clk,
    input wire reset,

    // Read Ports
    input wire [4:0] rs1,
    input wire [4:0] rs2,

    output wire [XLEN-1:0] read_data1,
    output wire [XLEN-1:0] read_data2,

    // Write Port
    input wire reg_write,
    input wire [4:0] rd,
    input wire [XLEN-1:0] write_data
);

   
    // Register File Memory
   

    reg [XLEN-1:0] registers [0:REG_COUNT-1];

    integer i;

   
    // Reset and Write Logic
  

    always @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < REG_COUNT; i = i + 1)
                registers[i] <= 0;

        end

        else if (reg_write && (rd != 5'd0)) begin

            registers[rd] <= write_data;

        end

    end

    
    // Read Logic (Combinational)
   
    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];

    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

endmodule