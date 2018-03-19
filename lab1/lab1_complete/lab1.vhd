---------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
---------------------------------------
ENTITY lab1 IS
    PORT ( 	
            input:    IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
			output:   OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
END lab1;
---------------------------------------
ARCHITECTURE behavioral OF lab1 IS

BEGIN
    output(0) <= input(0);
    output(1) <= NOT input(1);	
END behavioral;
---------------------------------------