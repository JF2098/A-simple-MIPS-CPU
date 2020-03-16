`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/20 19:45:42
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

module exception(
	input wire rst,

    input wire cp0weW,
    input wire [4:0]waddrW,
    input wire[31:0] wdataW,

    input wire adel,ades,
	input wire[7:0] except,
	input wire[31:0] cp0_statusW,cp0_causeW,cp0_epcW,
	output wire[31:0] excepttypeM,newpcM
    );
    wire [31:0] cp0_status,cp0_cause,cp0_epc;

    assign cp0_status = (cp0weW & (waddrW == `CP0_REG_STATUS))? wdataW:
                        cp0_statusW;
    assign cp0_cause = (cp0weW & (waddrW == `CP0_REG_CAUSE))? wdataW:
                        cp0_causeW;
    assign cp0_epc = (cp0weW & (waddrW == `CP0_REG_EPC))? wdataW:
                        cp0_epcW;
	
assign excepttypeM = (rst)? 32'b0:
                    (((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) &&
				 	 (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1))? 32'h00000001: //int
                    (except[6] == 1'b1 | adel)? 32'h00000004://adel
                    (ades)? 32'h00000005://ades
                    (except[4] == 1'b1)? 32'h00000008://syscall
                    (except[3] == 1'b1)? 32'h00000009://break
                    (except[2] == 1'b1)? 32'h0000000e://eret
                    (except[1] == 1'b1)? 32'h0000000a://ri
                    (except[0] == 1'b1)? 32'h0000000c://ov
                    32'h0;

assign newpcM = (excepttypeM == 32'h00000001)? 32'hbfc00380:
                (excepttypeM == 32'h00000004)? 32'hbfc00380:
                (excepttypeM == 32'h00000005)? 32'hbfc00380:
                (excepttypeM == 32'h00000008)? 32'hbfc00380:
                (excepttypeM == 32'h00000009)? 32'hbfc00380:
                (excepttypeM == 32'h0000000a)? 32'hbfc00380:
                (excepttypeM == 32'h0000000c)? 32'hbfc00380:
                (excepttypeM == 32'h0000000e)? cp0_epc:
                32'b0;

endmodule
