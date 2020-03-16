`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire[31:0] instrD,
	output wire pcsrcD,branchD,
	input equalD,stallD,
	output jumpD,balD,jrD,jalD,
	output eretD,syscallD,breakD,
	output invalidD,
	//execute stage
	input wire flushE,stallE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,
	output wire hilo_writeE, hilo_dstE,
	output wire hilo_readE,
	output wire div_validE,signed_divE,
	output wire jalE,jrE,balE,
	output wire[7:0] alucontrolE,
	output wire cp0readE,
	//mem stage
	input wire flushM,stallM,
	output wire memtoregM,
	output wire	regwriteM,hilo_writeM,
	output wire hilo_dstM,memenM,cp0weM,
	output wire [7:0]alucontrolM,
	output wire memwriteM,
	//write back stage
	input wire flushW,stallW,
	output wire memtoregW,regwriteW,
	output wire hilo_writeW,hilo_dstW,
	output wire cp0weW
    );
	
	//decode stage
	wire memtoregD,alusrcD,
		regdstD,regwriteD, hilo_writeD,
		hilo_dstD,cp0weD,cp0readD;
	wire[7:0] alucontrolD;
	wire memenD;
	wire hilo_readD,memwriteD;
	//execute stage
	wire memenE,cp0weE,memwriteE;

	main_decoder md(
		.instr(instrD),.stallD(stallD),
		.regwrite(regwriteD),.regdst(regdstD),
		.alusrc(alusrcD),.branch(branchD),
		.memtoreg(memtoregD),
		.jump(jumpD),.memen(memenD),.jal(jalD),
		.jr(jrD),.bal(balD),.hilo_write(hilo_writeD),
		.hilo_dst(hilo_dstD),.hilo_read(hilo_readD),
		.div_valid(div_validD),.signed_div(signed_divD),
		.cp0we(cp0weD),.cp0read(cp0readD),.eret(eretD),
		.syscall(syscallD),.break(breakD),.memwrite(memwriteD)
		);
	aludec ad(instrD,stallD,alucontrolD,invalidD);

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(25) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,alusrcD,regdstD,regwriteD,hilo_writeD,
		hilo_dstD,hilo_readD,div_validD,signed_divD,jrD,jalD,balD,memenD,cp0weD,cp0readD,memwriteD,alucontrolD},
		{memtoregE,alusrcE,regdstE,regwriteE,hilo_writeE,
		hilo_dstE,hilo_readE,div_validE,signed_divE,jrE,jalE,balE,memenE,cp0weE,cp0readE,memwriteE,alucontrolE}
		);
	flopenrc #(17) regM(
		clk,rst,
		~stallM,
		flushM,
		{memtoregE,regwriteE,hilo_writeE,hilo_dstE,cp0weE,memenE,memwriteE,alucontrolE},
		{memtoregM,regwriteM,hilo_writeM,hilo_dstM,cp0weM,memenM,memwriteM,alucontrolM}
		);
	flopenrc #(8) regW(
		clk,rst,
		~stallW,
		flushW,
		{memtoregM,regwriteM,hilo_writeM,hilo_dstM,cp0weM},
		{memtoregW,regwriteW,hilo_writeW,hilo_dstW,cp0weW}
		);
endmodule
