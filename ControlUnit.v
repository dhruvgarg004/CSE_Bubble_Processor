`timescale 1ns/1ps

module control (IR , PCctrl, ALUctrl, WriteReg, ALUsrc, MemWrite, MemToReg, RegWrite, Link, Immediate);
input wire[31:0] IR;
output reg[1:0] PCctrl;//how to update PC
//0=pc+4 , 1=branch , 2=from reg , 3=jump mode
output reg[3:0] ALUctrl;//which operation alu will preform
output reg[4:0] WriteReg;//result is stored in rt or rd
output reg ALUsrc, MemWrite, MemToReg, RegWrite, Link;
output reg[31:0] Immediate;

wire[31:0] signed_im, unsigned_im;
assign signed_im = { {16{IR[15]}} , IR[15:0]};
assign unsigned_im = { 16'd0 , IR[15:0]};

wire [4:0] rs,rt,rd;
assign rs = IR[25:21];
assign rt = IR[20:16];
assign rd = IR[15:11];

parameter RFORMAT = 1'b0;
parameter IFORMAT = 1'b1;

localparam ADD_FUNC =  {3'd4,3'd0};
localparam SUB_FUNC = {3'd4,3'd2};
localparam ADDU_FUNC= {3'd4,3'd1};
localparam SUBU_FUNC ={3'd4,3'd3};
localparam AND_FUNC ={3'd4,3'd4};
localparam OR_FUNC ={3'd4,3'd5};
localparam SLL_FUNC ={3'd0,3'd0};
localparam SRL_FUNC ={3'd0,3'd2};
localparam SLT_FUNC ={3'd5,3'd2};

parameter ADD = 0;
parameter SUB = 1;
parameter AND = 2;
parameter OR = 3;
parameter SLL = 4;
parameter SRL = 5;
parameter SLT = 6;

always@(IR) begin
    Link = 0;

    if(IR[31:26] == 6'b000000) begin //R-formats
        PCctrl = 0;
        WriteReg = rd;
        ALUsrc = RFORMAT;
        MemWrite = 0;
        MemToReg = 0;
        RegWrite = 1;
        Immediate = signed_im;

        case(IR[5:0])
        ADD_FUNC: ALUctrl = 0;
        SUB_FUNC: ALUctrl = 1;
        ADDU_FUNC: ALUctrl = 0;
        SUBU_FUNC: ALUctrl = 1;
        AND_FUNC: ALUctrl = 2;
        OR_FUNC: ALUctrl = 3;
        SLL_FUNC: ALUctrl = 4;
        SRL_FUNC: ALUctrl = 5;
        SLT_FUNC: ALUctrl = 6;
        6'b001_000: begin   //jr instruction
            PCctrl = 2;
            ALUctrl = 0;
        end
        endcase
            
    end

    else if (IR[31:29] == 3'b001) begin //I-formats
        PCctrl = 0;
        WriteReg = rt;
        ALUsrc = IFORMAT;
        MemWrite = 0;
        MemToReg = 0;
        RegWrite = 1;
        case(IR[28:26])
            3'b000: begin//addi
                Immediate = signed_im;
                ALUctrl = 0;
            end
            3'b001:begin    //addiu
                Immediate = unsigned_im;
                ALUctrl = 0;
            end
            3'b010:begin    //slti
                Immediate = signed_im;
                ALUctrl = 6;
            end
            3'b011:begin    //sltiu
                Immediate = unsigned_im;
                ALUctrl = 6;
            end
            3'b100:begin    //andi
                Immediate = unsigned_im;
                ALUctrl = 2;
            end
            3'b101:begin    //ori
                Immediate = unsigned_im;
                ALUctrl = 3;
            end
        endcase        
    end

    else if (IR[31:29]==3'b011) begin  //branch
        PCctrl = 1;
        WriteReg = rt;
        ALUsrc = RFORMAT;
        ALUctrl = 0;
        MemWrite = 0;
        MemToReg = 0;
        RegWrite = 0;
        Immediate = signed_im;
        case(IR[28:26])
        3'b000: //beq
            ALUctrl = 7;
        3'b001: //bne
            ALUctrl = 8;
        3'b010: //bgt
            ALUctrl = 9;
        3'b011: //bgte
            ALUctrl = 10;
        3'b100: //ble
            ALUctrl = 11;
        3'b110: //bleq
            ALUctrl = 12;
        endcase

    end

    else if (IR[31:26]==2) begin    //j
        PCctrl = 3;
        WriteReg = rd;  //useless
        ALUsrc = IFORMAT;   //useless
        ALUctrl = 15;  //useless   
        MemWrite = 0;
        MemToReg = 0;
        RegWrite = 0;
        Immediate = signed_im;
    end

    else if (IR[31:26]==3) begin    //jal
        PCctrl = 3;
        WriteReg = 31;  //useless
        ALUsrc = IFORMAT;  //useless
        ALUctrl = 15;  //useless
        MemWrite = 0;
        MemToReg = 0;
        RegWrite = 0;
        Link = 1;
        Immediate = signed_im;
    end
    else if (IR[31:26]==6'b100011) begin  //lw
        PCctrl = 0;
        WriteReg = rt;
        ALUsrc = IFORMAT;
        ALUctrl = 0;    //add
        MemWrite = 0;
        MemToReg = 1;
        RegWrite = 1;  
        Immediate = signed_im;       
    end

    else if (IR[31:26]==6'b101011) begin  //sw
        PCctrl = 0;
        WriteReg = rt;
        ALUsrc = IFORMAT;
        ALUctrl = 0;    //add
        MemWrite = 1;
        MemToReg = 0;
        RegWrite = 0;     
        Immediate = signed_im;    
    end
    
end
endmodule
