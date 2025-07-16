`timescale 1ns/1ps
// This defines the adder used in relative addressing
module LC3_addermux(
    // R1-PC mux
    input wire [15:0] i_PC,
    input wire [15:0] i_SR1,
    input wire i_addr1mux,
    // IR mux
    input wire [10:0] i_IR_10_0,
    input wire [8:0] i_IR_8_0,
    input wire [5:0] i_IR_5_0,
    input wire [1:0] i_addr2mux, // 00: 0; 01: IR[5:0]; 10: IR[8:0]; 11: IR[10:0]
    // OUT
    output wire [15:0] o_addermux_out
);

// ===== （Sign EXTension） =====
wire [15:0] i_IR_10_0_sext = {{5{i_IR_10_0[10]}}, i_IR_10_0};  // 11-bit → 16-bit
wire [15:0] i_IR_8_0_sext  = {{7{i_IR_8_0[8]}},   i_IR_8_0};    // 9-bit → 16-bit
wire [15:0] i_IR_5_0_sext  = {{10{i_IR_5_0[5]}},  i_IR_5_0};    // 6-bit → 16-bit

// ===== ADDR2MUX（纯组合逻辑实现） =====
wire [15:0] addr2mux_out = 
    (i_addr2mux == 2'b00) ? 16'h0000 :          // 00: 0
    (i_addr2mux == 2'b01) ? i_IR_5_0_sext :     // 01: IR[5:0] 符号扩展
    (i_addr2mux == 2'b10) ? i_IR_8_0_sext :     // 10: IR[8:0] 符号扩展
    i_IR_10_0_sext;                             // 11: IR[10:0] 符号扩展

// ===== ADDR1MUX =====
wire [15:0] addr1mux_out = (i_addr1mux) ? i_SR1 : i_PC;  // 0: PC; 1: SR1

// ===== 加法器 =====
assign o_addermux_out = addr1mux_out + addr2mux_out;

endmodule