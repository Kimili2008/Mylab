`timescale 1ns/1ps
// This module encapsulates control store and microsequencer.//
// The microinstructions are stored in controlstore and microsequencer determines the main counter.//
// Control logic wraps up all control signals and sends out to other modules//
module LC3_control_logic(
    input i_clk,
    //from the processor
    input   wire    [15:0]                  i_IR,
    input   wire                            i_Ready_Bit, 
    input   wire    [2:0]                   i_NZP,
    input   wire                            i_Reset,

    output  wire    o_LD_MAR, 
    output  wire    o_LD_MDR, 
    output  wire    o_LD_IR,    
    output  wire    o_LD_REG,       // This is reg file
    output  wire    o_LD_CC,        // I called this NZP reg
    output  wire    o_LD_PC,        
    //output  wire    o_LD_Priv,          // Not in use yet
    //output  wire    o_LD_SavedSSP,      // Not in use yet
    //output  wire    o_LD_SavedUSP,      // Not in use yet
    //output  wire    o_LD_Vector,        // Not in use yet    
    //output  wire    o_LD_Priority,      // Not in use yet 
    //output  wire    o_LD_ACV,           // Not in use yet     

    // Control What data goes onto CPU Bus 
    output  wire    o_GatePC, 
    output  wire    o_GateMDR, 
    output  wire    o_GateALU, 
    output  wire    o_GateMarMux, 
    //output  wire    o_GateVector,       // Not in use yet 
    //output  wire    o_GatePC_minus1,    // Not in use yet 
    //output  wire    o_GateSRP,          // Not in use yet 
    //output  wire    o_GateSP,           // Not in use yet 

    // Mux Control Signals
    output  wire    [1:0]   o_PCMUX, 
    output  wire    [1:0]   o_DRMUX, 
    output  wire    [1:0]   o_SR1MUX, 
    output  wire    [0:0]   o_ADDR1MUX, 
    output  wire    [1:0]   o_ADDR2MUX, 
    //output  wire    [1:0]   o_SPMUX,    // Not in use yet
    output  wire    [0:0]   o_MARMUX, 
    //output  wire    [0:0]   o_TableMUX, // Not in use yet
    //output  wire    [1:0]   o_VectorMUX,// Not in use yet 
    //output  wire    [0:0]   o_PSRMUX,   // Not in use yet 

    // ALU Control 
    output  wire    [1:0]   o_ALUK, 

    // Memory Control 
    output  wire    o_MIO_EN, 
    output  wire    o_R_W
);
    // Privilege Control

//output  wire    o_Set_Priv          // Not in use yet

wire [51:0] w_current_state;
wire [5:0] w_next_addr;
// output declaration of module LC3_microsequencer
wire            w_IRD       = w_current_state[51];
wire    [2:0]   w_COND      = w_current_state[50:48];
wire    [5:0]   w_J_Field   = w_current_state[47:42];
wire   w_LD_BEN        = w_current_state[38];   // BEN is internal to this module
LC3_microsequencer u_LC3_microsequencer(
    .i_CLK              	(i_clk               ),
    .i_Reset            	(i_Reset             ),
    .i_j_field          	(w_J_Field),
    .i_COND_bits        	(w_COND),
    .i_IRD              	(w_IRD               ),
    .i_LD_BEN           	(w_LD_BEN),
    .i_R_Bit            	(i_Ready_Bit         ),
    .i_IR_15_9          	(i_IR[15:9]          ),
    .i_NZP              	(i_NZP               ),
    //.i_ACV              	(i_ACV               ),
    .o_AddressNextState 	(w_next_addr  )
);

// output declaration of module control_store

control_store #(
    .AddrBusSize 	(6                               ),
    .NumElements 	(64                              ),
    .ElementSize 	(52                              ))
u_control_store(
    .i_CLK       	(i_clk        ),
    .i_read_en   	(1'b1    ),
    .i_read_addr 	(w_next_addr  ),
    .o_read_data 	(w_current_state  )
);




// Control Signals for Microsequencer 


    // Load Registers (datapath and register file)
assign o_LD_MAR        = w_current_state[41];
assign o_LD_MDR        = w_current_state[40];
assign o_LD_IR         = w_current_state[39];

assign o_LD_REG        = w_current_state[37];
assign o_LD_CC         = w_current_state[36];
assign o_LD_PC         = w_current_state[35];
//assign o_LD_Priv       = w_current_state[34];
assign o_LD_SavedSSP   = w_current_state[33];
assign o_LD_SavedUSP   = w_current_state[32];
//assign o_LD_Vector     = w_current_state[31];
//assign o_LD_Priority   = w_current_state[30];
//assign o_LD_ACV        = w_current_state[29];

    // Control What data goes onto CPU Bus 
assign o_GatePC        = w_current_state[28];
assign o_GateMDR       = w_current_state[27];
assign o_GateALU       = w_current_state[26];
assign o_GateMarMux    = w_current_state[25];
//assign o_GateVector    = w_current_state[24];
//assign o_GatePC_minus1 = w_current_state[23];
assign o_GateSRP       = w_current_state[22];
//assign o_GateSP        = w_current_state[21];

    // Mux Control Signals
assign o_PCMUX     = w_current_state[20:19];
assign o_DRMUX     = w_current_state[18:17];
assign o_SR1MUX    = w_current_state[16:15];
assign o_ADDR1MUX  = w_current_state[14];
assign o_ADDR2MUX  = w_current_state[13:12];
//assign o_SPMUX     = w_current_state[11:10];
assign o_MARMUX    = w_current_state[9];
//assign o_TableMUX  = w_current_state[8];
//assign o_VectorMUX = w_current_state[7:6];
//assign o_PSRMUX    = w_current_state[5];

    // ALU Control 
assign o_ALUK      = w_current_state[4:3];

    // Memory Control 
assign o_MIO_EN    = w_current_state[2];
assign o_R_W       = w_current_state[1];

    // Privilege Control
//assign o_Set_Priv  = w_current_state[0];






endmodule //LC3_control_logic
