
//process : the regfile and alu is finished//
//addermux is finished//
//buses'definitions are defined//
//for control signals w_XX_Control//
//for buses w_XX_out//
//led display-seg_part not developed
//next: microinstructions development
module LC3(
    input clk,
    input rst,
    input btn, //increment the value of LED register by one
    output reg[9:0] seg_output,
    output reg[3:0] led_output
);


//clk signal handle-
//FPGA Crystal Oscillater 50MHZ


//LC-3//
wire [3:0] sw; // the led states line
reg [15:0] MAR;
reg [15:0] MDR;
reg [15:0] IR;
reg [2:0] CC; // N Z P
reg [2:0] state; 
reg [15:0] CCR; // to calculate CC

//Buses//
wire [15:0] w_CPU_bus ; //only one signal passes through this line at a time
wire [15:0] w_Adder_out ;//From the PC adder
wire [15:0] w_PC_out;
wire [15:0] w_ALU_out;
wire [2:0] w_NZP_out;
wire [15:0] w_MDR_out;
wire [15:0] w_Processing_unit_out;
wire [15:0] w_SR1_out;
wire [15:0] w_SR2_out;

//Tri-state Gates//
// Control what is on CPU bus (gates) 
assign w_CPU_Bus =  (w_GateMarMux_Control)  ? w_MarMux_Out :
                    (w_GatePC_Control)      ? w_PC_Out :
                    (w_GateALU_Control)     ? w_ProcessingUnit_Out :
                    (w_GateMarMux_Control)  ? w_MarMux_Out :
                    (w_GateMDR_Control)     ? w_MDR_Out :
                    16'hFFFF;   // Default to 65535 or -1
always @(posedge clk) begin
    if (LD_IR_Control)
        IR <= w_CPU_bus;
end


//Wire control signals
wire w_Ready_Bit;
wire w_NZ_Control;
wire w_SR2MUX_Control;

// Load Registers
wire w_LD_MAR_Control;
wire w_LD_MDR_Control;
wire w_LD_IR_Control;    
wire w_LD_REG_Control;      
wire w_LD_CC_Control;       
wire w_LD_PC_Control;
// Tristate gate controls
wire w_GatePC_Control;
wire w_GateMDR_Control;
wire w_GateALU_Control;
wire w_GateMarMux_Control;
wire [1:0] w_PCMUX_Control;
wire [1:0] w_DRMUX_Control; // might be not in use
wire [1:0] w_SR1MUX_Control; 
wire [0:0] w_ADDR1MUX_Control; 
wire [1:0] w_ADDR2MUX_Control;
wire w_MARMUX_Control;
wire [1:0] w_ALUK_Control;
//Memory Control
wire w_MEM_EN_Control;
wire w_R_W_Control; //Read-Write Control



//Register(R0-R7)//
LC3_regfile regfile_inst (
    .clk(clk),
    .rst(rst),
    .DR(IR[11:9]),
    .SR1(IR[8:6]),
    .SR2(IR[2:0]), // controls the immediate
    .d(w_CPU_bus),
    .we(w_LD_REG_Control),
    .DIS_sw(sw),
    .DIS_reg(Seg_reg),
    .SR1_out(w_SR1_out),
    .SR2_out(w_SR2_out)
);

//Memory//
LC3_mem mem_inst (
    .clk(clk),
    .addr(mem_addr),
    .d_in(mem_d_in),
    .we(mem_we),
    .d_out(mem_d_out)
);
//PC
LC3_pc u_LC3_pc (
    .clk(clk),
    .rst(rst),
    .o_pc(w_PC_out),
    .pc_mux(w_PCMUX_Control),
    .ld_pc(w_LD_PC_Control),
    .cpu_bus(w_CPU_bus),
    .jmp_addr(w_Adder_out),
);


//FSM
parameter PCFETCH = 3'b000;
parameter DECODE = 3'b001;
parameter EVADD = 3'b010;
parameter OPERFETCH = 3'b011;
parameter STORE = 3'b100;



//alu//

// *opcode:add 00 and 01 not 10
LC3_alu alu_inst (
    .operand1(IR[4:0]), //Immediate
    .operand0(w_SR2_out), //
    .operand2(w_SR1_out),
    .opcode(w_ALUK_Control),
    .SR2MUX(w_SR2MUX_Control),
    .alu_out(w_ALU_out)
);



//LC-3 Core




//CC control
always @(*) begin
    if (CCR = 16'd0) //Z
        CC <= 3'd010;
    else if (CCR[15]) //N
        CC <= 3'd100;
    else    //P
        CC <= 3'd001;
end

//Adder Control//
// output declaration of module LC3_addermux

LC3_addermux u_LC3_addermux(
    .i_PC           	(w_PC_out),
    .i_SR1          	(w_SR1_out),
    .i_addr1mux     	(w_ADDR1MUX_Control),
    .i_IR_10_0      	(IR[10:0]),
    .i_IR_8_0       	(IR[8:0]),
    .i_IR_5_0       	(IR[5:0]),
    .i_addr2mux     	(w_ADDR2MUX_Control),
    .o_addermux_out 	(w_Adder_out)
);



//LED display
reg [15:0] Seg_reg;

always @(posedge btn) begin
    led_output <= led_output + 1;
end
always @(*) begin
    if (rst) led_output <= 4'b0000;
end
endmodule

