-- This code was modifeid for TEMPO Summer School, July 17-21, 2017
-- Hardware Implementation of Embedded Optimisation 
----------------------------------------------------------------------------------
-- Company: Digilent Inc.
-- Engineer: Ryan Kim
-- 
-- Create Date:    16:48:30 10/10/2011 
-- Module Name:    Delay - Behavioral 
-- Project Name:   PmodOled Demo
-- Tool versions:  ISE 13.2
-- Description:    Creates a delay of DELAY_MS ms
--
-- Revision: 1.0
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY delay IS
    PORT ( clk 			: IN  STD_LOGIC; --System CLK
			rst 		: IN STD_LOGIC;  --Global RST (Synchronous)
			delay_ms 	: IN  STD_LOGIC_VECTOR (11 DOWNTO 0); --Amount of ms to delay
			delay_en 	: IN  STD_LOGIC; --Delay block enable
			delay_fin 	: OUT  STD_LOGIC); --Delay finish flag
END delay;

ARCHITECTURE behavioral OF delay IS

TYPE states IS (idle,
				hold,
				done);
					
SIGNAL current_state : states := idle; --Signal for state machine
SIGNAL clk_counter : STD_LOGIC_VECTOR(16 DOWNTO 0) := (OTHERS => '0'); --Counts up on every rising edge of CLK
SIGNAL ms_counter : STD_LOGIC_VECTOR (11 DOWNTO 0) := (OTHERS => '0'); --Counts up when clk_counter = 100,000

BEGIN
	--DELAY_FIN goes HIGH when delay is done
	delay_fin <= '1' WHEN (current_state = Done AND DELAY_EN = '1') ELSE
					'0';
					
	--State machine for Delay block
	state_machine : PROCESS (clk)
	BEGIN
		IF(rising_edge(clk)) THEN
			IF(rst = '1') THEN --When RST is asserted switch to idle (synchronous)
				current_state <= idle;
			ELSE
				CASE (current_state) IS
					WHEN Idle =>
						IF(DELAY_EN = '1') THEN --Start delay on DELAY_EN
							current_state <= Hold;
						END IF;
					WHEN Hold =>
						IF( ms_counter = delay_ms) THEN --stay until DELAY_MS has occured
							current_state <= done;
						END IF;
					WHEN done =>
						IF(delay_en = '0') THEN --Wait til DELAY_EN is deasserted to go to IDLE
							current_state <= Idle;
						END IF;
					WHEN OTHERS =>
						current_state <= Idle;
				END CASE;
			END IF;
		END IF;
	end PROCESS;
	
	
	--Creates ms_counter that counts at 1KHz
	clk_div : PROCESS (clk)
	BEGIN
		IF(clk'EVENT AND clk = '1') THEN
			IF (current_state = Hold) THEN
				IF(clk_counter = "11000011010100000") THEN --100,000 
					clk_counter <= (OTHERS => '0');
					ms_counter <= ms_counter + 1; --increments at 1KHz
				ELSE
					clk_counter <= clk_counter + 1;
				END IF;
			ELSE --If not in the hold state reset counters
				clk_counter <= (OTHERS => '0');
				ms_counter <= (OTHERS => '0');
			END IF;
		END IF;
	END PROCESS;

end behavioral;

