-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Sun Dec 22 10:35:20 2019
-- Host        : DESKTOP-ANR2QHA running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {D:/OneDrive -
--               cqu.edu.cn/Source/Vivado/func_test_v0.03/soc_axi_func/rtl/xilinx_ip/clk_pll/clk_pll_stub.vhdl}
-- Design      : clk_pll
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg676-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_pll is
  Port ( 
    cpu_clk : out STD_LOGIC;
    sys_clk : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end clk_pll;

architecture stub of clk_pll is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "cpu_clk,sys_clk,clk_in1";
begin
end;
