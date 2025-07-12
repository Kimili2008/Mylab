module LC3_pc(
    input clk,
    input rst,
    input wire[1:0] pc_mux, //to control 00,pc+1 ; 01, relative address; 10,bus
    input wire ld_pc,
    input wire[15:0] cpu_bus,  // to load the value from the bus
    input wire[15:0] jmp_addr, // to change the value of PC, from the special adder
    output wire [15:0] o_pc,
    );
reg[15:0] pc;
assign o_pc = pc;
always @(*) begin
    if (rst) pc <= 16'd0;
end
always @(posedge clk) begin
    case (pc_mux)
        2'b00: pc <= pc + 1;
        2'b01: pc <= cpu_bus;
        2'b10: pc <= jmp_addr;
        default: pc <= pc;
    endcase
end

endmodule