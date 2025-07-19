`timescale 1ns/1ps
module LC3_regfile(
    input wire [2:0] DR,
    input wire [2:0] SR1,
    input wire [2:0] SR2,
    input wire rst,
    input wire clk,
    input wire we,
    input   wire    [1:0]       i_SR1MUX,   // Mux select for SR1
    input   wire    [1:0]       i_DRMUX,    // Mux select for DR
    input wire [3:0] DIS_sw,
    input wire [15:0] d,
    output reg [15:0] SR1_out,
    output reg [15:0] SR2_out,
    output reg [15:0] DIS_reg
);

    parameter RLEN = 8;
    reg [15:0] R [0:RLEN-1];


    // SR1 Mux
    // Note: Determines register for SR1 output of Register File
    reg    [2:0]   w_SR1MUX_Out;
    always @(*) begin   // @ any "input" change, update value
        case(i_SR1MUX)
            2'b00: w_SR1MUX_Out = DR;    // Bits [11:9] of IR, represents DR address
            2'b01: w_SR1MUX_Out = SR1;     // Bits [8:6] of IR, represents SR1 address
            2'b10: w_SR1MUX_Out = 3'b110;       // R6
            default: w_SR1MUX_Out = 3'b000;     // Defaults to 0
        endcase
    end



  // DR Mux
    // Note: Determines which register is the destination register in register file 
    reg    [2:0]   w_DRMUX_Out;
    always @(*) begin // @ any "input" change, update value
        case(i_DRMUX)
            2'b00: w_DRMUX_Out = DR; /* 3'b001*/    // Bits [11:9] of IR, represents DR address
            2'b01: w_DRMUX_Out = 3'b111;       // R7 
            2'b10: w_DRMUX_Out = 3'b110;       // R6
            default: w_DRMUX_Out = 3'b000;      // Defaults to 0
        endcase
    end



    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<RLEN; i=i+1) R[i] <= 16'b0;
        end
        else if (we) begin
            R[w_DRMUX_Out] <= d;
        end
    end

    always @(*) begin
        SR1_out = R[w_SR1MUX_Out]; 
        SR2_out = R[SR2];
        DIS_reg = R[DIS_sw[2:0]];  // 显示选择
    end

endmodule

