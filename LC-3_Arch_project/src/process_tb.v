`timescale 1ns/1ps
// ALU SR1MUX left to be solved//
// interrupt problem left to be solved//
module LC3_tb();

// output declaration of module LC3
wire [7:0] seg_output_single;
wire [3:0] seg_output_sequence;
wire [3:0] led_output;
reg r_Reset = 3'b0; 
//clk generation
localparam  DURATION = 60000;
reg     clk = 0;
reg     btn = 0;
always begin 
        #5    clk = ~clk;
end

always begin
    #40    btn = ~btn;
end


//cycle 12.5 MHZ

LC3 #(
    .counter 	(2  ),
    .R0      	(0000  ),
    .R1      	(0001  ),
    .R2      	(0010  ),
    .R3      	(0011  ),
    .R4      	(0100  ),
    .R5      	(0101  ),
    .R6      	(0110  ),
    .R7      	(0111  ),
    .PC      	(1000  ),
    .MAR     	(1001  ),
    .MDR     	(1010  ),
    .Ir      	(1011  ))
u_LC3(
    .clk                 	(clk                  ),
    .rst                 	(r_Reset              ),
    .btn                 	(btn                  ),
    .seg_output_single   	(seg_output_single    ),
    .seg_output_sequence 	(seg_output_sequence  ),
    .led_output          	(led_output           )
);



//testing
  // Testing:
    //------------------------------------------------------------------------------

initial begin
        // Pulse the Reset line to clean restart the LC3 to state 18
    #(10*40)   
    r_Reset = 1'b1;
    #(40*10)
    r_Reset = 1'b0;
end 

    // Run and Output simulation to .vcd file 
    //------------------------------------------------------------------------------
integer idx; // Loop Counter for Dumping Memory
initial begin
    $dumpfile("LC3.fst");
    $dumpvars(0, LC3_tb); // 0 = Dump all vars (including sub-mods)

        // Dump Register File


        // Dump Array that gets sorted by Assembly Program 
        // Wait for sim to complete
    #(DURATION)

        // Notify the end of simulation
    $display("Finished!");
    $finish;
end


endmodule //LC3_tb
