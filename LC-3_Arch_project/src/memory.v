`timescale 1ns/1ps
module LC3_mem(
    input clk,
    input we,
    input re,
    input wire [6:0] w_raddr,
    input wire [6:0] w_waddr, // MAR-curtailed
    input wire [15:0] d,
    output reg [15:0] d_out,
    output reg ready_bit
);
reg [15:0] mem [0:127];
reg delayed_ready_bit = 0;
always @(posedge clk) begin
        if(we) begin 
            mem[w_waddr] <= d;
            ready_bit <= 1'b1; 
        end
        if(re) begin 
            d_out <= mem[w_raddr];
            // o_Ready_Bit <= 1'b1; 
            delayed_ready_bit <= 1'b1;
        end
        if(~re && ~we)
            ready_bit <= 1'b0; 
        if(delayed_ready_bit) begin
            delayed_ready_bit <= 1'b0;
            ready_bit <= 1'b1; 
        end

 end

// Memory Initialization
//------------------------------------------------------------------------------
parameter INIT_FILE = "mainmemory.mem";

initial if (INIT_FILE) begin
    $readmemh(INIT_FILE, mem);
end

endmodule
