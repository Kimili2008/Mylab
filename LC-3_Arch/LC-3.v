module LC3(
    input clk,
    input wire[3:0] sw,
    input rst,
    output reg[9:0] seg_output,
    output reg[3:0] led_output
);
//clk signal handle-
//FPGA Crystal Oscillater 50MHZ


//LC-3 //
reg [15:0] PC;
reg [15:0] MAR;
reg [15:0] MDR;
reg [15:0] IR;
reg [2:0] CC; // N Z P
reg [2:0] state; 
reg [15:0] CCR // to calculate CC

//Register(R0-R7)//
LC3_regfile regfile_inst (
    .clk(clk),
    .rst(rst),
    .DR(regfile_DR),
    .SR1(regfile_SR1_addr),
    .SR2(regfile_SR2_addr),
    .d(regfile_d),
    .we(regfile_we),
    .DIS_sw(sw),
    .DIS_reg(Seg_reg),
    .SR1_out(regfile_SR1_out),
    .SR2_out(regfile_SR2_out)
);

//Memory//
LC3_mem mem_inst (
    .clk(clk),
    .addr(mem_addr),
    .d_in(mem_d_in),
    .we(mem_we),
    .d_out(mem_d_out)
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
    .operand1(alu_operand1),
    .operand1(alu_operand2),
    .opcode(alu_opcode),
    .alu_out(alu_out)
);



//LC-3 Core//


//CC control
always @(*) begin
    if (CCR = 16'd0) 
        CC <= 3'd010;
    else if (CCR[15])
        CC <= 3'd100;
    else
        CC <= 3'd001;
end

//LED display
reg [15:0] Seg_reg;


endmodule





module LC3_mem(
    input clk,
    input we,
    input wire [6:0] addr, // MAR-curtailed
    input wire [15:0] d,
    output wire [15:0] d_out
);


reg [15:0] mem [0:127];
always @(posedge clk) begin
    if (we) mem[addr]<= d;
end
assign d_out = mem[addr];

endmodule


module LC3_regfile(
    input [2:0] DR,
    input [2:0] SR1,
    input [2:0] SR2,
    input rst,
    input clk,
    input we,
    input [3:0] DIS_sw,
    input [15:0] d,
    output reg [15:0] SR1_out,
    output reg [15:0] SR2_out,
    output reg [15:0] DIS_reg //the register being displayed
);

//assign    DR = IR[11:9];
//assign    SR1 = IR[8:6];
//assign    SR2 = IR[2:0];
parameter RLEN = 8;
reg[15:0]  R[7:0]; // Reg file
always @(posedge clk) begin
    if (we) R[DR] <= d;
end
always @(*) begin
    SR1_out <= R[SR1];
    SR2_out <= R[SR2];
end


// LED logic the first 0-2 bits of DIS_sw belongs to the 8 regs
always @(*) begin
    DIS_reg <= R[DIS_SW[2:0]]
end
//
integer i;
always @(posedge rst) begin
    for (i=0; i< RLEN;i = i + 1)
        R[i] <= 16'b0;
end

endmodule



module LC3_alu(
    input wire[15:0] operand1,
    input wire[15:0] operand2,
    input wire[3:0] opcode,
    output reg[15:0] alu_out
);
parameter ADD = 2'b00;
parameter AND = 2'b01;
parameter NOT = 2'b10;

always @(*) begin
    case(opcode)
        ADD: alu_out <= operand1 + operand2;
        AND: alu_out <= operand1 & operand2;
        NOT: alu_out <= ~operand1;
    endcase
end

endmodule
