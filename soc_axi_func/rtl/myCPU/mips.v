`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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

module mycpu_top(
	input wire[5:0] int,
	input wire aclk,aresetn,
	
	 // axi port
    //ar
    output wire[3:0] arid,      //read request id, fixed 4'b0
    output wire[31:0] araddr,   //read request address
    output wire[7:0] arlen,     //read request transfer length(beats), fixed 4'b0
    output wire[2:0] arsize,    //read request transfer size(bytes per beats)
    output wire[1:0] arburst,   //transfer type, fixed 2'b01
    output wire[1:0] arlock,    //atomic lock, fixed 2'b0
    output wire[3:0] arcache,   //cache property, fixed 4'b0
    output wire[2:0] arprot,    //protect property, fixed 3'b0
    output wire arvalid,        //read request address valid
    input wire arready,         //slave end ready to receive address transfer
    //r              
    input wire[3:0] rid,        //equal to arid, can be ignored
    input wire[31:0] rdata,     //read data
    input wire[1:0] rresp,      //this read request finished successfully, can be ignored
    input wire rlast,           //the last beat data for this request, can be ignored
    input wire rvalid,          //read data valid
    output wire rready,         //master end ready to receive data transfer
    //aw           
    output wire[3:0] awid,      //write request id, fixed 4'b0
    output wire[31:0] awaddr,   //write request address
    output wire[3:0] awlen,     //write request transfer length(beats), fixed 4'b0
    output wire[2:0] awsize,    //write request transfer size(bytes per beats)
    output wire[1:0] awburst,   //transfer type, fixed 2'b01
    output wire[1:0] awlock,    //atomic lock, fixed 2'b01
    output wire[3:0] awcache,   //cache property, fixed 4'b01
    output wire[2:0] awprot,    //protect property, fixed 3'b01
    output wire awvalid,        //write request address valid
    input wire awready,         //slave end ready to receive address transfer
    //w          
    output wire[3:0] wid,       //equal to awid, fixed 4'b0
    output wire[31:0] wdata,    //write data
    output wire[3:0] wstrb,     //write data strobe select bit
    output wire wlast,          //the last beat data signal, fixed 1'b1
    output wire wvalid,         //write data valid
    input wire wready,          //slave end ready to receive data transfer
    //b              
    input  wire[3:0] bid,       //equal to wid,awid, can be ignored
    input  wire[1:0] bresp,     //this write request finished successfully, can be ignored
    input wire bvalid,          //write data valid
    output wire bready,          //master end ready to receive write response

	//debug signals
	output wire [31:0] debug_wb_pc,
	output wire [3 :0] debug_wb_rf_wen,
	output wire [4 :0] debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata

    );

	//sram signal
	//cpu inst sram
	wire        inst_sram_en;
	wire [3 :0] inst_sram_wen;
	wire [31:0] inst_sram_addr;
	wire [31:0] inst_sram_wdata;
	wire [31:0] inst_sram_rdata;
	//cpu data sram
	wire        data_sram_en,data_sram_write;
	wire [1 :0] data_sram_size;
	wire [3 :0] data_sram_wen;
	wire [31:0] data_sram_addr;
	wire [31:0] data_sram_wdata;
	wire [31:0] data_sram_rdata;

	// the follow definitions are between controller and datapath.
	// also use some of them  link the IPcores
	wire rst,clk;
	// fetch stage
	wire[31:0] pcF;
	wire[31:0] instrF;

	// decode stage
	wire [31:0] instrD;
	wire pcsrcD,jumpD,jalD,jrD,balD,branchD,equalD,invalidD,eretD,syscallD,breakD;
	wire [1:0] hilo_weD;
	wire stallD;
	
	// execute stage
	wire regdstE,alusrcE;
	wire memtoregE,regwriteE,jalE,balE,jrE;
	wire flushE,stallE;
	wire [7:0] alucontrolE;
	wire hilo_writeE,hilo_dstE,hilo_readE;
	wire div_validE,signed_divE;
	wire cp0readE;

	// mem stage
	wire memwriteM,memenM;
	wire[31:0] aluoutM,writedata2M;
	wire cp0weM;
	wire[31:0] readdataM;
	wire [3:0] selM,rselM;
	wire memtoregM,regwriteM;
	wire stallM,flushM;
	wire [7:0] alucontrolM;
	wire hilo_writeM,hilo_dstM;
	wire [31:0] data_sram_addr_temp;
	wire [1:0] sizeM;
	wire flush_except;
	
	// writeback stage
	wire memtoregW,regwriteW;
	wire [31:0] pcW;
	wire [4:0] writeregW;
	wire [31:0] resultW;
	wire flushW,stallW;
	wire hilo_writeW,hilo_dstW;
	wire cp0weW;
	
	

	//cache mux signal
	wire i_cache_miss,sel_i;
	wire[31:0] i_addr,d_addr,m_addr;
	wire m_fetch,m_ld_st,mem_access;
	wire mem_write,m_st;
	wire mem_ready,m_i_ready,m_d_ready,i_ready,d_ready;
	wire[31:0] mem_st_data,mem_data;
	wire[1:0] mem_size,d_size;// size not use
	wire[3:0] m_sel,d_wen;
	wire stallreq_from_if,stallreq_from_mem;
	wire [31:0] m_i_a,m_d_a;
// from_if | F E
// from_mem | All
// 

	assign clk = aclk;
	assign rst = aresetn;
	// assign the inst_sram_parameters
	assign inst_sram_en = ~flush_except;
	assign inst_sram_wen = 4'b0;
	assign inst_sram_wdata = 32'b0;
	assign inst_sram_addr = pcF;
	assign instrF = inst_sram_rdata;

	//assign the data_sram_parameters
	assign data_sram_en = memenM & ~flush_except;
	assign data_sram_write = memwriteM;
	assign data_sram_wen = selM;
	assign data_sram_size = sizeM;
	assign data_sram_addr_temp = aluoutM;
	assign data_sram_addr = data_sram_addr_temp;
	assign data_sram_wdata = writedata2M;
	assign readdataM = data_sram_rdata;

	// these modules use your own
	controller c(
		.clk(clk),.rst(~rst),
		//decode stage
			//input
		.instrD(instrD),
		.equalD(equalD),.stallD(stallD),
			//output
		.pcsrcD(pcsrcD),.branchD(branchD),
		.jumpD(jumpD),.balD(balD),.jrD(jrD),
		.jalD(jalD),.eretD(eretD),.syscallD(syscallD),
		.breakD(breakD),.invalidD(invalidD),
		//execute stage
			//input
		.flushE(flushE),.stallE(stallE),
			//output
		.memtoregE(memtoregE),.alusrcE(alusrcE),.regdstE(regdstE),.regwriteE(regwriteE),
		.hilo_writeE(hilo_writeE),.hilo_dstE(hilo_dstE),.hilo_readE(hilo_readE),
		.cp0readE(cp0readE),
		.div_validE(div_validE),.signed_divE(signed_divE),
		.jalE(jalE),.jrE(jrE),.balE(balE),
		.alucontrolE(alucontrolE),
		//mem stage
			//input
		.flushM(flushM),.stallM(stallM),
			//output
		.memtoregM(memtoregM),.regwriteM(regwriteM),.memenM(memenM),.memwriteM(memwriteM),
		.hilo_writeM(hilo_writeM),.hilo_dstM(hilo_dstM),.cp0weM(cp0weM),
		.alucontrolM(alucontrolM),
		//write back stage
			//input
		.flushW(flushW),.stallW(stallW),
			//output
		.memtoregW(memtoregW),.regwriteW(regwriteW),
		.hilo_writeW(hilo_writeW),.hilo_dstW(hilo_dstW),.cp0weW(cp0weW)
		);
	datapath dp(
		.clk(clk),.rst(~rst),
		//fetch stage
			//input
		.instrF(instrF),
			//output
		.pcF(pcF),
		//decode stage
			//input
		.pcsrcD(pcsrcD),.branchD(branchD),
		.jumpD(jumpD),.balD(balD),.jalD(jalD),.jrD(jrD),
		.eretD(eretD),.syscallD(syscallD),.breakD(breakD),.invalidD(invalidD),
			//output
		.equalD(equalD),.stallD(stallD),.instrD(instrD),
		//execute stage
			//input
		.memtoregE(memtoregE),.alusrcE(alusrcE),.regdstE(regdstE),.regwriteE(regwriteE),
		.hilo_writeE(hilo_writeE),.hilo_dstE(hilo_dstE),.hilo_readE(hilo_readE),
		.div_validE(div_validE),.signed_divE(signed_divE),
		.jalE(jalE),.jrE(jrE),.balE(balE),
		.cp0readE(cp0readE),
		.alucontrolE(alucontrolE),
			//output
		.flushE(flushE),.stallE(stallE),
		//mem stage
			//input
		.memtoregM(memtoregM),.regwriteM(regwriteM),.memenM(memenM),
		.hilo_writeM(hilo_writeM),.hilo_dstM(hilo_dstM),.cp0weM(cp0weM),
		.readdataM(readdataM),.alucontrolM(alucontrolM),
			//output
		.aluoutM(aluoutM),.writedata2M(writedata2M),
		.selM(selM),.rselM(rselM),.flushM(flushM),.stallM(stallM),
		.flush_except(flush_except),.sizeM(sizeM),
		//writeback stage
			//input
		.memtoregW(memtoregW),.regwriteW(regwriteW),
		.hilo_writeW(hilo_writeW),.hilo_dstW(hilo_dstW),.cp0weW(cp0weW),
			//output
		.flushW(flushW),.stallW(stallW),
		//debug output
		.pcW(debug_wb_pc),.rf_wen(debug_wb_rf_wen),
		.writeregW(debug_wb_rf_wnum),.resultW(debug_wb_rf_wdata),
			//input
		.stallreq_from_if(stallreq_from_if),.stallreq_from_mem(stallreq_from_mem)
	    );
	
	i_cache#(32,15) ic (
		.clk(clk),.clrn(rst),
		.p_a(inst_sram_addr), //input
		.p_din(inst_sram_rdata), //output
		.p_strobe(inst_sram_en), //input
		.p_ready(i_ready), //output
		.cache_miss(i_cache_miss), //output
		.flush_except(flush_except), //input
		
		.m_a(m_i_a), //output
		.m_dout(mem_data), //input
		.m_strobe(m_fetch), //output
		.m_ready(m_i_ready) //input
	);


	d_cache#(32,15) dc (
		.clk(clk),.clrn(rst), 
		.p_a(data_sram_addr), //input
		.p_dout(data_sram_wdata), //input
		.p_strobe(data_sram_en), //input
		.p_rw(data_sram_write), //input
		.p_wen(data_sram_wen),//input
		.p_ren(rselM), //input
		.flush_except(flush_except), //input
		.p_ready(d_ready), //output
		.p_din(data_sram_rdata), //output
		
		.m_dout(mem_data), //input
		.m_ready(m_d_ready), //input
		.m_din(mem_st_data), //output
		.m_a(m_d_a), //output
		.m_strobe(m_ld_st), //output
		.m_rw(m_st) //output
	);

	//mux, i_cache has higher priority than d_cache
	

	//use a inst_miss signal to denote that the instruction is not loadssss
	// reg inst_miss;
	// always @(posedge clk) begin
	// 	if (~aresetn) begin
	// 		inst_miss <= 1'b1;
	// 	end
	// 	if (m_i_ready & inst_miss) begin // fetch instruction ready
	// 		inst_miss <= 1'b0;
	// 	end else if (~inst_miss & data_sram_en) begin // fetch instruction ready, but need load data, so inst_miss maintain 0
	// 		inst_miss <= 1'b0;
	// 	end else if (~inst_miss & data_sram_en & m_d_ready) begin //load data ready, set inst_miss to 1
	// 		inst_miss <= 1'b1;
	// 	end else begin // other conditions, set inst_miss to 1
	// 		inst_miss <= 1'b1;
	// 	end
	// end

	// assign sel_i = inst_miss;	// use inst_miss to select access memory(for load/store) or fetch(each instruction)
	// assign d_addr = (data_sram_addr[31:16] != 16'hbfaf) ? data_sram_addr : {16'h1faf,data_sram_addr[15:0]}; // modify data address, to get the data from confreg
	// assign i_addr = inst_sram_addr;
	// assign m_addr = sel_i ? i_addr : d_addr;
	// // 
	// assign m_fetch = inst_sram_en & inst_miss; //if inst_miss equals 0, disable the fetch strobe
	// assign m_ld_st = data_sram_en;

	// assign inst_sram_rdata = mem_data;
	// assign data_sram_rdata = mem_data;
	// assign mem_st_data = data_sram_wdata;
	//use select signal
	assign sel_i = i_cache_miss;
	assign m_addr = sel_i ? m_i_a : m_d_a;
	assign mem_access = sel_i ? m_fetch : m_ld_st; 
	assign mem_size = sel_i ? 2'b10 : data_sram_size;
	assign m_sel = sel_i ? 4'b1111 : data_sram_wen;
	assign mem_write = sel_i ? 1'b0 : data_sram_write;

	//demux
	assign m_i_ready = mem_ready & sel_i;
	assign m_d_ready = mem_ready & ~sel_i;

	//
	assign stallreq_from_if = ~i_ready;
	assign stallreq_from_mem = data_sram_en & ~d_ready;

	axi_interface interface(
		.clk(aclk),
		.resetn(aresetn),
		
		 //cache/cpu_core port
		.mem_a(m_addr),
		.mem_access(mem_access),
		.mem_write(mem_write),
		.mem_size(mem_size),
		.mem_sel(m_sel),
		.mem_ready(mem_ready),
		.mem_st_data(mem_st_data),
		.mem_data(mem_data),
		// add a input signal 'flush', cancel the memory accessing operation in axi_interface, do not need any extra design. 
		.flush(flush_except), // use excepetion type

		.arid      (arid      ),
		.araddr    (araddr    ),
		.arlen     (arlen     ),
		.arsize    (arsize    ),
		.arburst   (arburst   ),
		.arlock    (arlock    ),
		.arcache   (arcache   ),
		.arprot    (arprot    ),
		.arvalid   (arvalid   ),
		.arready   (arready   ),
					
		.rid       (rid       ),
		.rdata     (rdata     ),
		.rresp     (rresp     ),
		.rlast     (rlast     ),
		.rvalid    (rvalid    ),
		.rready    (rready    ),
				
		.awid      (awid      ),
		.awaddr    (awaddr    ),
		.awlen     (awlen     ),
		.awsize    (awsize    ),
		.awburst   (awburst   ),
		.awlock    (awlock    ),
		.awcache   (awcache   ),
		.awprot    (awprot    ),
		.awvalid   (awvalid   ),
		.awready   (awready   ),
		
		.wid       (wid       ),
		.wdata     (wdata     ),
		.wstrb     (wstrb     ),
		.wlast     (wlast     ),
		.wvalid    (wvalid    ),
		.wready    (wready    ),
		
		.bid       (bid       ),
		.bresp     (bresp     ),
		.bvalid    (bvalid    ),
		.bready    (bready    )
	);
endmodule
