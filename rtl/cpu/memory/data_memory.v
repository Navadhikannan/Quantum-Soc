module data_memory #(parameter XLEN = 32,
                     parameter MEM_DEPTH = 256)
(
    input                   clk,
    input                   mem_read,
    input                   mem_write,
    input  [XLEN-1:0]       address,
    input  [XLEN-1:0]       write_data,

    output reg [XLEN-1:0]   read_data
);

    // 256 x 32-bit memory
    reg [XLEN-1:0] memory [0:MEM_DEPTH-1];

    integer i;

    // Initialize memory
    initial begin
        for(i = 0; i < MEM_DEPTH; i = i + 1)
            memory[i] = 32'd0;
    end

    //--------------------------------------------------
    // Write Operation (SW)
    //--------------------------------------------------
    always @(posedge clk)
    begin
        if(mem_write)
            memory[address[9:2]] <= write_data;
    end

    //--------------------------------------------------
    // Read Operation (LW)
    //--------------------------------------------------
    always @(*)
    begin
        if(mem_read)
            read_data = memory[address[9:2]];
        else
            read_data = 32'd0;
    end

endmodule