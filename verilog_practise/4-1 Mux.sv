`timescale 1ps/1ps
module Mux_41(
    input wire[3:0] data,
    input wire [1:0] sel,
    output wire s_data
);
//assign s_data = (sel[0]&sel[1]&data[0])+(~sel[0]&sel[1]&data[1])+(sel[0]&~sel[1]&data[2])+(~sel[0]&~sel[1]&data[3]);
//此处为经典错误，未排除glitch的可能
//assign s_data = (sel=2'b00)? data[0]:
 //               (sel=2'b01)? data[1]:
 //               (sel=2'b10)? data[2]:
 //               data[3];

assign s_data = data[sel];
endmodule

`include "Mux_41.v"
`timescale 1ps/1ps
module Mux_41_tb;
    reg[3:0] tb_data;
    reg[1:0] tb_sel;
    wire tb_s_data;
Mux_41 uut(
    .data(tb_data),
    .sel(tb_sel),
    .s_data(tb_s_data)
);
initial begin
    tb_data = 4'b0001;
    tb_sel = 2'b00;
    #10;
    tb_sel = 2'b01;
    #10;
    tb_data = 4'b0010;
    #10;
end

endmodule