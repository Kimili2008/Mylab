`timescale 1ns/1ps
module voter_7(
    input [6:0] votes,
    input wire clk,
    output wire voter_7_output
);
reg sum =0 ;
integer i;
assign voter_7_output = (sum >= 3'd4)? 1:0;
always @(posedge clk) 
begin
    for(i=0;i<7;i=i+1)
    begin
        sum = sum + votes[i];
    end

end

endmodule

`include "voter_7.v"
`default_nettype wire
`timescale 1ns/1ps
module tb_voter_7;
reg tb_clk = 1'b0;
reg [6:0] tb_votes = 7'd0;
wire tb_voter_7_output;
voter_7 UUT
(
    .votes (tb_votes),
    .clk (tb_clk),
    .voter_7_output(tb_voter_7_output)
);


integer i;
initial begin
    $dumpfile("tb_voter_7.vcd");
    $dumpvars(0, tb_voter_7);
end
localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) tb_clk=~tb_clk;
initial begin
    //for(i=0;i<7;i=i+1)
    //begin
      //  tb_votes = tb_votes + 1;
        //#20;
    //end
    tb_votes = 7'b0000111;
    #20;
    tb_votes = 7'b1111111;
    #20;
    $finish(2);
end

endmodule
`default_nettype wire   