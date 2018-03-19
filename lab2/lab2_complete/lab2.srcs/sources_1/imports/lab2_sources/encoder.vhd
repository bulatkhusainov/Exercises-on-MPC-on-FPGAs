LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
----------------------------------------------------------------------------------
ENTITY encoder IS
  PORT (
    clka : IN STD_LOGIC;
    y: in STD_LOGIC_VECTOR(4 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END encoder;
----------------------------------------------------------------------------------
ARCHITECTURE behavioral OF encoder IS

SIGNAL reg_address: STD_LOGIC_VECTOR(10 DOWNTO 0);
TYPE memory IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

CONSTANT digit_0: memory := (
    0 => "00000000",
    1 => "00000000",
    2 => "00111110",
    3 => "01000001",
    4 => "01000001",
    5 => "01000001",
    6 => "00111110",
    7 => "00000000");
               
CONSTANT digit_1: memory := (
    0 => "00000000",
    1 => "00000000",
    2 => "00000001",
    3 => "01111111",
    4 => "01000001",
    5 => "00000000",
    6 => "00000000",
    7 => "00000000");
    
SIGNAL oled_output:  STD_LOGIC_VECTOR(0 TO 4);

BEGIN

    douta <= "00000000" WHEN addra(10 DOWNTO 3) = "00000000" ELSE
             digit_0(to_integer(unsigned(addra(2 DOWNTO 0)))) WHEN oled_output(to_integer(unsigned(addra(10 DOWNTO 3)))-1) = '0' ELSE
             digit_1(to_integer(unsigned(addra(2 DOWNTO 0)))) WHEN oled_output(to_integer(unsigned(addra(10 DOWNTO 3)))-1) = '1' ELSE
             "00000000";
    oled_output <= y;
    
END behavioral;
----------------------------------------------------------------------------------