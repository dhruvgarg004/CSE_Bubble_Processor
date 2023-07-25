`timescale 1ns/1ps

module ALU (in1 , in2 , shamt, ALUctrl , out , zero);

input wire [31:0] in1,in2;
input wire[4:0] shamt;
input wire[3:0] ALUctrl;
output reg[31:0] out;
output wire zero;

assign zero = (out==32'd0);

parameter ADD = 0;
parameter SUB = 1;
parameter AND = 2;
parameter OR = 3;
parameter SLL = 4;
parameter SRL = 5;
parameter SLT = 6;
parameter BEQ = 7;
parameter BNE = 8;
parameter BGT = 9;
parameter BGTE = 10;
parameter BLE = 11;
parameter BLEQ = 12;

always @(*) begin
    case(ALUctrl)

    ADD: out = in1 + in2;
    SUB: out = in1 - in2;
    AND: out = in1 & in2;
    OR: out = in1 | in2;
    SLL: out = in1 << shamt;
    SRL: out = in1 >> shamt;
    SLT: out = (in1<in2)? 1:0;
    BEQ: out = (in1==in2)?0:1;
    BNE: out = (in1!=in2)?0:1;
    BGT: out = (in1>in2)?0:1;
    BGTE: out = (in1>=in2)?0:1;
    BLE: out = (in1<in2)?0:1;
    BLEQ: out = (in1<=in2)?0:1;

    endcase
end
endmodule
