module LC3_microsequencer ( 
    input   wire                i_CLK,
    input   wire                i_Reset,
    // From Control Store:
    input   wire    [5: 0]      i_j_field,
    input   wire    [2: 0]      i_COND_bits,
    input   wire                i_IRD,
    input   wire                i_LD_BEN,
    // From Memory IO:
    input   wire                i_R_Bit, // 1 when memory is ready
    // From Data Path:
    input   wire    [15:9]      i_IR_15_9,
    input   wire    [2: 0]      i_NZP, // condition code
    //input   wire                i_ACV, // Address Control Violation not in use
    //input   wire                i_PSR_15, // not in use
    // From Interrupt Control:
    input   wire                i_INT, // the interrupt signal
    output  wire     [5: 0]      o_AddressNextState);


    // Different MUX select line values for Microsequencer 
    //parameter ACV   = 3'b110;
    //parameter INT   = 3'b101;
    //parameter PSR15 = 3'b100;
    parameter BEN   = 3'b010;
    parameter R     = 3'b001;
    parameter IR11  = 3'b011;
    // BEN determines the condition code
    wire      w_BEN = (i_IR_15_9[9] && i_NZP[0]) || // P
                      (i_IR_15_9[10] && i_NZP[1]) || // Z
                      (i_IR_15_9[11] && i_NZP[2]);   // N

    // Set up Branch Enable Register 
    reg r_BEN;
    // To prevent glitches
    always @(posedge i_CLK) begin
        r_BEN <= w_BEN;
    end
    wire w_BEN_Reg;
    assign w_BEN_Reg = r_BEN;

    // The Actual Microsequencer
    // ---------------------------------------------------------------
    assign o_AddressNextState = (i_Reset)                   ?   6'h12 :
                                (i_IRD)                     ?   {2'b00, i_IR_15_9[15:12]}: // The addr of microinstructions e.g. not 1001 addr: 6'b001001
                             // (i_COND_bits == ACV)        ?   {          i_ACV,      5'b00000}   | i_j_field:
                             // (i_COND_bits == INT)        ?   {1'b0,     i_INT,      4'b0000}    | i_j_field:
                             // (i_COND_bits == PSR15)      ?   {2'b00,    i_PSR_15,   3'b000}     | i_j_field:
                                (i_COND_bits == 3'b010)        ?   {3'b000,   w_BEN_Reg,  2'b00}  | i_j_field:  // if true, the next instruction is 22
                                (i_COND_bits == 3'b001)          ?   {4'b0000,  i_R_Bit,    1'b0}       | i_j_field:
                                (i_COND_bits == 3'b011)       ?   {5'b00000, i_IR_15_9[11]}           | i_j_field: // JSR if true, jmp to j_field + 1 or j_field
                                i_j_field;  // Default Case

endmodule