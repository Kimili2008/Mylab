module LC3_nzp ( 
    input   wire                i_CLK,
    // From Control Store:
    input   wire                i_LD_CC_Control,
    // From Data Path:
    input   wire    [15:0]      i_Bus,
    // Output to Control Store
    output  wire    [2: 0]      o_NZP // Goes to BUS and Addr1Mux
    );


    // The NZP Register
    // --------------------------------------------------
    reg [2:0] r_NZP;
    assign o_NZP = r_NZP;

    always @ (posedge i_CLK) begin
        if(i_LD_CC_Control)
            r_NZP <= w_Logic;
    end
    // --------------------------------------------------


    // Condition Codes Logic 
    // --------------------------------------------------
    wire [2:0] w_Logic; // N=2, Z=1, P=0

    assign w_Logic[2] = (i_Bus[15] == 1'b1) ? 1'b1 : 1'b0;                          // N if MSB is a 1 (2's compliment)
    assign w_Logic[1] = (i_Bus == 16'h0000) ? 1'b1 : 1'b0;                          // Z if the entire value is 0
    assign w_Logic[0] = (i_Bus[15] == 1'b0 && i_Bus != 16'b0000) ? 1'b1: 1'b0;      // P if MSB is a 0 (2's compliment)
    // ----------------------------------------------------

endmodule