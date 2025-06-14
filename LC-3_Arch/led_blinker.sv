// Led_blinker
`timescale 1ns/1ps //25KHZ clk
module Led_blinker (
    input wire enable,
    input wire sel0,
    input wire sel1,
    input wire clk,
    output wire Led_blinker_output
);
    parameter HZ100 = 125;
    parameter HZ50 = 250;
    parameter HZ10 = 1250;
    parameter HZ1 = 12500;
//counter 
    reg [31:0] c_100 = 0;
    reg [31:0] c_50 = 0;
    reg [31:0] c_10 = 0;
    reg [31:0] c_1 = 0;

//toggle
    reg  toggle100=1'b1;
    reg  toggle50=1'b1;
    reg  toggle10=1'b1;
    reg  toggle1=1'b1;
//select
    wire output1;
begin
    always @ (posedge clk)
    begin
        if (c_100==HZ100-1)
        begin
            c_100 <= 0;
            toggle100 <= !toggle100;
        end
        else 
            c_100 <= c_100+1;
    end

    always @ (posedge clk)
    begin
        if (c_50==HZ50-1)
        begin
            c_50 <= 0;
            toggle50 <= !toggle50;
        end
        else 
            c_50 <= c_50+1;
    end

    always @ (posedge clk)
    begin
        if (c_10==HZ10-1)
        begin
            c_10 <= 0;
            toggle10 <= !toggle10;
        end
        else 
            c_10 <= c_10+1;
    end

    always @ (posedge clk)
    begin
        if (c_1==HZ1-1)
        begin
            c_1 <= 0;
            toggle1 <= !toggle1;
        end
        else 
            c_1 <= c_1+1;
    end
    wire output1;
    always @(*) begin
        if (sel0==0 && sel1==0)      output1 = toggle1;
        else if (sel0==0 && sel1==1) output1 = toggle10;
        else if (sel0==1 && sel1==0) output1 = toggle50;
        else                         output1 = toggle100;
    end
        
        assign Led_blinker_output = output1 & enable;


        //Alternative way to design a multiplexer
        //assign output1 = sel1 ? (sel2? toggle100 : toggle50) : (sel2? toggle10 : toggle1);
        //assign Led_blinker_output = output1 & enable
end
endmodule
///testbench
`include "Led_blinker.v"
`timescale 1us/1ps
module Led_blinker_tb;
    reg tb_clk = 1'b1;
    reg tb_enable = 1'b1;
    reg tb_sel1 = 1'b1;
    reg tb_sel0 = 1'b1;
    wire tb_output; //wire没有初始值
    Led_blinker UUT ( //unit under test
        .clk(tb_clk),
        .enable(tb_enable),
        .sel0(tb_sel0),
        .sel1(tb_sel1),
        .Led_blinker_output(tb_output)
    );
    initial begin
        $dumpfile("Led_tb.vcd");
        $dumpvars(0,Led_tb);
    end


    always #20 tb_clk = !tb_clk; //T=40us



    initial begin //only executed once
        tb_enable=0;
        #400*40; //check enable
        tb_enable=1;
        #400*40;//check 100HZ
        tb_sel0=1;
        tb_sel1=0;
        #500*40;//check 50HZ
        tb_sel0=0;
        tb_sel1=1;
        #2500*40;//check 10HZ
        tb_sel1=0;
        #25000*40;//check 1HZ
        $display("test complete!");
        $finish;
    end
endmodule
