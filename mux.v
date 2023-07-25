`timescale 1ns/1ps
module mux1bit (a,b,s,out);
input wire a,b,s;
output wire out;
assign out = a&(~s) | b&s;
endmodule

module mux32bit (a,b,s,out);
input wire[31:0] a,b;
output wire[31:0] out;
input s;

mux1bit arr[31:0] (.a(a) , .b(b) , .s({32{s}}) , .out(out));
endmodule

module mux32bit_4option (a,b,c,d,s,zero,out);
input wire[31:0] a,b,c,d;
input wire[1:0] s;
input wire zero;
output reg[31:0] out;

always @(*) begin
    case(s)
    2'b00: out<=a;
    2'b01: begin
        if (zero)
            out<=b;
        else
            out<=a;
    end
    2'b10: out<=c;
    2'b11: out<=d;
    endcase
end
endmodule
