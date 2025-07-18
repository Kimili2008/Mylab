`timescale 1ns/1ps
//process : the regfile and alu is finished//
//addermux is finished//
//buses'definitions are defined//
//for control signals w_XX_Control//
//for buses w_XX_out//
//led display-seg_part developed//
//microinstructions development finished//
//initialisation
//debounce btn logic
module LC3(
    input clk_0,
    input rst,
    input btn, //increment the value of LED register by one
    output reg[7:0] seg_output_single,
    output reg[3:0] seg_output_sequence,
    output reg[3:0] led_output
);


//clk signal handle-
//FPGA Crystal Oscillater 50MHZ
wire clk;
reg [2:0] clk_cnt = 3'b000;
always @(posedge clk_0) begin
    clk_cnt <= clk_cnt + 1;
end
assign clk = clk_cnt[2];

//LC-3//
wire [3:0] sw; // the led states line
reg [15:0] IR;
//Buses//
wire [15:0] w_CPU_bus ; //only one signal passes through this line at a time
wire [15:0] w_Adder_out ;//From the PC adder
wire [15:0] w_PC_out;
wire [15:0] w_ALU_out;
wire [2:0] w_NZP_out;
wire [15:0] w_MDR_out;
wire [15:0] w_SR1_out;
wire [15:0] w_SR2_out;
wire [15:0] w_MarMux_out;





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
//Tri-state Gates//
// Control what is on CPU bus (gates) 
assign w_CPU_bus =  (w_GateMarMux_Control)  ? w_MarMux_out :
                    (w_GatePC_Control)      ? w_PC_out :
                    (w_GateALU_Control)     ? w_ALU_out :
                    (w_GateMDR_Control)     ? w_MDR_out :
                    16'hFFFF;   // Default to 65535 or -1
    
//wire [3:0] bus_sel = {w_GateMarMux_Control, w_GatePC_Control, 
                     //w_GateALU_Control, w_GateMDR_Control};
//always @(*) begin
  //  casex(bus_sel)
    //    4'b1xxx: w_CPU_bus <= w_MarMux_out;
      //  4'b01xx: w_CPU_bus = w_PC_out;
        //4'b001x: w_CPU_bus = w_ALU_out;
        //4'b0001: w_CPU_bus = w_MDR_out;
        //default: w_CPU_bus = 16'hFFFF;
    //endcase
//end
always @(posedge clk) begin
    if (w_LD_IR_Control)
        IR <= w_CPU_bus;
end



//led display
wire [15:0] w_Seg_Reg_out;
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
    .DIS_reg(w_Seg_Reg_out),
    .SR1_out(w_SR1_out),
    .SR2_out(w_SR2_out)
);


//PC//
LC3_pc u_LC3_pc (
    .clk(clk),
    .rst(rst),
    .o_pc(w_PC_out),
    .pc_mux(w_PCMUX_Control),
    .ld_pc(w_LD_PC_Control),
    .cpu_bus(w_CPU_bus),
    .jmp_addr(w_Adder_out)
);






//alu//

// *opcode:add 00 and 01 not 10
LC3_alu alu_inst (
    .operand1(IR[4:0]), //Immediate
    .operand0(w_SR2_out), //
    .operand2(w_SR1_out),
    .opcode(w_ALUK_Control),
    .SR2MUX(IR[5]),
    .alu_out(w_ALU_out)
);



//LC-3 Core

LC3_control_logic u_LC3_control_logic(
    .i_clk        	(clk),
    .i_IR         	(IR),
    .i_Ready_Bit  	(w_Ready_Bit),
    .i_NZP        	(w_NZP_out),
    .i_Reset      	(rst),
    .o_LD_MAR     	(w_LD_MAR_Control),
    .o_LD_MDR     	(w_LD_MDR_Control),
    .o_LD_IR      	(w_LD_IR_Control),
    .o_LD_REG     	(w_LD_REG_Control),
    .o_LD_CC      	(w_LD_CC_Control),
    .o_LD_PC      	(w_LD_PC_Control),
    .o_GatePC     	(w_GatePC_Control),
    .o_GateMDR    	(w_GateMDR_Control),
    .o_GateALU    	(w_GateALU_Control),
    .o_GateMarMux 	(w_GateMarMux_Control),
    .o_PCMUX      	(w_PCMUX_Control),
    .o_DRMUX      	(w_DRMUX_Control),
    .o_SR1MUX     	(w_SR1MUX_Control),
    .o_ADDR1MUX   	(w_ADDR1MUX_Control),
    .o_ADDR2MUX   	(w_ADDR2MUX_Control),
    .o_MARMUX     	(w_MARMUX_Control),
    .o_ALUK       	(w_ALUK_Control),
    .o_MIO_EN     	(w_MEM_EN_Control),
    .o_R_W        	(w_R_W_Control)
);


// output declaration of module LC3_nzp


LC3_nzp u_LC3_nzp(
    .i_CLK           	(clk),
    .i_LD_CC_Control 	(w_LD_CC_Control  ),
    .i_Bus           	(w_CPU_bus),
    .o_NZP           	(w_NZP_out)
);


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

//Marmux//
// output declaration of module LC3_MarMux

LC3_MarMux #(
    .immediate 	(0  ),
    .addr      	(1  ))
u_LC3_MarMux(
    .i_Marmux_Control 	(w_MARMUX_Control),
    .i_offset_addr    	(w_Adder_out),
    .i_IR_7_0         	(IR[7:0]),
    .o_MarMux_out     	(w_MarMux_out)
);

// output declaration of module LC3_Memory_wrapper
//Memory//
LC3_Memory_wrapper u_LC3_Memory_wrapper(
    .i_CLK       	(clk),
    .i_LED_dis   	(sw),
    .i_LD_MDR    	(w_LD_MDR_Control),
    .i_LD_MAR    	(w_LD_MAR_Control),
    .i_RW        	(w_R_W_Control), //R/W
    .i_MIO_EN    	(w_MEM_EN_Control),
    .i_Bus       	(w_CPU_bus),
    .o_Bus       	(w_MDR_out),
    .o_Ready_Bit 	(w_Ready_Bit)
);


parameter R0 = 4'b0000;
parameter R1 = 4'b0001;
parameter R2 = 4'b0010;
parameter R3 = 4'b0011;
parameter R4 = 4'b0100;
parameter R5 = 4'b0101;
parameter R6 = 4'b0110;
parameter R7 = 4'b0111;
parameter PC = 4'b1000;
parameter MAR = 4'b1001;
parameter MDR = 4'b1010;
parameter Ir = 4'b1011;

//LED display
reg [15:0] Seg_reg;
reg [11:0] counter1;
reg [1:0] counter2;
assign sw = led_output;
always @(posedge btn or posedge rst) begin
    if (rst) begin
        led_output <= 4'b0000;
    end
    else begin
    led_output <= led_output + 1;
    end
end
//数位管扫描功能实现
parameter counter = 12'd2500;//2500
always @(posedge clk or posedge rst) begin
    if (rst) begin
        Seg_reg <= 16'h0000;
        counter1 <= 12'd0;
        counter2 <= 2'b00;
    end
    else begin
        if (counter1 == counter) begin
            counter1 <= 12'd0;
            counter2 <= counter2 + 1;
        end
        else begin
            counter1 <= counter1 + 1;
        end
        case (led_output)
            R0: Seg_reg <= w_Seg_Reg_out;
            R1: Seg_reg <= w_Seg_Reg_out ;
            R2: Seg_reg <= w_Seg_Reg_out ;
            R3: Seg_reg <= w_Seg_Reg_out ;
            R4: Seg_reg <= w_Seg_Reg_out ;
            R5: Seg_reg <= w_Seg_Reg_out ;
            R6: Seg_reg <= w_Seg_Reg_out ;
            R7: Seg_reg <= w_Seg_Reg_out ;
            PC: Seg_reg <= w_PC_out ;
        //MAR: Seg_reg <= w_MAR_out ;
            MDR: Seg_reg <= w_MDR_out ;
            Ir: Seg_reg <= IR ;
            default: Seg_reg <= 16'h0000;
        endcase
    end
end




// 数字到七段码的映射（共阴极数码管）
function [7:0] seg7;
    input [3:0] num;
    begin
        case (num)
            4'h0: seg7 = 8'b00111111; // 0
            4'h1: seg7 = 8'b00000110; // 1
            4'h2: seg7 = 8'b01011011; // 2
            4'h3: seg7 = 8'b01001111; // 3
            4'h4: seg7 = 8'b01100110; // 4
            4'h5: seg7 = 8'b01101101; // 5
            4'h6: seg7 = 8'b01111101; // 6
            4'h7: seg7 = 8'b00000111; // 7
            4'h8: seg7 = 8'b01111111; // 8
            4'h9: seg7 = 8'b01101111; // 9
            4'hA: seg7 = 8'b01110111; // A
            4'hB: seg7 = 8'b01111100; // B
            4'hC: seg7 = 8'b00111001; // C
            4'hD: seg7 = 8'b01011110; // D
            4'hE: seg7 = 8'b01111001; // E
            4'hF: seg7 = 8'b01110001; // F
            default: seg7 = 8'b00000000; // 全灭
        endcase
    end
endfunction
//display 显示是第几个Segment
//display 显示出单个Segment的值，根据Seg_reg的值
wire [3:0] digit3 = Seg_reg[15:12]; // 最高位
wire [3:0] digit2 = Seg_reg[11:8];
wire [3:0] digit1 = Seg_reg[7:4];
wire [3:0] digit0 = Seg_reg[3:0];   // 最低位

always @(posedge clk) begin
    case (counter2)
        2'b00:begin
            seg_output_sequence <= 4'b0001;
            seg_output_single <= seg7(digit0);
        end 
        2'b01: begin
            seg_output_sequence <= 4'b0010;
            seg_output_single <= seg7(digit1);
        end
        2'b10:begin
            seg_output_sequence <= 4'b0100;
            seg_output_single <= seg7(digit2);
        end
        2'b11: begin
            seg_output_sequence <= 4'b1000;
            seg_output_single <= seg7(digit3);
        end
        default: begin 
            seg_output_sequence <= 4'b0000;
            seg_output_single <= 8'b00000000;
        end
        
    endcase
end
endmodule
