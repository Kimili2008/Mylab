module LC3_pc(
    input wire clk,
    input wire rst,
    input wire [1:0] pc_mux,    // 00:pc+1; 01:bus; 10:jmp_addr
    input wire ld_pc,           
    input wire [15:0] cpu_bus,  
    input wire [15:0] jmp_addr, 
    output wire [15:0] o_pc
);

    reg [15:0] pc;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 16'd0;       // 同步复位
        end
        else if (ld_pc) begin  
            case (pc_mux)
                2'b00: pc <= pc + 1;    
                2'b01: pc <= cpu_bus;     
                2'b10: pc <= jmp_addr;   
                default: pc <= pc;      
            endcase
        end
    end

    assign o_pc = pc;

endmodule