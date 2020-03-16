`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/06 19:55:49
// Design Name: 
// Module Name: flopr
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


module flopr #(parameter WIDTH = 8)(
input wire clk,rst,
input wire[WIDTH-1:0] d,
output reg[WIDTH-1:0] q
    );
always @(posedge clk) 
    if(rst)
        q <= 0;
    else
        q <= d;
    
endmodule
