module digitalock(
    input wire reset,
    input wire clk,
    input wire data,
    output wire unclock
);
localparam state0 = 4'd0;
localparam state1 = 4'd1;
localparam state2 = 4'd2;
localparam state3 = 4'd3;
localparam state4 = 4'd4;
reg [3:0] state;
reg [3:0] nextstate;
//只用state会产生锁存器和组合逻辑反馈环路
always @(clk) begin
    if(reset)
        nextstate <= state0;
    else 
        state <= nextstate;
end


always @(*) begin
    state = nextstate;
    if (data==1)
        casea (state)
            state0: nextstate <= state0;
            state1: nextstate <= state2;
            state2: nextstate <= state1;
            state3: nextstate <= state2;
            state4: nextstate <= state0;
    else
        caseb (state)
            state0: nextstate <= state1;
            state1: nextstate <= state1;
            state2: nextstate <= state3;
            state3: nextstate <= state4;
            state4: nextstate <= state1;

    unclock <= (state==state4)? 1 : 0;  
end
endmodule