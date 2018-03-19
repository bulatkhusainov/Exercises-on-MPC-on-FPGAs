-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.2 (lin64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
-- Date        : Mon Apr  3 17:42:46 2017
-- Host        : bkhusain-HP-Z420-Workstation running 64-bit Ubuntu 14.04.5 LTS
-- Command     : write_vhdl -mode funcsim -nolib -force -file
--               /home/bkhusain/hdrive/bulat_documents/events_conferences/Slovakia_summer_school/lab1/lab1_complete/lab1_complete.sim/sim_1/impl/func/lab1_tb_func_impl.vhd
-- Design      : lab1
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity lab1 is
  port (
    input : in STD_LOGIC_VECTOR ( 1 downto 0 );
    output : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of lab1 : entity is true;
  attribute ECO_CHECKSUM : string;
  attribute ECO_CHECKSUM of lab1 : entity is "8c74bdbb";
end lab1;

architecture STRUCTURE of lab1 is
  signal \output[1]_INST_0_i_2_n_0\ : STD_LOGIC;
  signal output_OBUF : STD_LOGIC_VECTOR ( 1 downto 0 );
begin
\output[0]_INST_0\: unisim.vcomponents.OBUF
     port map (
      I => output_OBUF(0),
      O => output(0)
    );
\output[0]_INST_0_i_1\: unisim.vcomponents.IBUF
     port map (
      I => input(0),
      O => output_OBUF(0)
    );
\output[1]_INST_0\: unisim.vcomponents.OBUF
     port map (
      I => output_OBUF(1),
      O => output(1)
    );
\output[1]_INST_0_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \output[1]_INST_0_i_2_n_0\,
      O => output_OBUF(1)
    );
\output[1]_INST_0_i_2\: unisim.vcomponents.IBUF
     port map (
      I => input(1),
      O => \output[1]_INST_0_i_2_n_0\
    );
end STRUCTURE;
