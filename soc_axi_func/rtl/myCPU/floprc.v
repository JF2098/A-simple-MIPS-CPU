`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/06 20:00:46
// Design Name: 
// Module Name: floprc
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


module floprc #(parameter WIDTH = 8)(
input wire clk,rst,clr,
input wire[WIDTH-1:0] d,
output reg[WIDTH-1:0] q
    );
always @(posedge clk)
    if(rst || clr)
        q <= 0;
    else
        q <= d;


endmodule
