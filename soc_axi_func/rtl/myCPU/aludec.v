`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/19 20:11:01
// Design Name: 
// Module Name: aludec
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

module aludec(
input [31:0] instr,
input stallD,
output [7:0] alucontrol,
output invalid
    );

wire [5:0] op;
wire [5:0] funct;
wire [4:0] rt;

assign op = instr[31:26];
assign funct = instr[5:0];
assign rt = instr[20:16];

assign alucontrol = (stallD)?8'b0:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_AND)?`EXE_AND_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_OR)?`EXE_OR_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_NOR)?`EXE_NOR_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_XOR)?`EXE_XOR_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SLL)?`EXE_SLL_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SRL)?`EXE_SRL_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SRA)?`EXE_SRA_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SRAV)?`EXE_SRAV_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SLLV)?`EXE_SLLV_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SRLV)?`EXE_SRLV_OP: 

                   (op == `EXE_SPECIAL_INST && funct == `EXE_MFHI)?`EXE_MFHI_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_MFLO)?`EXE_MFLO_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_MTHI)?`EXE_MTHI_OP: 
                   (op == `EXE_SPECIAL_INST && funct == `EXE_MTLO)?`EXE_MTLO_OP: 

                   (op == `EXE_SPECIAL_INST && funct == `EXE_SLT)? `EXE_SLT_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SLTU)? `EXE_SLTU_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_ADD)? `EXE_ADD_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_ADDU)? `EXE_ADDU_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SUB)? `EXE_SUB_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_SUBU)? `EXE_SUBU_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_MULT)? `EXE_MULT_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_MULTU)? `EXE_MULTU_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_DIV)? `EXE_DIV_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_DIVU)? `EXE_DIVU_OP:

                   (op == `EXE_SPECIAL_INST && funct == `EXE_JALR)? `EXE_JALR_OP:
                   (op == `EXE_SPECIAL_INST &&funct == `EXE_JR)? `EXE_JR_OP:
                    
                   (op == `EXE_REGIMM_INST && rt == `EXE_BLTZAL)? `EXE_BLTZAL_OP:
                   (op == `EXE_REGIMM_INST && rt == `EXE_BGEZAL)? `EXE_BGEZAL_OP:
                   (op == `EXE_REGIMM_INST && rt == `EXE_BGEZ)? `EXE_BGEZ_OP:
                   (op == `EXE_REGIMM_INST && rt == `EXE_BLTZ)? `EXE_BLTZ_OP:

                   (op == `EXE_SPECIAL_INST && funct == `EXE_SYSCALL)? `EXE_SYSCALL_OP:
                   (op == `EXE_SPECIAL_INST && funct == `EXE_BREAK)? `EXE_BREAK_OP:
                   (instr == 32'b01000010000000000000000000011000)? `EXE_ERET_OP:
                   (instr[31:21] == 11'b01000000100)? `EXE_MTC0_OP:
                   (instr[31:21] == 11'b01000000000)? `EXE_MFC0_OP:
                    
                   (op == `EXE_NOP)? `EXE_NOP_OP: 
                   (op == `EXE_ANDI)? `EXE_ANDI_OP:
                   (op == `EXE_ORI)? `EXE_ORI_OP:
                   (op == `EXE_XORI)? `EXE_XORI_OP:
                   (op == `EXE_LUI)? `EXE_LUI_OP:

                   (op == `EXE_SRL)? `EXE_SRL_OP:
                   (op == `EXE_SRLV)? `EXE_SRLV_OP:
                   (op == `EXE_SRA)? `EXE_SRA_OP:
                   (op == `EXE_SRAV)? `EXE_SRAV_OP:

                   (op == `EXE_ADDI)? `EXE_ADDI_OP:
                   (op == `EXE_ADDIU)? `EXE_ADDIU_OP:
                   (op == `EXE_SLTI)? `EXE_SLTI_OP:
                   (op == `EXE_SLTIU)? `EXE_SLTIU_OP:

                   (op == `EXE_J)? `EXE_J_OP:
                   (op == `EXE_JAL)? `EXE_JAL_OP:
                   (op == `EXE_BEQ)? `EXE_BEQ_OP:   
                   (op == `EXE_BGTZ)? `EXE_BGTZ_OP:
                   (op == `EXE_BLEZ)? `EXE_BLEZ_OP:
                   (op == `EXE_BNE)? `EXE_BNE_OP:

                   (op == `EXE_LB)? `EXE_LB_OP:
                   (op == `EXE_LBU)? `EXE_LBU_OP:
                   (op == `EXE_LH)? `EXE_LH_OP:
                   (op == `EXE_LHU)? `EXE_LHU_OP:
                   (op == `EXE_LL)? `EXE_LL_OP:
                   (op == `EXE_LW)? `EXE_LW_OP:
                   (op == `EXE_SB)? `EXE_SB_OP:
                   (op == `EXE_SC)? `EXE_SC_OP:
                   (op == `EXE_SH)? `EXE_SH_OP:
                   (op == `EXE_SW)? `EXE_SW_OP:

                   //(op == 6'b111111 && funct == 6'b000000)? 8'b11111111:
                   8'b00000000;



assign invalid = (alucontrol == 8'b00000000 && ~stallD);

endmodule
