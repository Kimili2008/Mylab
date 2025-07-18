module control_store #( 
    parameter       AddrBusSize = 6,
    parameter       NumElements = 64,
    parameter       ElementSize = 52)(   
    input   wire                            i_CLK,
    input   wire                            i_read_en,
    input   wire    [AddrBusSize-1: 0]      i_read_addr,
    output  reg     [ElementSize-1: 0]      o_read_data);

    //------------------------------------------------------------------------------
    // Memory Declaration
    //------------------------------------------------------------------------------
    reg [51: 0] memory [63:0];

    //------------------------------------------------------------------------------
    // Read/Write Operations
    //------------------------------------------------------------------------------
    always @(posedge i_CLK) begin
        o_read_data = (i_read_en) ? memory[i_read_addr] : {ElementSize{1'b0}};
    end

    //------------------------------------------------------------------------------
    // Memory Initialization
    // Note: This is a rare case where initial blocks work in synthesizable Verilog.
    //------------------------------------------------------------------------------
    localparam INIT_FILE_2 = "controlstore.mem";
    initial if (INIT_FILE_2) begin
        $readmemb(INIT_FILE_2, memory);
    end

endmodule