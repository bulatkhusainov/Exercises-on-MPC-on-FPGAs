---------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_Std.all;

---------------------------------------
ENTITY lab1_tb IS
END;
---------------------------------------
ARCHITECTURE bench OF lab1_tb IS

  COMPONENT lab1
      PORT (  
              input:    IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        output:   OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
  END COMPONENT;

  SIGNAL input: STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL output: STD_LOGIC_VECTOR (1 DOWNTO 0);


BEGIN

  uut: lab1 PORT MAP ( input  => input,
                       output => output );

  stimulus: PROCESS
  BEGIN
  
    -- Put initialisation code here
    input <= "00";
    WAIT FOR 100 NS;
    input <= "01";
    WAIT FOR 100 NS;
    input <= "10";
    WAIT FOR 100 NS;
    input <= "11";
    WAIT FOR 100 NS;

    -- Put test bench stimulus code here

    WAIT;
  END PROCESS;


END;