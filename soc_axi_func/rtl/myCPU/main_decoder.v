`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/15 20:52:17
// Design Name: 
// Module Name: main_decoder
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

module main_decoder(
    input[31:0] instr,
    input stallD,
    output regwrite, regdst, alusrc, branch, memtoreg, jump,
    output memen, jal, jr, bal, hilo_write, hilo_dst, hilo_read, div_valid,
    output signed_div,cp0we,cp0read,eret,syscall,break,memwrite
    //output reg[1:0] aluop
    );

wire [5:0] op;
wire [5:0] funct;
wire [4:0] rt;
assign op = instr[31:26];
assign funct = instr[5:0];
assign rt = instr[20:16];

assign regwrite = ((op == `EXE_SPECIAL_INST && 
                   funct != `EXE_MTHI && funct != `EXE_MTLO && 
                   funct != `EXE_MULT && funct != `EXE_MULTU && 
                   funct != `EXE_DIV && funct != `EXE_DIVU) ||
                   (op == `EXE_ANDI) ||
                   (op == `EXE_ORI) ||
                   (op == `EXE_XORI) ||
                   (op == `EXE_ADDI) ||
                   (op == `EXE_ADDIU) ||
                   (op == `EXE_LUI) ||
                   (op == `EXE_SLTI) ||
                   (op == `EXE_SLTIU) ||
                   (op == `EXE_JAL) ||
                   (op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) ||
                   (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL) ||
                   (op == `EXE_LB) ||
                   (op == `EXE_LBU) ||
                   (op == `EXE_LH) ||
                   (op == `EXE_LHU) ||
                   (op == `EXE_LW) ||

                   (instr[31:21] == 11'b01000000000 && instr[10:0] == 11'b00000000000)//MFC0
                   ) && ~stallD; 

assign regdst = ((op == `EXE_SPECIAL_INST) || (op == 6'b111111 && funct == 6'b000000));

assign alusrc = ((op == `EXE_ANDI) ||
                 (op == `EXE_ADDI) ||
                 (op == `EXE_ORI) ||
                 (op == `EXE_XORI) ||
                 (op == `EXE_ADDIU) ||
                 (op == `EXE_LUI) ||
                 (op == `EXE_SLTI) ||
                 (op == `EXE_SLTIU) ||
                 (op == `EXE_LB) ||
                 (op == `EXE_LB) ||
                 (op == `EXE_LBU) ||
                 (op == `EXE_LH) ||
                 (op == `EXE_LHU) ||
                 (op == `EXE_LW) ||
                 (op == `EXE_SB) ||
                 (op == `EXE_SH) ||
                 (op == `EXE_SW)) && ~stallD;

assign branch = ((op == `EXE_BEQ) ||
                 (op == `EXE_BNE) ||
                 (op == `EXE_BLEZ) ||
                 (op == `EXE_BGTZ) ||

                 (op == `EXE_REGIMM_INST && rt == `EXE_BLTZ) ||
                 (op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) ||
                 (op == `EXE_REGIMM_INST && rt == `EXE_BGEZ) ||
                 (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL));

assign memtoreg = ((op == `EXE_LB) ||
                   (op == `EXE_LBU) ||
                   (op == `EXE_LH) ||
                   (op == `EXE_LHU) ||
                   (op == `EXE_LW)) && ~stallD;

assign jump = ((op == `EXE_J) ||
               (op == `EXE_SPECIAL_INST && funct == `EXE_JR));

assign memen = ((op == `EXE_LB) ||
                (op == `EXE_LBU) ||
                (op == `EXE_LH) ||
                (op == `EXE_LHU) ||
                (op == `EXE_LW) ||
                (op == `EXE_SB) ||
                (op == `EXE_SH) ||
                (op == `EXE_SW)) && ~stallD;

assign jal =  ((op == `EXE_JAL));

assign jr =  ((op == `EXE_SPECIAL_INST && funct == `EXE_JR) ||
              (op == `EXE_SPECIAL_INST && funct == `EXE_JALR));

assign bal = ((op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL) ||
              (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL));

assign hilo_write = ((op == `EXE_SPECIAL_INST && funct == `EXE_MTHI) ||
                     (op == `EXE_SPECIAL_INST && funct == `EXE_MTLO) ||
                     (op == `EXE_SPECIAL_INST && funct == `EXE_MULT) ||
                     (op == `EXE_SPECIAL_INST && funct == `EXE_MULTU) ||
                     (op == `EXE_SPECIAL_INST && funct == `EXE_DIV) ||
                     (op == `EXE_SPECIAL_INST && funct == `EXE_DIVU));

assign hilo_dst = ((op == `EXE_SPECIAL_INST && funct == `EXE_MTHI) || 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_MFHI));

assign hilo_read = ((op == `EXE_SPECIAL_INST && funct == `EXE_MFHI) ||
                    (op == `EXE_SPECIAL_INST && funct == `EXE_MFLO));

assign div_valid = (((op == `EXE_SPECIAL_INST && funct == `EXE_DIV) ||
                     (op == `EXE_SPECIAL_INST && funct == `EXE_DIVU))) && ~stallD;

assign signed_div = (op == `EXE_SPECIAL_INST && funct == `EXE_DIV) && ~stallD;

assign cp0we = (instr[31:21] == 11'b01000000100 && instr[10:0] == 11'b00000000000); //MTC0

assign cp0read = (instr[31:21] == 11'b01000000000 && instr[10:0] == 11'b00000000000); //MFC0

assign eret = (instr == 32'b01000010000000000000000000011000)&& ~stallD;

assign syscall = (op == `EXE_SPECIAL_INST && funct == `EXE_SYSCALL)&& ~stallD;

assign break = (op == `EXE_SPECIAL_INST && funct == `EXE_BREAK)&& ~stallD;

assign memwrite = (op == `EXE_SB)||(op == `EXE_SH)||(op == `EXE_SW)&& ~stallD;

endmodule
