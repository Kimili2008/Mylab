//uart protocal

module Send(
    input                   [ 0 : 0]        clk, 
    input                   [ 0 : 0]        rst,

    output      reg         [ 0 : 0]        dout,

    input                   [ 0 : 0]        dout_vld,
    input                   [ 7 : 0]        dout_data
);

// Counter and parameters
localparam FullT        = 10416;
localparam TOTAL_BITS   = 9;
reg [ 15 : 0] div_cnt;           // 分频计数器，范围 0 ~ 10416
reg [ 4 : 0] dout_cnt;          // 位计数器，范围 0 ~ 9

// Main FSM
localparam WAIT     = 0;
localparam SEND     = 1;
reg current_state, next_state;
always @(posedge clk) begin
    if (rst)
        current_state <= WAIT;
    else
        current_state <= next_state;
end

always @(*) begin
    next_state = current_state;
    case (current_state)
        0: next_state <= (dout_vld == 1);
        1: 
            next_state <= ~(dout_cnt == TOTAL_BITS);
            dout_cnt <= 0;

    endcase
end

// Counter
always @(posedge clk) begin
    if (rst)
        div_cnt <= 0;
    else if (current_state == SEND) begin
        // TODO
        div_cnt <= divcnt + 1;
    end
    else
        div_cnt <= 0;
end

always @(posedge clk) begin
    if (rst)
        dout_cnt <= 4'H0;
    else if (current_state == SEND) begin
        // TODO
        if (div_cnt == FullT)
            dout_cnt <= dout_cnt + 1;
            div_cnt <= 16'd0;
    end
    else
        dout_cnt <= 4'H0;
end

reg [7 : 0] temp_data;      // 用于保留待发送数据，这样就不怕 dout_data 的变化了
always @(posedge clk) begin
    if (rst)
        temp_data <= 8'H0;
    else if (current_state == WAIT && dout_vld)
        temp_data <= dout_data;
end

always @(posedge clk) begin
    if (rst)
        dout <= 1'B1;
    else begin
        dout <= dout_data[dout_cnt];
    end
end
endmodule




module Receive(
    input                   [ 0 : 0]        clk,
    input                   [ 0 : 0]        rst,

    input                   [ 0 : 0]        din,

    output      reg         [ 0 : 0]        din_vld,
    output      reg         [ 7 : 0]        din_data
);

// Counter and parameters
localparam FullT        = 10416;
localparam HalfT        = 5208;
localparam TOTAL_BITS   = 8;
reg [ 15 : 0]   div_cnt;       // 分频计数器，范围 0 ~ 10416
reg [ 3 : 0]    din_cnt;       // 位计数器，范围 0 ~ 8

// Main FSM
localparam WAIT     = 0;
localparam RECEIVE  = 1;
reg current_state, next_state;
always @(posedge clk) begin
    if (rst)
        current_state <= WAIT;
    else
        current_state <= next_state;
end

always @(*) begin
    next_state = current_state;
    case (current_state)
        // TODO
        1:
            next_state <= ~(din_cnt>=8 && div_cnt>=FullT);

        0:
            next_state <= (div_cnt>=HalfT);
    endcase
end

// Counter
always @(posedge clk) begin
    if (rst)
        div_cnt <= 0;
    else if (current_state == WAIT) begin // STATE WAIT
        // TODO
        if (din == 0)
            div_cnt <= div_cnt + 1;
        else
            div_cnt <= 0;
    end
    else begin  // STATE RECEIVE
        // TODO
        div_cnt <= div_cnt + 1;
    end
end

always @(posedge clk) begin
    if (rst)
        din_cnt <= 0;
    else begin
        // TODO
        din_cnt <= din_cnt + (div_cnt == FullT);
        div_cnt <= 0;
    end
end


// Output signals
reg [ 0 : 0] accept_din;    // 位采样信号
always @(*) begin
    accept_din = 1'B0;
    // TODO
    accept_din <= (div_cnt == FullT);
end

always @(*) begin
    din_vld = 1'B0;
    // TODO
    din_vld <= (div_vnt >= FullT && din_cnt == TOTAL_BITS);
end

always @(posedge clk) begin
    if (rst)
        din_data <= 8'B0;
    else if (current_state == WAIT)
        din_data <= 8'B0;
    else if (accept_din)
        din_data <= din_data | (din << din_cnt);
end
endmodule