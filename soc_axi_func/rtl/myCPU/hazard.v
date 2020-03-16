`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/06 20:44:24
// Design Name: 
// Module Name: hazard
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


module hazard(
    output stallF,flushF,
    //Decode
    input [4:0]rsD, rtD, 
    input branchD,jumpD,jrD,
    input balD,jalD,
    output [1:0]forwardaD, forwardbD,
    output stallD,
    output flushD,
    //Execute
    input [4:0]rsE,rtE,rdE,
    input [4:0]writeregE, 
    input regwriteE, memtoregE,
    input hilo_readE,hilo_dstE,
    input div_stallE,pcsrcD,
    input cp0readE,
    output [1:0]forwardaE,forwardbE,
    output [1:0]forwardhiloE,
    output stallE,
    output flushE,
    output [1:0]forwardcp0E,
    //Memory
    input [4:0]writeregM, 
    input regwriteM, memtoregM,
    input hilo_writeM,hilo_dstM,
    input cp0weM,
    input [4:0]rdM,
    output flushM,stallM,
    input [31:0] excepttypeM,
    //Write back
    input [4:0]writeregW, 
    input regwriteW,
    input hilo_writeW,hilo_dstW,
    input [4:0] rdW,
    input cp0weW,
    
    output flushW,stallW,
    //
    input stallreq_from_if, stallreq_from_mem,
    output flush_except
    );

wire lwstall, branchstall, jrstall, flush_except;

assign forwardaE = ((rsE != 0) & (rsE == writeregM) & regwriteM)? 2'b10:
             ((rsE != 0) & (rsE == writeregW) & regwriteW)? 2'b01:
             2'b00;

assign forwardbE = ((rtE != 0) & (rtE == writeregM) & regwriteM)? 2'b10:
             ((rtE != 0) & (rtE == writeregW) & regwriteW)? 2'b01:
             2'b00;

assign forwardhiloE = ((hilo_readE != 0) && hilo_writeM)? 2'b10:
             ((hilo_readE != 0) && hilo_writeW)? 2'b01:
             2'b00;

assign forwardcp0E = ((cp0readE != 0) && cp0weM && rdM == rdE)? 2'b10:
             ((cp0readE != 0) && cp0weW && rdW == rdE)? 2'b01:
             2'b00;

assign lwstall = ((rsD == rtE) | (rtD == rtE)) & memtoregE;
assign stallF = lwstall | branchstall | div_stallE | jrstall | stallreq_from_if | stallreq_from_mem;
assign stallD = stallF;
assign stallE = div_stallE | stallreq_from_mem;
assign stallM = stallreq_from_mem;
assign stallW = 0;


assign flushF = flush_except;
assign flushD = flush_except;
assign flushE = lwstall | branchstall | jumpD | flush_except;
assign flushM = flush_except;
assign flushW = flush_except | stallreq_from_mem;
assign flush_except = (|excepttypeM);

assign forwardaD = (rsD != 0) & (rsD == writeregM) & regwriteM;
assign forwardbD = (rtD != 0) & (rtD == writeregM) & regwriteM;

assign branchstall = (branchD & regwriteE &
        ((writeregE == rsD) | (writeregE == rtD)))
        | (branchD & memtoregM &
        ((writeregM == rsD) | (writeregM == rtD)));

assign jrstall = (jumpD & jrD & regwriteE &
        ((writeregE == rsD) | (writeregE == rtD))) 
        | (jumpD & jrD & memtoregM &
        ((writeregM == rsD) | (writeregM == rtD)));

endmodule
