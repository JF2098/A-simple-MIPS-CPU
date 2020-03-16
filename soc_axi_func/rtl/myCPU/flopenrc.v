`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/06 20:00:06
// Design Name: 
// Module Name: flopenrc
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


module flopenrc #(parameter WIDTH = 8)(
input wire clk,rst,en,clr,
input wire[WIDTH-1:0] d,
output reg[WIDTH-1:0] q
    );
always @(posedge clk) 
    if(rst || clr)
        q <= 0;
    else if(en)
        q <= d;
    else
        q <= q;
    
endmodule
