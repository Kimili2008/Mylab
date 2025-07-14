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
    end
end

    // 读操作（同步输出）
always @(posedge clk) begin
    if (re) begin
        d_out_reg <= mem[w_raddr];
    end
end
assign d_out = d_out_reg;

    // 就绪信号（操作后立即就绪）
assign ready_bit = we || re;

reg [15:0] d_out_reg;
always @(posedge clk) begin
    if (re) d_out_reg <= mem[w_raddr];
end
assign d_out = d_out_reg;

// Memory Initialization
//------------------------------------------------------------------------------
parameter INIT_FILE = "mainmemory.mem"

initial if (INIT_FILE) begin
    $readmemh(INIT_FILE, memory);
end

endmodule
