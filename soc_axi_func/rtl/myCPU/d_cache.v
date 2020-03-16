`timescale 1ns / 1ps

module d_cache #(parameter A_WIDTH = 32, parameter C_INDEX = 6)
(
    //CPU
    input wire clk,clrn,
    input wire[A_WIDTH-1:0] p_a,
    input wire[31:0] p_dout,
    input wire p_strobe, //en
    input wire p_rw,  //0 read 1 write
    input wire[3:0] p_wen,p_ren,
    input flush_except, //?????????cache
    output wire p_ready,
    output wire[31:0] p_din,
    //MEM
    input wire[31:0] m_dout,
    input wire m_ready,
    output wire[31:0] m_din,
    output wire[A_WIDTH-1:0] m_a,
    output wire m_strobe,
    output wire m_rw
);
localparam T_WIDTH = A_WIDTH - C_INDEX - 2;
reg [3:0] d_valid [0 : (1<<C_INDEX)-1];
reg [T_WIDTH-1:0] d_tags [0 : (1<<C_INDEX) - 1];
reg [31:0] d_data [0 : (1<<C_INDEX) - 1];
wire [C_INDEX-1:0] index = p_a[C_INDEX+1 : 2];
wire [T_WIDTH-1:0] tag = p_a[A_WIDTH-1 : C_INDEX+2];

//write to cache
integer i;
//kseg1????cache
always@(posedge clk or negedge clrn)
    if(clrn == 0) begin
        for(i = 0; i < (1<<C_INDEX); i=i+1)
            d_valid[i] <= 4'b0;
    end else if(c_write  & ~flush_except & p_a[31:16] != 16'hbfaf) begin
            d_valid[index] <= p_wen;
        end

always@(posedge clk)
    if(c_write & ~flush_except & p_a[31:16] != 16'hbfaf) begin
        d_tags[index] <= tag;
        case(p_wen)
            4'b1111: d_data[index] <= c_din; //SW
            4'b1100: d_data[index][31:16] <= c_din[31:16]; //SH
            4'b0011: d_data[index][15:0] <= c_din[15:0];
            4'b1000: d_data[index][31:24] <= c_din[31:24]; //SB
            4'b0100: d_data[index][23:16] <= c_din[23:16];
            4'b0010: d_data[index][15:8] <= c_din[15:8];
            4'b0001: d_data[index][7:0] <= c_din[7:0];
            default: d_data[index] <= d_data[index];
        endcase
    end

//read from cache
wire valid = ((d_valid[index] & p_ren) == p_ren); //d_valid should be "larger" than p_ren, 1100 & 1000 = 1000 √ 1000 & 1110 = 1000 ×
wire [T_WIDTH-1 : 0] tagout = d_tags[index];
wire [31:0] c_dout = d_data[index];

//cache control
wire cache_hit = (valid & (tagout == tag)) & ~flush_except ;//hit
wire cache_miss = ~cache_hit;
assign m_din = p_dout;
//??cache???????????????
assign m_a = (p_a[31:16] == 16'hbfaf) ? {16'h1faf,p_a[15:0]}: p_a; 
assign m_rw = p_strobe & p_rw; //write through
assign m_strobe = p_strobe & (p_rw | cache_miss);
assign p_ready = ~p_rw & cache_hit | (cache_miss | p_rw) & m_ready;
wire c_write = (p_rw | cache_miss & m_ready);
wire sel_in = p_rw;
wire sel_out = cache_hit;
wire [31:0] c_din = sel_in ? p_dout : m_dout;
assign p_din = sel_out ? c_dout :m_dout;

endmodule