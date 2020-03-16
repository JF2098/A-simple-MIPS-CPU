`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/22 20:16:59
// Design Name: 
// Module Name: mux
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


module mux2
#(parameter N=32)
(
    input [N-1:0] ina, inb,
    input s,
    output [N-1:0] out
);
assign out = (s == 1'b0)?ina :
             (s == 1'b1)?inb :
             32'h00000000;
endmodule
