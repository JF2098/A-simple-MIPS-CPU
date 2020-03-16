`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/15 19:42:03
// Design Name: 
// Module Name: pc
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


module pc(
input clk, rst,
input [31:0] newaddr,
output reg [31:0] addr,
output reg inst_ce
);
always @(posedge clk) 
    if(rst)
        addr <= 32'hfffffffc;
    else
        addr <= newaddr;

always @(posedge clk)
    if(rst)
        inst_ce <= 0;
    else
        inst_ce <= 1;
endmodule
