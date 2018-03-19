-- This code was modifeid for TEMPO Summer School, July 17-21, 2017
-- Hardware Implementation of Embedded Optimisation 
----------------------------------------------------------------------------------
-- Company: Digilent INc.
-- EngINeer: Ryan Kim
-- 
-- Create Date:    14:35:33 10/10/2011 
-- Module Name:    PmodOLEDCtrl - Behavioral 
-- Project Name:   PmodOLED Demo
-- Tool versions:  ISE 13.2
-- Description:    Top level controller that controls the PmodOLED blocks
--
-- Revision: 1.1
-- Revision 0.01 - File Created
-- Revision 0.02 - ModIFied alightly to adapt to the Zynq board, Nov. 5, 2012 
--                 By Farhad Abdolian (fabdolian@seemaconsultINg.com)
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity top_level_circuit IS
	PORT ( 
		CLK 	: IN  STD_LOGIC;
		RST 	: IN	STD_LOGIC;
		SWITCH_B: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
-- Removed the CS sINce the Zynq board does not have the CS rOUTed to the FPGA.		
--		CS  	: OUT STD_LOGIC;
		SDIN	: OUT STD_LOGIC;
		SCLK	: OUT STD_LOGIC;
		DC		: OUT STD_LOGIC;
		RES	: OUT STD_LOGIC;
		VBAT	: OUT STD_LOGIC;
		VDD	: OUT STD_LOGIC);
END top_level_circuit;

architecture Behavioral of top_level_circuit IS

--decalre lab2 (adder) COMPONENT
COMPONENT lab2
    PORT (
        x_1 : IN STD_LOGIC_VECTOR (3 downto 0);
        x_2 : IN STD_LOGIC_VECTOR (3 downto 0);
        y   : OUT STD_LOGIC_VECTOR (4 downto 0);
        clk : IN STD_LOGIC);
END COMPONENT;


COMPONENT oled_init IS
PORT ( 
        CLK 	: IN  STD_LOGIC;
		RST 	: IN	STD_LOGIC;
		EN		: IN  STD_LOGIC;
		CS  	: OUT STD_LOGIC;
		SDO	: OUT STD_LOGIC;
		SCLK	: OUT STD_LOGIC;
		DC		: OUT STD_LOGIC;
		RES	: OUT STD_LOGIC;
		VBAT	: OUT STD_LOGIC;
		VDD	: OUT STD_LOGIC;
		FIN  : OUT STD_LOGIC);
END COMPONENT;

COMPONENT oled_print IS
    PORT ( 
        CLK 	: IN  STD_LOGIC;
		RST 	: IN	STD_LOGIC;
		SWITCH_B: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		EN		: IN  STD_LOGIC;
		CS  	: OUT STD_LOGIC;
		SDO		: OUT STD_LOGIC;
		SCLK	: OUT STD_LOGIC;
		DC		: OUT STD_LOGIC;
		FIN  : OUT STD_LOGIC);
END COMPONENT;

type states IS (Idle,
					Oledinitialize,
					OledExample,
					Done);

SIGNAL current_state 	: states := Idle;

SIGNAL init_en				: STD_LOGIC := '0';
SIGNAL init_done			: STD_LOGIC;
SIGNAL init_cs				: STD_LOGIC;
SIGNAL init_sdo			    : STD_LOGIC;
SIGNAL init_sclk			: STD_LOGIC;
SIGNAL init_dc				: STD_LOGIC;

SIGNAL example_en			: STD_LOGIC := '0';
SIGNAL example_cs			: STD_LOGIC;
SIGNAL example_sdo		    : STD_LOGIC;
SIGNAL example_sclk		    : STD_LOGIC;
SIGNAL example_dc			: STD_LOGIC;
SIGNAL example_done		    : STD_LOGIC;

-- Since we do not have a CS on the Synq board, we have to have this temp SIGNAL to make 
-- it work with minimum amout of modIFication of the desgin. /Farhad Abdolian Nov. 5, 2012
SIGNAL CS				   : STD_LOGIC;

SIGNAL y : STD_LOGIC_VECTOR(4 DOWNTO 0);


begin 
    adder: lab2 PORT MAP (SWITCH_B(7 DOWNTO 4), SWITCH_B(3 DOWNTO 0), y, CLK);
	init: oled_init PORT map(CLK, RST, init_en, init_cs, init_sdo, init_sclk, init_dc, RES, VBAT, VDD, init_done);
	print: oled_print PORT map(CLK, RST, y, example_en, example_cs, example_sdo, example_sclk, example_dc, example_done);
	
	--MUXes to indicate which OUTputs are routed out depENDing on which block IS enabled
	CS <= init_cs WHEN (current_state = Oledinitialize) ELSE
			example_cs;
	SDin <= init_sdo WHEN (current_state = Oledinitialize) ELSE
			example_sdo;
	SCLK <= init_sclk WHEN (current_state = Oledinitialize) ELSE
			example_sclk;
	DC <= init_dc WHEN (current_state = Oledinitialize) ELSE
			example_dc;
	--END output MUXes
	
	--MUXes that enable blocks WHEN in the proper states
	init_en <= '1' WHEN (current_state = Oledinitialize) ELSE
					'0';
	example_en <= '1' WHEN (current_state = OledExample) ELSE
					'0';
	--END enable MUXes
	
	PROCESS(CLK)
	begin
		IF(rising_edge(CLK)) THEN
			IF(RST = '1') THEN
				current_state <= Idle;
			ELSE
				CASE(current_state) IS
					WHEN Idle =>
						current_state <= Oledinitialize;
					--Go through the initialization sequence
					WHEN Oledinitialize =>
						IF(init_done = '1') THEN
							current_state <= OledExample;
						END IF;
					--Do example and Do nothing WHEN finished
					WHEN OledExample =>
						IF(example_done = '1') THEN
							current_state <= Done;
						END IF;
					--Do Nothing
					WHEN Done =>
						current_state <= Done;
					WHEN OTHERS =>
						current_state <= Idle;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	
END Behavioral;

