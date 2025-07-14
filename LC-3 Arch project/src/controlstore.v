//Control store controls all signals

module control_store #( 
    parameter       INIT_FILE   = "../ControlSignals/output.txt", 
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
    reg [ElementSize-1: 0] memory [NumElements];

    //------------------------------------------------------------------------------
    // Read/Write Operations
    //------------------------------------------------------------------------------
    always @(*) begin
        o_read_data = (i_read_en) ? memory[i_read_addr] : {ElementSize{1'b0}};
    end

    //------------------------------------------------------------------------------
    // Memory Initialization
    // Note: This is a rare case where initial blocks work in synthesizable Verilog.
    //------------------------------------------------------------------------------
    parameter INIT_FILE = "controlstore.mem"
    initial if (INIT_FILE) begin
        $readmemb(INIT_FILE, memory);
    end

endmodule