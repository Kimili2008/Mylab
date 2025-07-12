module LC3_mem(
    input clk,
    input we,
    input re,
    input wire [6:0] w_raddr,
    input wire [6:0] w_waddr, // MAR-curtailed
    input wire [15:0] d,
    output wire [15:0] d_out,
    output reg ready_bit
);

reg delayed_bit = 0;//the read_data needs some time to be received by registers
reg [15:0] mem [0:127];
always @(posedge clk) begin
    if (we) begin
        mem[w_waddr] <= d;
        ready_bit <= 1'b1;
    end
    if (re)begin
        mem[w_waddr] <= d;
        delayed_bit <= 1'b1;
    end
        
    if (~we && ~re)
        ready_bit <= 1'b0;
    if (delayed_bit) begin
        ready_bit <= 1'b1;
        delayed_bit <= 1'b0;
    end

end



// Memory Initialization
//------------------------------------------------------------------------------
initial if (INIT_FILE) begin
    $readmemh(INIT_FILE, memory);
end

endmodule
