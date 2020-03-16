`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/25 10:15:51
// Design Name: 
// Module Name: sl2
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


module sl2 (input [31:0] a,
            output [31:0] y);
    // shift left by 2
    assign y = {a[29:0], 2'b00};
endmodule
