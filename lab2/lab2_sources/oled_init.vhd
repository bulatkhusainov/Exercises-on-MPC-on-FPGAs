-- This code was modifeid for TEMPO Summer School, July 17-21, 2017
-- Hardware Implementation of Embedded Optimisation 
----------------------------------------------------------------------------------
-- Company: Digilent Inc.
-- Engineer: Ryan Kim
-- 
-- Create Date:    16:05:03 10/10/2011
-- Module Name:    OledInit - Behavioral 
-- Project Name:   PmodOLED Demo
-- Tool versions:  ISE 13.2
-- Description:    Runs the initialization sequence for the PmodOLED
--
-- RevISion: 1.2
-- RevISion 0.01 - File Created
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_unsigned.ALL;

ENTITY oled_init IS
    PORT ( clk 	: IN  STD_LOGIC; --System Clock
		rst 	: IN	STD_LOGIC;		--Global Synchronous Reset
		en		: IN  STD_LOGIC;		--Block enable pin
		cs  	: OUT STD_LOGIC;		--SPI Chip Select
		sdo	: OUT STD_LOGIC;		--SPI data out
		sclk	: OUT STD_LOGIC;		--SPI Clock
		dc		: OUT STD_LOGIC;		--Data/Command Pin
		res	: OUT STD_LOGIC;		--PmodOLED RES
		vbat	: OUT STD_LOGIC;		--VBAT enable
		vdd	: OUT STD_LOGIC;		--VDD enable
		fin  : OUT STD_LOGIC);		--OledInit FinISh Flag
END oled_init;

ARCHITECTURE behavioral OF oled_init IS

COMPONENT spi_ctrl
    PORT(
         clk : IN  STD_LOGIC;
         rst : IN  STD_LOGIC;
         spi_en : IN  STD_LOGIC;
         spi_data : IN  STD_LOGIC_vector(7 DOWNTO 0);
         cs : OUT  STD_LOGIC;
         sdo : OUT  STD_LOGIC;
         sclk : OUT  STD_LOGIC;
         spi_fin : OUT  STD_LOGIC
        );
    END COMPONENT;

COMPONENT delay
    PORT(
         clk : IN  STD_LOGIC;
         rst : IN  STD_LOGIC;
         delay_ms : IN  STD_LOGIC_vector(11 DOWNTO 0);
         delay_en : IN  STD_LOGIC;
         delay_fin : OUT  STD_LOGIC
        );
    END COMPONENT;

TYPE states IS (transition1,
					transition2,
					transition3,
					transition4,
					transition5,
					idle,
					vddon,
					wait1,
					dispoff,
					reseton,
					wait2,
					resetoff,
					chargepump1,
					chargepump2,
					precharge1,
					precharge2,
					vbaton,
					wait3,
					dispcontrast1,
					dispcontrast2,
					invertdisp1,
					invertdisp2,
					comconfig1,
					comconfig2,
					dispon,
					fulldisp,
					done
					);
					
SIGNAL current_state : states := idle;
SIGNAL after_state : states := idle;

SIGNAL temp_dc : STD_LOGIC := '0';
SIGNAL temp_res : STD_LOGIC := '1';
SIGNAL temp_vbat : STD_LOGIC := '1';
SIGNAL temp_vdd : STD_LOGIC := '1';
SIGNAL temp_fin : STD_LOGIC := '0';

SIGNAL temp_delay_ms : STD_LOGIC_VECTOR (11 DOWNTO 0) := (others => '0');
SIGNAL temp_delay_en : STD_LOGIC := '0';
SIGNAL temp_delay_fin : STD_LOGIC;
SIGNAL temp_spi_en : STD_LOGIC := '0';
SIGNAL temp_spi_data : STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
SIGNAL temp_spi_fin : STD_LOGIC;

BEGIN

 spi_comp: spi_ctrl PORT MAP (
          clk => clk,
          rst => rst,
          spi_en => temp_spi_en,
          spi_data => temp_spi_data,
          cs => cs,
          sdo => sdo,
          sclk => sclk,
          spi_fin => temp_spi_fin
        );
		  
   delay_comp: Delay PORT MAP (
          clk => clk,
          rst => rst,
          delay_ms => temp_delay_ms,
          delay_en => temp_delay_en,
          delay_fin => temp_delay_fin
        );
		  
dc <= temp_dc;
res <= temp_res;
vbat <= temp_vbat;
vdd <= temp_vdd;
fin <= temp_fin;

--Delay 100 ms after VbatOn
temp_delay_ms <= "000001100100" WHEN (after_state = DISpContrast1) ELSE --100 ms
				 "000000000001"; --1ms
	
	STATE_MACHINE : PROCESS (CLK)
	BEGIN
		IF(rISing_edge(CLK)) then
			IF(RST = '1') then
				current_state <= Idle;
				temp_res <= '0';
			ELSE
				temp_res <= '1';
				CASE (current_state) IS
					WHEN Idle 			=>
						IF(EN = '1') then
							temp_dc <= '0';
							current_state <= VddOn;
						END IF;
						
					--Initialization Sequence
					--ThIS should be done everytime the PmodOLED IS started
					WHEN VddOn 			=>
						temp_vdd <= '0';
						current_state <= Wait1;
					WHEN Wait1 			=>	
						after_state <= DISpOff;
						current_state <= Transition3;
					WHEN DISpOff 		=>
						temp_spi_data <= "10101110"; --0xAE
						after_state <= ResetOn;
						current_state <= Transition1;
					WHEN ResetOn		=>
						temp_res <= '0';
						current_state <= Wait2;
					WHEN Wait2			=>
						after_state <= ResetOff;
						current_state <= Transition3;
					WHEN ResetOff		=>
						temp_res <= '1';
						after_state <= ChargePump1;
						current_state <= Transition3;
					WHEN ChargePump1	=>
						temp_spi_data <= "10001101"; --0x8D
						after_state <= ChargePump2;
						current_state <= Transition1;
					WHEN ChargePump2 	=>
						temp_spi_data <= "00010100"; --0x14
						after_state <= PreCharge1;
						current_state <= Transition1;
					WHEN PreCharge1	=>
						temp_spi_data <= "11011001"; --0xD9
						after_state <= PreCharge2;
						current_state <= Transition1;
					WHEN PreCharge2	=>
						temp_spi_data <= "11110001"; --0xF1
						after_state <= VbatOn;
						current_state <= Transition1;
					WHEN VbatOn			=>
						temp_vbat <= '0';
						current_state <= Wait3;
					WHEN Wait3			=>
						after_state <= DISpContrast1;
						current_state <= Transition3;
					WHEN DISpContrast1=>
						temp_spi_data <= "10000001"; --0x81
						after_state <= DISpContrast2;
						current_state <= Transition1;
					WHEN DISpContrast2=>
						temp_spi_data <= "00001111"; --0x0F
						after_state <= InvertDISp1;
						current_state <= Transition1;
					WHEN InvertDISp1	=>
						temp_spi_data <= "10100001"; --0xA1
						after_state <= InvertDISp2;
						current_state <= Transition1;
					WHEN InvertDISp2 =>
						temp_spi_data <= "11001000"; --0xC8
						after_state <= ComConfig1;
						current_state <= Transition1;
					WHEN ComConfig1	=>
						temp_spi_data <= "11011010"; --0xDA
						after_state <= ComConfig2;
						current_state <= Transition1;
					WHEN ComConfig2 	=>
						temp_spi_data <= "00100000"; --0x20
						after_state <= DISpOn;
						current_state <= Transition1;
					WHEN DISpOn			=>
						temp_spi_data <= "10101111"; --0xAF
						after_state <= Done;
						current_state <= Transition1;
					--END Initialization sequence	
					
					--Used for debugging, ThIS command turns the entire screen on regardless of memory
					WHEN FullDISp		=>
						temp_spi_data <= "10100101"; --0xA5
						after_state <= Done;
						current_state <= Transition1;
						
					--Done state
					WHEN Done			=>
						IF(EN = '0') then
							temp_fin <= '0';
							current_state <= Idle;
						ELSE
							temp_fin <= '1';
						END IF;
						
					--SPI transitions
					--1. Set SPI_EN to 1
					--2. Waits for SpiCtrl to finISh
					--3. Goes to clear state (Transition5)	
					WHEN Transition1 =>
						temp_spi_en <= '1';
						current_state <= Transition2;
					WHEN Transition2 =>
						IF(temp_spi_fin = '1') then
							current_state <= Transition5;
						END IF;
						
					--Delay Transitions
					--1. Set DELAY_EN to 1
					--2. Waits for Delay to finISh
					--3. Goes to Clear state (Transition5)	
					WHEN Transition3 =>
						temp_delay_en <= '1';
						current_state <= Transition4;
					WHEN Transition4 =>
						IF(temp_delay_fin = '1') then
							current_state <= Transition5;
						END IF;
						
					--Clear transition
					--1. Sets both DELAY_EN and SPI_EN to 0
					--2. Go to after state	
					WHEN Transition5 =>
						temp_spi_en <= '0';
						temp_delay_en <= '0';
						current_state <= after_state;
					--END SPI transitions
					--END Delay Transitions
					--END Clear transition	
						
					WHEN others 		=>
						current_state <= Idle;
				END CASE;
			END IF;
		END IF;
	END PROCESS;

END behavioral;

