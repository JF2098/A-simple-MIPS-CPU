`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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

module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,balD,
	input wire jalD,jrD,
	input wire eretD,syscallD,breakD,
	input wire invalidD,
	output wire equalD,stallD,
	output wire[31:0] instrD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire hilo_writeE,hilo_dstE,
	input wire hilo_readE,
	input wire div_validE,signed_divE,
	input wire jalE,jrE,balE,cp0readE,
	input wire[7:0] alucontrolE,
	output wire flushE,stallE,
	//mem stage
	input wire memtoregM,regwriteM,
	input wire hilo_writeM,hilo_dstM,
	input wire memenM,
	input wire[31:0] readdataM,
	input wire[7:0] alucontrolM,
	input wire cp0weM,
	output wire[31:0] aluoutM,writedata2M,
	output wire[3:0] selM,rselM,
	output flushM,stallM,
	output wire flush_except,
	output wire [1:0] sizeM,
	//writeback stage
	input wire memtoregW,regwriteW,
	input wire hilo_writeW,hilo_dstW,
	input wire cp0weW,
	output flushW,stallW,
	//debug
	output wire[31:0] pcW,
	output wire[3:0] rf_wen,
	output wire[4:0] writeregW,
	output wire[31:0] resultW,
	//
	input wire stallreq_from_if,stallreq_from_mem
	
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	wire [31:0] pcplus8F;
	wire is_in_delayslotF;
	wire flushF;
	wire [7:0] exceptF;
	//decode stage
	wire [31:0] pcplus4D;
	wire forwardaD,forwardbD;
	wire[5:0] opD,functD;
	wire [4:0] rsD,rtD,rdD,saD;
	wire flushD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [1:0] typeD;
	wire [31:0] pcplus8D;
	wire [1:0] jumpjrjalD;
	wire [31:0] pcD;
	wire is_in_delayslotD;
	wire [7:0] exceptD;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [1:0] forwardhiloE, forwardcp0E;
	wire div_stallE;
	wire [4:0] rsE,rtE,rdE,saE;
	wire [4:0] writeregE,writereg2E;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E;
	wire [31:0] srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E;
	wire [63:0] hilo_iE, hilo_o2E;
	wire [31:0] hilo_oE;
	wire overflowE, zeroE;
	wire [63:0] div_resE;
	wire [31:0] pcplus8E;
	wire [31:0] pcE;
	wire is_in_delayslotE;
	wire [31:0] cp0dataE, cp0data2E;
	wire [7:0] exceptE;
	//mem stage
	wire [4:0] writeregM;
	wire [63:0] hilo_iM;
	wire [31:0] writedataM,readdata2M;
	wire [31:0] pcM,newpcM;
	wire [4:0] rdM;
	wire is_in_delayslotM;
	wire [7:0] exceptM;
	wire adelM,adesM;
	wire [31:0] bad_addrM,excepttypeM;
	//writeback stage
	wire [31:0] aluoutW,readdataW;
	wire [63:0] hilo_iW, hilo_oW;
	wire [4:0] rdW;
	wire[31:0] count_oW,compare_oW,status_oW,cause_oW,epc_oW, config_oW,prid_oW,badvaddrW;
	
	//hazard detection
	hazard h(
		//fetch stage
		.stallF(stallF),.flushF(flushF),
		//decode stage
		.rsD(rsD),.rtD(rtD),
		.branchD(branchD),.jumpD(jumpD),.jrD(jrD),.balD(balD),.jalD(jalD),
		.forwardaD(forwardaD),.forwardbD(forwardbD),
		.stallD(stallD),.flushD(flushD),
		//execute stage
		.rsE(rsE),.rtE(rtE),.rdE(rdE),
		.writeregE(writeregE),.regwriteE(regwriteE),.memtoregE(memtoregE),
		.hilo_readE(hilo_readE),.hilo_dstE(hilo_dstE),.cp0readE(cp0readE),
		.div_stallE(div_stallE),.pcsrcD(pcsrcD),
		.forwardaE(forwardaE),.forwardbE(forwardbE),.forwardhiloE(forwardhiloE),
		.stallE(stallE),.flushE(flushE),
		.forwardcp0E(forwardcp0E),
		//mem stage
		.writeregM(writeregM),.rdM(rdM),
		.regwriteM(regwriteM),.memtoregM(memtoregM),
		.hilo_writeM(hilo_writeM),.hilo_dstM(hilo_dstM),.cp0weM(cp0weM),
		.flushM(flushM),.stallM(stallM),
		//write back stage
		.writeregW(writeregW),.rdW(rdW),
		.regwriteW(regwriteW),
		.hilo_writeW(hilo_writeW),.hilo_dstW(hilo_dstW),.cp0weW(cp0weW),
		.excepttypeM(excepttypeM),
		.flushW(flushW),.stallW(stallW),

		.stallreq_from_if(stallreq_from_if),.stallreq_from_mem(stallreq_from_mem),
		.flush_except(flush_except)
		);

	assign jumpjrjalD = (!jumpD & !jrD & !jalD)? 2'b00:
					 ((jumpD & !jrD) | jalD)? 2'b01:
					 (jrD)? 2'b10:
					 2'b00;
					 
	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux3 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},srca2D,
		jumpjrjalD,pcnextFD);
	//regfile (operates in decode and writeback)
	regfile rf(.clk(clk),.we3(regwriteW),.ra1(rsD),.ra2(rtD),.wa3(writeregW),.wd3(resultW),.rd1(srcaD),.rd2(srcbD));

	//fetch stage logic
	pcflopenrc #(32) pcreg(clk,rst,~stallF,flushF,pcnextFD,newpcM,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	adder pcadd2(pcF,32'b1000,pcplus8F);
	//except: keep,adel,ades,sys,bp,eret,ri,ov
	assign exceptF = (pcF[1:0] == 2'b00)? 8'b00000000 : 8'b01000000;
	assign is_in_delayslotF = (jumpD|jalD|jrD|balD|branchD);
	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcplus8F,pcplus8D);
	flopenrc #(32) r4D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(8) r5D(clk,rst,~stallD,flushD,exceptF,exceptD);
	flopenrc #(1) r6D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);

	signext se(instrD[15:0],typeD,signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd3(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign typeD = instrD[29:28];
	assign saD = instrD[10:6];

	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	flopenrc #(32) r9E(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(8) r10E(clk,rst,~stallE,flushE,{exceptD[7:5],syscallD,breakD,eretD,invalidD,exceptD[0]},exceptE);
	flopenrc #(1) r11E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux3 #(64) forwardhilomux(hilo_oW,hilo_iW,hilo_iM,forwardhiloE,hilo_o2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	mux3 #(32) forwardcp0mux(cp0dataE,aluoutW,aluoutM,forwardcp0E,cp0data2E);

	div_radix2 div(~clk,rst,srca2E,srcb3E,div_validE,signed_divE,div_stallE,div_resE);
	alu alu(srca2E,srcb3E,alucontrolE,saE,hilo_o2E,div_resE,cp0data2E,aluoutE,overflowE,zeroE,hilo_iE);
	mux2 #(5) wrmux(rtE,rdE,regdstE,writeregE);
	mux2 #(5) wrmux2(writeregE,5'b11111,jalE|balE,writereg2E);
	mux2 #(32) wrmux3(aluoutE,pcplus8E,jalE|jrE|balE,aluout2E);

	//mem stage
	flopenrc #(32) r1M(clk,rst,~stallM,flushM,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~stallM,flushM,aluout2E,aluoutM);
	flopenrc #(5) r3M(clk,rst,~stallM,flushM,writereg2E,writeregM);
	flopenrc #(64) r4M(clk,rst,~stallM,flushM,hilo_iE,hilo_iM);
	flopenrc #(32) r5M(clk,rst,~stallM,flushM,pcE,pcM);
	flopenrc #(5) r6M(clk,rst,~stallM,flushM,rdE,rdM);
	flopenrc #(1) r7M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
	flopenrc #(8) r8M(clk,rst,~stallM,flushM,{exceptE[7:1],overflowE},exceptM);

	data_mem_shell dmemshell(alucontrolM,aluoutM[1:0],writedataM,readdataM,selM,rselM,writedata2M,readdata2M,adelM,adesM,sizeM);
	exception except(rst,cp0weW,rdW,aluoutW,adelM,adesM,exceptM,status_oW,cause_oW,epc_oW,excepttypeM,newpcM);
	
	assign bad_addrM = (exceptM[6])? pcM:
					   (adelM | adesM)? aluoutM: 32'b0;
	//writeback stage
	//assign rf_wen = {4{regwriteW && (stallreq_from_if | stallreq_from_mem) == 1'b0}};
	assign rf_wen = {4{regwriteW}};

	flopenrc #(32) r1W(clk,rst,~stallW,flushW,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~stallW,flushW,readdata2M,readdataW);
	flopenrc #(5) r3W(clk,rst,~stallW,flushW,writeregM,writeregW);
	flopenrc #(64) r4W(clk,rst,~stallW,flushW,hilo_iM,hilo_iW);
	flopenr #(32) r5W(clk,rst,~stallW,pcM,pcW);
	flopenrc #(5) r6W(clk,rst,~stallW,flushW,rdM,rdW);
	
	hilo_reg hilo(clk,rst,hilo_writeW,hilo_iW[63:32],hilo_iW[31:0],hilo_oW[63:32],hilo_oW[31:0]);
	
	//W阶段处理MTC0，M阶段处理异常
	cp0_reg CP0(
		.clk(clk),.rst(rst),.we_i(cp0weW),.waddr_i(rdW),.raddr_i(rdE),
		.data_i(aluoutW),.int_i(6'b000000),.excepttype_i(excepttypeM),
		.current_inst_addr_i(pcM),.is_in_delayslot_i(is_in_delayslotM),
		.bad_addr_i(bad_addrM),.data_o(cp0dataE),.count_o(count_oW),
		.compare_o(compare_oW),.status_o(status_oW),.cause_o(cause_oW),
		.epc_o(epc_oW),.config_o(config_oW),.prid_o(prid_oW),.badvaddr(badvaddrM));

	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
endmodule
