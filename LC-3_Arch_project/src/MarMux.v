`timescale 1ns/1ps
//combinational
module LC3_MarMux(
    input wire i_Marmux_Control,
    input wire [15:0] i_offset_addr,
    input wire [7:0] i_IR_7_0,
    output wire [15:0] o_MarMux_out
);
wire [15:0] i_IR_7_0_sext;
assign i_IR_7_0_sext = (i_IR_7_0[7])? {8'b11111111,i_IR_7_0} : {8'b00000000,i_IR_7_0};
parameter immediate = 1'b0;
parameter addr = 1'b1;
assign o_MarMux_out = (i_Marmux_Control == 1'b0)? i_IR_7_0_sext : i_offset_addr;

endmodule //LC3_MarMux
