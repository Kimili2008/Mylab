// Hello world! Kimi 2025/6/11
module Helloworld
    initial begin //only be executed once
        $display ("Hello World from Shanghai");
        #10 $finish;
    end
endmodule
//Counter Design
module Upcounter(
    input wire reset, //default wire
    input wire enable,
    input wire clk,
    output reg [3:0] counter_out
)
    always @(posedge clk) 
    begin:Counter
        if (reset == 1'b1) begin
            counter_out <= #1 4'b0000;
        end
        else if (enable == 1'b1) begin
            counter_out <= #1 counter_out+1;
        end 
    end
endmodule
//testbench Design
`timescale 1ns/1ps
`include "upcounter.v"
module tb_;
reg clk;
reg reset;
reg enable;
wire [3:0] counter_out;
//instantiation
Upcounter uut(
    .reset (reset),
    .clk (clk),
    .enable(enable),
    .counter_out(counter_out)
);
//generate the clock pulses
localparam CLK_PERIOD = 10;//local constant 1 unit time is 10 nanosecs
always #(CLK_PERIOD/2) clk=~clk;
//
initial begin
    $dumpfile("tb_.vcd");
    $dumpvars(0, tb_);
end

initial begin
    #1 reset<=1'bx;clk<=1'bx;enable<=1'bx;
    #(CLK_PERIOD*3) reset<=1; //check reset
    #(CLK_PERIOD*1) reset<=1;clk<=0;//check clk
    #(CLK_PERIOD*5) reset<=0;clk<=0;enable<=1; //check clk
    #(CLK_PERIOD*3) reset<=0; //check clk
    repeat(5) @(posedge clk); 
    reset<=1; //check clk
    repeat(2) @(posedge clk);
    enable<=0; //check enable
    repeat(2) @(posedge clk);
    $finish(2);
end

endmodule
`default_nettype wire
//////////////////////////


