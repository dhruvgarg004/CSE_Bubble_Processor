`timescale 1ns/1ps
`include "ALU.v"

module alutb();
reg[31:0] in1,in2;
reg[4:0] shamt;
reg[3:0] ALUctrl;
wire [31:0] out;
wire zero;
integer i;

ALU uut (in1 , in2 , shamt, ALUctrl , out , zero);

initial begin

    in1 = 20;
    in2 = 10;
    shamt = 2;

    for (i=0 ; i<13 ; i=i+1) begin
        ALUctrl = i;
        #1 $display("%d %d %d",out,zero,ALUctrl);
        #5;
    end
end

endmodule
