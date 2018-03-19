-- This code was modifeid for TEMPO Summer School, July 17-21, 2017
-- Hardware Implementation of Embedded Optimisation 
----------------------------------------------------------------------------------
-- Company: Digilent inc.
-- Engineer: Ryan Kim
-- 
-- Create Date:    11:50:03 10/24/2011 
-- Module Name:    OledExample - Behavioral 
-- Project Name: 	 PmodOLED Demo
-- Tool versions:  ISE 13.2
-- Description: Demo for the PmodOLED.  First dISplays the alphabet for ~4 seconds and THEN
--				Clears the dISplay, waits for a ~1 second and THEN dISplays "ThIS IS Digilent's
--				PmodOLED"
--
-- RevISion: 1.2
-- RevISion 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

entity oled_print IS
    PORT ( CLK 	: IN  STD_LOGIC; --System CLK
			  RST 	: IN	STD_LOGIC; --Synchronous Reset
			  SWITCH_B: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			  EN		: IN  STD_LOGIC; --Example block enable pIN
			  CS  	: OUT STD_LOGIC; --SPI Chip Select
			  SDO		: OUT STD_LOGIC; --SPI Data OUT
			  SCLK	: OUT STD_LOGIC; --SPI Clock
			  DC		: OUT STD_LOGIC; --Data/Command Controller
			  FIN  	: OUT STD_LOGIC);--FINISh flag for example block
END oled_print;

architecture Behavioral of oled_print IS

--SPI Controller Component
COMPONENT spi_ctrl
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         SPI_EN : IN  std_logic;
         SPI_DATA : IN  std_logic_vector(7 DOWNTO 0);
         CS : OUT  std_logic;
         SDO : OUT  std_logic;
         SCLK : OUT  std_logic;
         SPI_FIN : OUT  std_logic
        );
    END COMPONENT;

--Delay Controller Component
COMPONENT Delay
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         DELAY_MS : IN  std_logic_vector(11 DOWNTO 0);
         DELAY_EN : IN  std_logic;
         DELAY_FIN : OUT  std_logic
        );
    END COMPONENT;
	 
--Character Library, Latency = 1
COMPONENT encoder
  PORT (
    clka : IN STD_LOGIC; --Attach System Clock to it
    y: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --First 8 bits IS the ASCII value of the character the last 3 bits are the parts of the char
    dOUTa : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Data byte OUT
  );
END COMPONENT;

--States for state machine
TYPE states IS (Idle,
				ClearDC,
				SetPage,
				PageNum,
				LeftColumn1,
				LeftColumn2,
				SetDC,
				Alphabet,
				Wait1,
				ClearScreen,
				Wait2,
				DigilentScreen,
				UpdateScreen,
				SENDChar1,
				SENDChar2,
				SENDChar3,
				SENDChar4,
				SENDChar5,
				SENDChar6,
				SENDChar7,
				SENDChar8,
				ReadMem,
				ReadMem2,
				Done,
				Transition1,
				Transition2,
				Transition3,
				Transition4,
				Transition5
					);
TYPE OledMem IS ARRAY(0 to 3, 0 to 15) of STD_LOGIC_VECTOR(7 DOWNTO 0);

--Variable that contains what the screen will be after the next UpdateScreen state
SIGNAL current_screen : OledMem; 
--CONSTANT that contains the screen filled with the Alphabet and numbers
CONSTANT alphabet_screen : OledMem :=((X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00"),
												(X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00"),
												(X"00",X"00",X"00",X"00",X"00",X"00",X"05",X"04",X"03",X"02",X"01",X"00",X"00",X"00",X"00",X"00"),
												(X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00"));
--CONSTANT that fills the screen with blank (spaces) entries
CONSTANT clear_screen : OledMem :=   ((X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"),	
												(X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"),
												(X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"),
												(X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"));
--CONSTANT that holds "This is Digilent's PmodOLED"
CONSTANT digilent_screen : OledMem:= ((X"54",X"68",X"69",X"73",X"20",X"69",X"73",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"),
												(X"44",X"69",X"67",X"69",X"6C",X"65",X"6E",X"74",X"27",X"73",X"20",X"20",X"20",X"20",X"20",X"20"),
												(X"50",X"6D",X"6F",X"64",X"4F",X"4C",X"45",X"44",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"),
												(X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20"));
--Current overall state of the state machine
SIGNAL current_state : states := Idle;
--State to go to after the SPI transmission is finished
SIGNAL after_state : states;
--State to go to after the set page sequence
SIGNAL after_page_state : states;
--State to go to after souting the character sequence
SIGNAL after_char_state : states;
--State to go to after the UpdateScreen is finished
SIGNAL after_update_state : states;

--Contains the value to be OUTputted to DC
SIGNAL temp_dc : STD_LOGIC := '0';

--Variables used in the Delay Controller Block
SIGNAL temp_delay_ms : STD_LOGIC_VECTOR (11 DOWNTO 0); --amount of ms to delay
SIGNAL temp_delay_en : STD_LOGIC := '0'; --Enable SIGNAL for the delay block
SIGNAL temp_delay_fIN : STD_LOGIC; --FINish SIGNAL for the delay block

--Variables used IN the SPI controller block
SIGNAL temp_spi_en : STD_LOGIC := '0'; --Enable SIGNAL for the SPI block
SIGNAL temp_spi_data : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0'); --Data to be sent OUT on SPI
SIGNAL temp_spi_fin : STD_LOGIC; --FINish SIGNAL for the SPI block

SIGNAL temp_char : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0'); --Contains ASCII value for character
SIGNAL temp_addr : STD_LOGIC_VECTOR (10 DOWNTO 0) := (OTHERS => '0'); --Contains address to BYTE needed in memory
SIGNAL temp_dOUT : STD_LOGIC_VECTOR (7 DOWNTO 0); --Contains byte OUTputted from memory
SIGNAL temp_page : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0'); --Current page
SIGNAL temp_index : integer range 0 to 15 := 0; --Current character on page

BEGIN
DC <= temp_dc;
--Example finish flag only high WHEN IN done state
FIN <= '1' WHEN (current_state = Done) ELSE
					'0';
--instantiate SPI Block
 SPI_COMP: spi_ctrl PORT MAP (
          CLK => CLK,
          RST => RST,
          SPI_EN => temp_spi_en,
          SPI_DATA => temp_spi_data,
          CS => CS,
          SDO => SDO,
          SCLK => SCLK,
          SPI_Fin => temp_spi_fin
        );
--instantiate Delay Block
   DELAY_COMP: Delay PORT MAP (
          CLK => CLK,
          RST => RST,
          DELAY_MS => temp_delay_ms,
          DELAY_EN => temp_delay_en,
          DELAY_Fin => temp_delay_fin
        );
--instantiate Memory Block
	encode : encoder
  PORT MAP (
    clka => CLK,
    y => SWITCH_B,
    addra => temp_addr,
    dOUTa => temp_dOUT
  );
	PROCESS (CLK)
	BEGIN
		IF(rISing_edge(CLK)) THEN
			case(current_state) IS
				--Idle until EN pulled high than intialize Page to 0 and go to state Alphabet afterwards
				WHEN Idle => 
					IF(EN = '1') THEN
						current_state <= ClearDC;
						after_page_state <= Alphabet;
						temp_page <= "00";
					END IF;
				--Set current_screen to CONSTANT alphabet_screen and update the screen.  Go to state Wait1 afterwards
				WHEN Alphabet => 
					current_screen <= alphabet_screen;
					current_state <= UpdateScreen;
					after_update_state <= Wait1;
				--Wait 4ms and go to ClearScreen
				WHEN Wait1 => 
					--temp_delay_ms <= "111110100000"; --4000
					temp_delay_ms <= "000000101000"; --40
					--after_state <= ClearScreen;
					after_state <= Alphabet;
					current_state <= Transition3; --Transition3 = The delay transition states
				--set current_screen to CONSTANT clear_screen and update the screen. Go to state Wait2 afterwards
				WHEN ClearScreen => 
					current_screen <= clear_screen;
					after_update_state <= Wait2;
					current_state <= UpdateScreen;
				--Wait 1ms and go to DigilentScreen
				WHEN Wait2 =>
					temp_delay_ms <= "001111101000"; --1000
					--after_state <= DigilentScreen;
					after_state <= Alphabet;
					current_state <= Transition3; --Transition3 = The delay transition states
				--Set currentScreen to CONSTANT digilent_screen and update the screen. Go to state Done afterwards
				WHEN DigilentScreen =>
					current_screen <= digilent_screen;
					after_update_state <= Done;
					current_state <= UpdateScreen;
				--Do nothing until EN is deassertted and THEN current_state is Idle
				WHEN Done			=>
					IF(EN = '0') THEN
						current_state <= Idle;
					END IF;
					
				--UpdateScreen State
				--1. Gets ASCII value from current_screen at the current page and the current spot of the page
				--2. IF on the last character of the page transition update the page number, IF on the last page(3)
				--			THEN the updateScreen go to "after_update_state" after 
				WHEN UpdateScreen =>
					temp_char <= current_screen(CONV_inTEGER(temp_page),temp_index);
					IF(temp_index = 15) THEN	
						temp_index <= 0;
						temp_page <= temp_page + 1;
						after_char_state <= ClearDC;
						IF(temp_page = "11") THEN
							after_page_state <= after_update_state;
						ELSE	
							after_page_state <= UpdateScreen;
						END IF;
					ELSE
						temp_index <= temp_index + 1;
						after_char_state <= UpdateScreen;
					END IF;
					current_state <= SENDChar1;
				
				--Update Page states
				--1. Sets DC to command mode
				--2. Souts the SetPage Command
				--3. Souts the Page to be set to
				--4. Sets the start pixel to the left column
				--5. Sets DC to data mode
				WHEN ClearDC =>
					temp_dc <= '0';
					current_state <= SetPage;
				WHEN SetPage =>
					temp_spi_data <= "00100010";
					after_state <= PageNum;
					current_state <= Transition1;
				WHEN PageNum =>
					temp_spi_data <= "000000" & temp_page;
					after_state <= LeftColumn1;
					current_state <= Transition1;
				WHEN LeftColumn1 =>
					temp_spi_data <= "00000000";
					after_state <= LeftColumn2;
					current_state <= Transition1;
				WHEN LeftColumn2 =>
					temp_spi_data <= "00010000";
					after_state <= SetDC;
					current_state <= Transition1;
				WHEN SetDC =>
					temp_dc <= '1';
					current_state <= after_page_state;
				--out Update Page States

				--Sout Character States
				--1. Sets the Address to ASCII value of char with the counter appouted to the out
				--2. Waits a clock for the data to get ready by going to ReadMem and ReadMem2 states
				--3. Sout the byte of data given by the block Ram
				--4. Repeat 7 more times for the rest of the character bytes
				WHEN SENDChar1 =>
					temp_addr <= temp_char & "000";
					after_state <= SENDChar2;
					current_state <= ReadMem;
				WHEN SENDChar2 =>
					temp_addr <= temp_char & "001";
					after_state <= SENDChar3;
					current_state <= ReadMem;
				WHEN SENDChar3 =>
					temp_addr <= temp_char & "010";
					after_state <= SENDChar4;
					current_state <= ReadMem;
				WHEN SENDChar4 =>
					temp_addr <= temp_char & "011";
					after_state <= SENDChar5;
					current_state <= ReadMem;
				WHEN SENDChar5 =>
					temp_addr <= temp_char & "100";
					after_state <= SENDChar6;
					current_state <= ReadMem;
				WHEN SENDChar6 =>
					temp_addr <= temp_char & "101";
					after_state <= SENDChar7;
					current_state <= ReadMem;
				WHEN SENDChar7 =>
					temp_addr <= temp_char & "110";
					after_state <= SENDChar8;
					current_state <= ReadMem;
				WHEN SENDChar8 =>
					temp_addr <= temp_char & "111";
					after_state <= after_char_state;
					current_state <= ReadMem;
				WHEN ReadMem =>
					current_state <= ReadMem2;
				WHEN ReadMem2 =>
					temp_spi_data <= temp_dOUT;
					current_state <= Transition1;
				--END SEND Character States
					
				--SPI transitions
				--1. Set SPI_EN to 1
				--2. Waits for SpiCtrl to finish
				--3. Goes to clear state (Transition5)
				WHEN Transition1 =>
					temp_spi_en <= '1';
					current_state <= Transition2;
				WHEN Transition2 =>
					IF(temp_spi_fin = '1') THEN
						current_state <= Transition5;
					END IF;
					
				--Delay Transitions
				--1. Set DELAY_EN to 1
				--2. Waits for Delay to finish
				--3. Goes to Clear state (Transition5)
				WHEN Transition3 =>
					temp_delay_en <= '1';
					current_state <= Transition4;
				WHEN Transition4 =>
					IF(temp_delay_fin = '1') THEN
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
			
				WHEN OTHERS 		=>
					current_state <= Idle;
			END case;
		END IF;
	END PROCESS;
	
END Behavioral;