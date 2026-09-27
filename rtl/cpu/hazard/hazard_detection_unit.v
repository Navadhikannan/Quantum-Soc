module hazard_detection_unit(

   
    // Inputs
   

    input wire        ex_mem_read,

    input wire [4:0]  ex_rd,

    input wire [4:0]  id_rs1,
    input wire [4:0]  id_rs2,

   
    // Outputs
   

    output reg pc_write,
    output reg if_id_write,
    output reg control_mux

);

    
    // Hazard Detection Logic
  

    always @(*) begin

       
        // Default Operation (No Hazard)
       

        pc_write    = 1'b1;
        if_id_write = 1'b1;
        control_mux = 1'b0;

        
        // Load-Use Hazard Detection
       

        if ( ex_mem_read &&
            (ex_rd != 5'd0) &&
            ((ex_rd == id_rs1) || (ex_rd == id_rs2))
           )
        begin

           
            // Stall Pipeline
            

            pc_write    = 1'b0;
            if_id_write = 1'b0;
            control_mux = 1'b1;

        end

    end

endmodule