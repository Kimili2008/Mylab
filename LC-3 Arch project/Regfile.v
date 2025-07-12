module LC3_regfile(
    input [2:0] DR,
    input [2:0] SR1,
    input [2:0] SR2,
    input rst,
    input clk,
    input we,
    input [3:0] DIS_sw,
    input [15:0] d,
    output reg [15:0] SR1_out,
    output reg [15:0] SR2_out,
    output reg [15:0] DIS_reg //the register being displayed
);

//assign    DR = IR[11:9];
//assign    SR1 = IR[8:6];
//assign    SR2 = IR[2:0];
parameter RLEN = 8;
reg[15:0]  R[7:0]; // Reg file
always @(posedge clk) begin
    if (we) R[DR] <= d;
end
always @(*) begin
    SR1_out <= R[SR1];
    SR2_out <= R[SR2];
end


// LED logic the first 0-2 bits of DIS_sw belongs to the 8 regs
always @(*) begin
    DIS_reg <= R[DIS_SW[2:0]]
end
//
integer i;
always @(posedge rst) begin
    for (i=0; i< RLEN;i = i + 1)
        R[i] <= 16'b0;
end

endmodule

