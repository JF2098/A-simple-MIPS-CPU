`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/08 20:11:08
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.vh"

module alu(
    input[31:0] a,b,
    input[7:0] op, //alucontrol
    input[4:0] sa,
    input[63:0] hilo_o,
    input[63:0] div_res,
    input[31:0] cp0data,
    output reg[31:0] y,
    output overflow,
    output zero,
    output reg[63:0] hilo_i
);
wire [31:0] mult_a, mult_b;
wire [63:0] mulres;
wire [31:0] subresult;
wire [63:0] hilo_temp;


assign mult_a = ((op == `EXE_MULT_OP) && (a[31] == 1'b1))? (~a + 1):a;
assign mult_b = ((op == `EXE_MULT_OP) && (b[31] == 1'b1))? (~b + 1):b;
assign hilo_temp = mult_a * mult_b;
assign mulres = ((op == `EXE_MULT_OP) && (a[31]^b[31] == 1'b1))?~hilo_temp +1 : hilo_temp;
assign subresult = a + (~b + 1);

assign zero = (y==32'b0);

assign overflow = ((op == `EXE_ADD_OP) || (op == `EXE_ADDI_OP))? (y[31] && !a[31] && !b[31]) || (!y[31] && a[31] && b[31]):
                  (op == `EXE_SUB_OP)? ((a[31]&!b[31])&!y[31]) || ((!a[31]&b[31])&y[31]):
                  1'b0;             

always@(*) begin
    case(op)
        `EXE_AND_OP, `EXE_ANDI_OP: y<= a & b;
        `EXE_OR_OP, `EXE_ORI_OP: y <= a | b;
        `EXE_XOR_OP, `EXE_XORI_OP: y <= a ^ b;
        `EXE_NOR_OP: y <= ~(a | b);
        `EXE_LUI_OP: y <= {b[15:0],b[31:16]};
        `EXE_SLL_OP: y <= b<<sa;
        `EXE_SRL_OP: y <= b>>sa;
        `EXE_SRA_OP: y <= ({32{b[31]}} << (6'd32 - {1'b0,sa})) | b>>sa;
        `EXE_SLLV_OP: y <= b<<a[4:0];
        `EXE_SRLV_OP: y <= b>>a[4:0];
        `EXE_SRAV_OP: y <= ({32{b[31]}} << (6'd32 - {1'b0,a[4:0]})) | b>>a[4:0];
        `EXE_MFHI_OP: y <= hilo_o[63:32];
        `EXE_MFLO_OP: y <= hilo_o[31:0];
        `EXE_ADD_OP, `EXE_ADDI_OP, `EXE_ADDU_OP, `EXE_ADDIU_OP: y<= a+b;
        `EXE_SUB_OP, `EXE_SUBU_OP: y <= subresult;
        `EXE_SLT_OP, `EXE_SLTI_OP: y <= ((a[31] && !b[31]) || (!a[31] && !b[31] && subresult[31]) ||  (a[31] && b[31] && subresult[31]));
        `EXE_SLTU_OP, `EXE_SLTIU_OP: y <= a<b;
        `EXE_LB_OP, `EXE_LBU_OP, `EXE_LH_OP, `EXE_LHU_OP, `EXE_LW_OP, `EXE_SB_OP, `EXE_SH_OP, `EXE_SW_OP: y<=a+b;
        `EXE_MTC0_OP: y <= b;
        `EXE_MFC0_OP: y <= cp0data;
        `EXE_MTHI_OP: hilo_i <= {a, hilo_o[31:0]};
        `EXE_MTLO_OP: hilo_i <= {hilo_o[63:32],a};
        `EXE_MULT_OP, `EXE_MULTU_OP: hilo_i <= mulres;
        `EXE_DIV_OP, `EXE_DIVU_OP: hilo_i <= div_res;
        //8'b11111111: y <= (a[31] == 1'b0)?a:(~a+1);
    endcase
end
endmodule
