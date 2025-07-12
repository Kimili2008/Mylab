`timescale 1ns/1ps
module  LC3(
input                   CLK     ,
input           [15:0]  SW      ,
input           [4:0]   BTN     ,
output      reg [7:0]   SSEG_CA ,
output      reg [7:0]   SSEG_AN ,
output           [15:0]  LED
);

//////////////////////////////////////////////////////////////////
// 产生25MHz的时钟供内核使用
//////////////////////////////////////////////////////////////////
reg		[1:0]	clk_25m_cnt;
wire			clk_25m;

always @(posedge CLK)
begin
    clk_25m_cnt <= clk_25m_cnt + 1;
end

assign clk_25m = clk_25m_cnt[1];

//////////////////////////////////////////////////////////////////
// LC-3 控制
//////////////////////////////////////////////////////////////////
//内核
reg     [15:0]  PC;
reg     [15:0]  IR;
reg     [2:0]   CC;     //N Z P
reg     [15:0]  CCR;    //用于计算CC的中间寄存器
wire            BEN;
reg     [4:0]   state;  //LC-3内核自动机的状态，共有32个
//内存
reg     [9:0]   MAR;
reg     [15:0]  MDR_in;
wire    [15:0]  MDR_out;
reg     [15:0]  MDR;    //缓冲用，防止输入输出直接相接
reg             M_WE;
//OS
reg		[15:0]	cur;    //光标
reg     [1:0]	mod;    //jump:2	run:1  halt/write:0
wire	[4:0]	BTN_clean;
reg     [8:0]   ins_cnt;//指令计数器

//////////////////////////////////////////////////////////////////
// LC-3 寄存器
//////////////////////////////////////////////////////////////////
wire    [2:0]   DR;    //二进制表示
wire    [2:0]   SR1;
wire    [2:0]   SR2;

assign    DR = IR[11:9];
assign    SR1 = IR[8:6];
assign    SR2 = IR[2:0];

reg     [15:0]  R[7:0];


//////////////////////////////////////////////////////////////////
// LC-3 内存
//////////////////////////////////////////////////////////////////
parameter   memory_range = 1 << 10;
dist_mem_gen_0	M(
.a      (MAR),
.d      (MDR_in),
.spo   (MDR_out),
.clk    (CLK),
.we     (M_WE));

//////////////////////////////////////////////////////////////////
// LC-3 内核
//////////////////////////////////////////////////////////////////
assign  BEN = (IR[11] & CC[2]) |
              (IR[10] & CC[1]) |
              (IR[9] & CC[0]);
always @(*)
begin
    if(CCR == 16'b0)
        CC <= 3'b010;
    else if(CCR[15] == 1'b1)
        CC <= 3'b100;
    else
        CC <= 3'b001;
end

always @(posedge clk_25m)
begin
    case(state)
        5'd1   :
        begin
            M_WE <= 1'b0;		//暂时禁止写入，防止在state == 2时内存被修改
            ins_cnt <= ins_cnt + 1;
            state <= 5'd2;
        end
        5'd2   :
        begin
            if(PC >= memory_range || mod == 2'b0)
            begin               //PC越界或强制停机
                mod <= 2'd0;
                state <= 5'd0;
            end
            else
            begin
                MAR <= PC[9:0];
                PC <= PC + 1;
                state <= 5'd3;
            end
        end
        5'd3   :
        begin
            IR <= MDR_out;
            state <= 5'd4;
        end
        5'd4   :
        begin
            case(IR[15:12])
                4'b0001:
                    state <= 5'd5;  //ADD
                4'b0101:
                    state <= 5'd6;  //AND
                4'b1001:
                    state <= 5'd7;  //NOT
                4'b1111:
                    state <= 5'd8;  //TRAP
                4'b1110:
                    state <= 5'd11; //LEA
                4'b0010:
                    state <= 5'd12; //LD
                4'b0110:
                    state <= 5'd13; //LDR
                4'b1010:
                    state <= 5'd18; //LDI
                4'b1011:
                    state <= 5'd19; //STI
                4'b0111:
                    state <= 5'd22; //STR
                4'b0011:
                    state <= 5'd23; //ST
                4'b0100:
                    state <= 5'd29; //JSR
                4'b1100:
                    state <= 5'd28; //JMP
                4'b0000:
                    state <= 5'd26; //BR
            endcase
        end
        5'd5   :
        //ADD
        begin
            if(IR[5])
            begin
                R[DR] <= R[SR1] + {IR[4]?11'b111_1111_1111:11'b0,IR[4:0]};
                CCR   <= R[SR1] + {IR[4]?11'b111_1111_1111:11'b0,IR[4:0]};
            end
            else
            begin
                R[DR] <= R[SR1] + R[SR2];
                CCR   <= R[SR1] + R[SR2];
            end
            state <= 5'd1;
        end
        5'd6   :
        //AND
        begin
            if(IR[5])
            begin
                R[DR] <= R[SR1] & {IR[4]?11'b111_1111_1111:11'b0,IR[4:0]};
                CCR   <= R[SR1] & {IR[4]?11'b111_1111_1111:11'b0,IR[4:0]};
            end
            else
            begin
                R[DR] <= R[SR1] & R[SR2];
                CCR   <= R[SR1] & R[SR2];
            end
            state <= 5'd1;
        end
        5'd7   :
        //NOT
        begin
            R[DR] <= ~R[SR1];
            CCR   <= ~R[SR1];
            state <= 5'd1;
        end
        5'd8   :
        //TRAP
        begin
            MAR <= {IR[7]?2'b11:2'b0,IR[7:0]};
            state <= 5'd9;
        end
        5'd9   :
        begin
            R[7] <= PC;
            state <= 5'd10;
        end
        5'd10  :
        begin
            PC <= MDR_out;
            state <= 5'd1;
        end
        5'd11  :
        //LEA
        begin
            R[DR] <= PC + {IR[8]?7'b111_1111:7'b0,IR[8:0]};
            CCR   <= PC + {IR[8]?7'b111_1111:7'b0,IR[8:0]};
            state <= 5'd1;
        end
        5'd12  :
        //LD
        begin
            MAR <= PC + {IR[8]?7'b111_1111:7'b0,IR[8:0]};
            state <= 5'd14;
        end
        5'd13  :
        //LDR
        begin
            MAR <= R[SR1] + {IR[5]?10'b11_1111_1111:10'b0,IR[5:0]};
            state <= 5'd14;
        end
        5'd14  :
        begin
            state <= 5'd15;
        end
        5'd15  :
        begin
            R[DR] <= MDR_out;
            CCR <= MDR_out;
            state <= 5'd1;
        end
        5'd16  :
        begin
            MAR <= MDR[9:0];
            state <= 5'd14;
        end
        5'd17  :
        begin
            MDR <= MDR_out;
            state <= 5'd16;
        end
        5'd18  :
        begin
            MAR <= PC + {IR[8]?7'b111_1111:7'b0,IR[8:0]};
            state <= 5'd17;
        end
        5'd19  :
        begin
            MAR <= PC + {IR[8]?7'b111_1111:7'b0,IR[8:0]};
            state <= 5'd20;
        end
        5'd20  :
        begin
            MDR <= MDR_out;
            state <= 5'd21;
        end
        5'd21  :
        begin
            MAR <= MDR[9:0];
            state <= 5'd24;
        end
        5'd22  :
        //STR
        begin
            MAR <= R[SR1] + {IR[5]?10'b11_1111_1111:10'b0,IR[5:0]};
            state <= 5'd24;
        end
        5'd23  :
        begin
            MAR <= PC + {IR[5]?10'b11_1111_1111:10'b0,IR[8:0]};
            state <= 5'd24;
        end
        5'd24  :
        begin
            MDR_in <= R[DR];
            state <= 5'd25;
        end
        5'd25  :
        begin
            M_WE <= 1'b1;
            state <= 5'd1;
        end
        5'd26  :
        begin
            if(BEN)
                state <= 5'd27; //BR 1
            else
                state <= 5'd1;  //BR 0
        end
        5'd27  :
        begin
            PC <= PC + {IR[8] ? 7'b111_1111 : 7'b0,IR[8:0]};
            state <= 5'd1;
        end
        5'd28  :
        begin
            PC <= R[SR1];
            state <= 5'd1;
        end
        5'd29  :
        //JSR/JSRR
        begin
            R[7] <= PC;
            if(IR[11])
                state <= 5'd30;
            else
                state <= 5'd31;
        end
        5'd30  :
        begin
            PC <= PC + {IR[10]?5'b11111:5'b0,IR[10:0]};
            state <= 5'd1;
        end
        5'd31  :
        begin
            PC <= R[SR1];
            state <= 5'd1;
        end
        default:
        //state == 0 , 当执行HALT后跳转到该状态
        begin
            MAR <= cur[9:0];
            if(mod == 2'b01)
            begin
                PC <= SW;			//启动，从SW开始执行
                ins_cnt <= 0;       //指令计数器清空
                state <= 5'd1;
            end
            else
                state <= 5'd0;		//保持停机状态
            if (mod == 2'b00 && BTN_clean[4])		//Press Enter
            begin
                M_WE <= 1'b1;	//允许写入
                MDR_in <= SW;
            end
            else
                M_WE <= 1'b0;
        end
    endcase
endmodule
