----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
----------------------------------------------------------------------------------
ENTITY lab2 IS
    PORT ( x_1 : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
           x_2 : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
           y   : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
           clk : IN  STD_LOGIC);
END lab2;
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF lab2 IS

BEGIN

    PROCESS (clk)
    BEGIN
        IF(clk'EVENT AND clk='1') THEN
            y <= STD_LOGIC_VECTOR(UNSIGNED('0' & x_1) + UNSIGNED('0' & x_2));
         END IF;
    END PROCESS;
end Behavioral;
----------------------------------------------------------------------------------