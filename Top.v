`timescale 1ns/1ps
`include "memory.v"
`include "Control Unit.v"
`include "ALU.v"
`include "mux.v"

module core (rst , clk);
input wire rst,clk;

reg [31:0] PC;
wire [31:0] PC_next , IR;
reg[31:0] R [31:0];
wire[31:0] in1,in2;
wire[31:0] rs_data, rt_data;
reg[31:0] unused32 = 0;
reg unused1 = 0;
reg start;
wire[31:0] next_inst;
wire[31:0] ReadData ,ALUout , Result;
wire ALUzero;
wire [4:0] shamt;

/* control unit sigmals*/
wire[1:0] PCctrl;//how to update PC
//0=pc+4 , 1=branch , 2=from reg , 3=jump mode
wire[3:0] ALUctrl;//which operation alu will preform
wire[4:0] WriteReg;//result is stored in rt or rd
wire ALUsrc, MemWrite, MemToReg, RegWrite_en, Link;
wire[31:0] Immediate;

/*Branch Addresses*/
wire[31:0] PCplus1 , branch_addr , jr_addr , j_addr;
assign PCplus1 = PC+1;
assign branch_addr = PC + Immediate;
assign jr_addr = rs_data;
assign j_addr = {PC[31:26] , IR[25:0]};
mux32bit_4option PC_next_decider(PCplus1 , branch_addr , jr_addr , j_addr , PCctrl , ALUzero , PC_next);

/*Register file interactions*/
assign rs_data = R[IR[25:21]];
assign rt_data = R[IR[20:16]];
mux32bit Result_decider (ALUout , ReadData , MemToReg , Result);

/*ALU interactions*/
assign in1 = rs_data;
assign shamt = IR[10:6];
mux32bit in2_decider (rt_data , Immediate , ALUsrc , in2);
ALU alu (in1 , in2 , shamt, ALUctrl , ALUout , ALUzero);

Text instruction (.rst(rst) , .clk(clk) , .r_addr(PC) , .w_addr(unused32) , .w_en(unused1) , .din(unused32) , .dout(IR));
Data var (.rst(rst) , .clk(clk) , .r_addr(ALUout) , .w_addr(ALUout) , .w_en(MemWrite) , .din(rt_data) , .dout(ReadData));

control unit (IR , PCctrl, ALUctrl, WriteReg, ALUsrc, MemWrite, MemToReg, RegWrite_en, Link, Immediate);



always@(posedge rst) begin
    PC =0;
    R[4] = 0;   //$a0 = starting index = 0
    R[5] = 5;   //$a1=5=size
    
    R[0] = 0;   //$zero
    R[29] = 32'd65535;  //$sp
    start = 0;
end

always@(posedge clk) begin

    if(start==0) begin
        start = 1;
    end

    else begin
        if (RegWrite_en) R[WriteReg] = Result;
        if (Link) R[31] = PCplus1;
        //fetch
        PC = PC_next;
    end
end


endmodule
