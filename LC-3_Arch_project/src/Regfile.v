`timescale 1ns/1ps
module LC3_regfile(
    input wire [2:0] DR,
    input wire [2:0] SR1,
    input wire [2:0] SR2,
    input wire rst,
    input wire clk,
    input wire we,
    input wire [3:0] DIS_sw,
    input wire [15:0] d,
    output reg [15:0] SR1_out,
    output reg [15:0] SR2_out,
    output reg [15:0] DIS_reg
);

    parameter RLEN = 8;
    reg [15:0] R [0:RLEN-1];

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<RLEN; i=i+1) R[i] <= 16'b0;
        end
        else if (we) begin
            R[DR] <= d;
        end
    end

    always @(*) begin
        SR1_out = (we && DR==SR1) ? d : R[SR1]; 
        SR2_out = (we && DR==SR2) ? d : R[SR2];
        DIS_reg = R[DIS_sw[2:0]];  // 显示选择
    end

endmodule

