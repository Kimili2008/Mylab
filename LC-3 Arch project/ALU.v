
module LC3_alu(
    input wire[4:0] operand1,
    input wire[15:0] operand2,
    input wire[15:0] operand0,
    input wire SR2MUX,
    input wire[1:0] opcode,
    output reg[15:0] alu_out
);
parameter ADD = 2'b00;
parameter AND = 2'b01;
parameter NOT = 2'b10;
parameter PASS1 = 2'b11;
//sr2mux = 0, SR2, else, immediate
wire [15:0] MUX_out;
wire [15:0] w_Imm5_SEXT;
assign w_Imm5_SEXT = (operand1[4]) ? {11'b11111111111, operand1} : {11'b00000000000, operand1};



always @(*) begin // @ any "input" change, update value
    case(SR2MUX)
        1'b0: MUX_out = operand0;     // SR2 from register file  
        1'b1: MUX_out = w_Imm5_SEXT;   // Immediate 5 (from IR)
    endcase
end

always @(*) begin
    case(opcode)
        ADD: alu_out = MUX_out + operand2;
        AND: alu_out = MUX_out & operand2;
        NOT: alu_out = ~MUX_out;
        PASS1: alu_out = MUX_out;
        default: alu_out = 16'h0000;
    endcase
end

endmodule
