`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/06 23:55:54
// Design Name: 
// Module Name: pcfolpenr
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

module pcflopenrc #(parameter WIDTH = 8)(
input wire clk,rst,en,flush,
input wire[WIDTH-1:0] d,
input wire[WIDTH-1:0] newpc,
output reg[WIDTH-1:0] q
    );

initial begin
    q<=32'hbfc00000;
end

always @(posedge clk) begin
    if(rst)
        q <= 32'hbfc00000;
    else if(flush)
        q <= newpc;
    else if(en)
        q <= d;
    else
        q <= q;
end
endmodule
