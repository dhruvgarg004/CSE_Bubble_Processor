`timescale 1ns/1ps

module Text (rst , clk , r_addr , w_addr , w_en , dout , din);
input wire rst, clk, w_en;
input wire[31:0] r_addr, w_addr, din;
output wire[31:0] dout;

reg[31:0] mem [65535:0];

initial begin
   mem[0] = 32'h00808020;   //add $s0 , $a0, $0 #address of array in $s0
   mem[1] = 32'h00a08820;  //add $s1 , $a1 , $0 #size of array in $s0
   mem[2] = 32'h2232ffff;  //addi $s2 , $s1 , -1  #i=n-1

   mem[3] = {6'b011000 , 5'd18 , 5'd0 , 16'd13};    //Loop1:  beq $s2 , $0 , exit1   #exit1 when i=0

   mem[4] = 32'h00009820;    //add $s3 , $0 , $0   #j=0

   mem[5] = {6'b011000 , 5'd19 , 5'd18 , 16'd9};    //Loop2:  beq $s3 , $s2 , exit2   #exit2 when j=i
   
   mem[6] = 32'h02134020;   //add $t0 , $s0 , $s3     #t0 = a+j
   mem[7] = 32'h8d140000;   //lw $s4 , 0($t0)     #s4 = a[j]
   mem[8] = 32'h8d150001;   //lw $s5 , 1($t0)     #s5 = a[j+1]

   mem[9] = {6'b011110 , 5'd20 , 5'd21 , 16'd3};   //ble $s4 , $s5 , afterswap   #if a[j]<=a[j+1] dont swap

   mem[10] = 32'had140001;   //sw $s4, 1($t0)
   mem[11] = 32'had150000;   //sw $s5 , 0($t0)
   mem[12] = 32'h22730001;   //addi $s3 , $s3 , 1  #j=j+1 (afterswap)

   mem[13] = {6'd2 , 26'd5};   //j Loop2

   mem[14] = 32'h2252ffff;   //addi $s2, $s2 , -1  #i = i-1(exit2)

   mem[15] = {6'd2 , 26'd3};   //j Loop1 
   mem[16] = {6'b011000 , 5'd0 , 5'd0 , 16'd0}; // (exit1)

end

assign dout = mem[r_addr[15:0]];

always@(posedge clk) begin
   if (w_en) begin
        mem[w_addr[15:0]] = din;
   end
end
endmodule


module Data (rst , clk , r_addr , w_addr , w_en , dout , din);
input wire rst, clk, w_en;
input wire[31:0] r_addr, w_addr, din;
output wire[31:0] dout;

reg[31:0] mem [65535:0];

assign dout = mem[r_addr[15:0]];

initial begin
   mem[0] = 20;
   mem[1] = 40;
   mem[2] = 60;
   mem[3] = 10;
   mem[4] = 0;
end

initial begin
   $monitor("%d %d %d %d %d",mem[0],mem[1],mem[2],mem[3],mem[4]);
end

always@(posedge clk) begin
   if (w_en) begin
        mem[w_addr[15:0]] = din;
   end
end
endmodule
