`timescale 1ns/1ps
// encapsulates MAR MDR and RAM
module LC3_Memory_wrapper(
    input wire i_CLK, 
    input wire [3:0] i_LED_dis,
    // Control Signals
    input wire          i_LD_MDR,
    input wire          i_LD_MAR,
    input wire          i_RW,
    input wire          i_MIO_EN,

    // From Data Path: 
    input wire  [15:0]  i_Bus,

    // Output 
    output wire [15:0]  o_Bus,
    output wire         o_Ready_Bit
);

// Output of Memory wire
wire [15:0] w_Memory_Out;

// MDR and MAR Registers
// ---------------------------
reg [15:0] r_MDR;
reg [15:0] r_MAR;
wire [15:0] w_Feed_MDR;
assign o_Bus = r_MDR; // Output MDR onto CPU bus (gated by top mod)

always @(posedge i_CLK) begin
    if(i_LD_MDR)
        r_MDR <= w_Feed_MDR;
    if(i_LD_MAR)
        r_MAR <= i_Bus;
end
// ---------------------------
// Bus or Memory Mux (to MDR)

assign w_Feed_MDR = (i_MIO_EN) ? w_Memory_Out : i_Bus;


// Address Control Logic
// Uses MIO and RW to know when to read / write what
// ------------------------------------
wire w_Write = (i_MIO_EN && i_RW) ? 1'b1 : 1'b0;
wire w_Read = (i_MIO_EN && ~i_RW) ? 1'b1 : 1'b0;

//inst


LC3_mem u_LC3_mem(
    .clk       	(i_CLK       ),
    .we        	(w_Write),
    .re        	(w_Read),
    .w_raddr   	(r_MAR[6:0]),
    .w_waddr   	(r_MAR[6:0]),
    .d         	(r_MDR),
    .d_out     	(w_Memory_Out),
    .ready_bit 	(o_Ready_Bit)
);




endmodule