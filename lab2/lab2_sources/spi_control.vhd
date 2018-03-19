-- This code was modifeid for TEMPO Summer School, July 17-21, 2017
-- Hardware Implementation of Embedded Optimisation 
----------------------------------------------------------------------------------
-- Company: Digilent inc.
-- Engineer: Ryan Kim
-- 
-- Create Date:    15:14:14 10/10/2011 
-- Module Name:    SpiCtrl - Behavioral 
-- Project Name:   PmodOled Demo
-- Tool versions:  ISE 13.2
-- Description:    Spi block that sENDs SPI data formatted SCLK active low with
--					SDO changing on the falling edge
--
-- RevISion: 1.0 - SPI completed
-- RevISion 0.01 - File Created 
--
----------------------------------------------------------------------------------
LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;

entity spi_ctrl IS
    Port ( CLK 		: IN  STD_LOGIC; --System CLK (100MHz)
		   RST 		: IN  STD_LOGIC; --Global RST (Synchronous)
		   SPI_EN 	: IN  STD_LOGIC; --SPI block enable pIN
		   SPI_DATA : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); --Byte to be sent
		   CS		: OUT STD_LOGIC; --Chip Select
           SDO 		: OUT STD_LOGIC; --SPI data OUT
           SCLK 	: OUT STD_LOGIC; --SPI clock
		   SPI_FIN	: OUT STD_LOGIC);--SPI finISh flag
END spi_ctrl;

architecture Behavioral OF spi_ctrl IS

type states IS (Idle,
				SEND,
				Hold1,
				Hold2,
				Hold3,
				Hold4,
				Done);
					
SIGNAL current_state : states := Idle; --SIGNAL for state machine

SIGNAL shIFt_regISter	: STD_LOGIC_VECTOR(7 DOWNTO 0); --ShIFt regISter to shIFt OUT SPI_DATA saved WHEN SPI_EN was set
SIGNAL shIFt_counter 	: STD_LOGIC_VECTOR(3 DOWNTO 0); --Keeps track how many bits were sent
SIGNAL clk_divided 		: STD_LOGIC := '1'; --Used as SCLK
SIGNAL counter 			: STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0'); --Count clocks to be used to divide CLK
SIGNAL temp_sdo			: STD_LOGIC := '1'; --Tied to SDO

SIGNAL falling : STD_LOGIC := '0'; --SIGNAL indicating that the clk has just fell
BEGIN
	clk_divided <= NOT counter(4); --SCLK = CLK / 32
	SCLK <= clk_divided;
	SDO <= temp_sdo;
	CS <= '1' WHEN (current_state = Idle and SPI_EN = '0') ELSE
		'0';
	SPI_FIN <= '1' WHEN (current_state = Done) ELSE
			'0';
	
	STATE_MACHINE : PROCESS (CLK)
	BEGIN
		IF(rising_edge(CLK)) THEN
			IF(RST = '1') THEN --Synchronous RST
				current_state <= Idle;
			ELSE
				CASE (current_state) IS
					WHEN Idle => --Wait for SPI_EN to go high
						IF(SPI_EN = '1') THEN
							current_state <= SEND;
						END IF;
					WHEN SEND => --Start sending bits, transition OUT WHEN all bits are sent and SCLK IS high
						IF(shIFt_counter = "1000" and falling = '0') THEN
							current_state <= Hold1;
						END IF;
					WHEN Hold1 => --Hold CS low for a bit
						current_state <= Hold2;
					WHEN Hold2 => --Hold CS low for a bit
						current_state <= Hold3;
					WHEN Hold3 => --Hold CS low for a bit
						current_state <= Hold4;
					WHEN Hold4 => --Hold CS low for a bit
						current_state <= Done;
					WHEN Done => --FinISh SPI transimISsion wait for SPI_EN to go low
						IF(SPI_EN = '0') THEN
							current_state <= Idle;
						END IF;
					WHEN OTHERS =>
						current_state <= Idle;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	CLK_DIV : PROCESS (CLK)
	BEGin
		IF(rISing_edge(CLK)) THEN
			IF (current_state = SEND) THEN --start clock counter WHEN in sout state
				counter <= counter + 1;
			ELSE --reset clock counter WHEN NOT in sout state
				counter <= (OTHERS => '0');
			END IF;
		END IF;
	END PROCESS;
	
	SPI_SEND_BYTE : PROCESS (CLK) --souts SPI data formatted SCLK active low with SDO changing on the falling edge
	BEGin
		IF(CLK'event and CLK = '1') THEN
			IF(current_state = Idle) THEN
				shIFt_counter <= (OTHERS => '0');
				shIFt_regISter <= SPI_DATA; --keeps placing SPI_DATA into shIFt_regISter so that WHEN state goes to sout it has the latest SPI_DATA
				temp_sdo <= '1';
			elsIF(current_state = SEND) THEN
				IF( clk_divided = '0' and falling = '0') THEN --IF on the falling edge OF Clk_divided
					falling <= '1'; --indicate that it IS passed the falling edge
					temp_sdo <= shIFt_regISter(7); --sout OUT the MSB
					shIFt_regISter <= shIFt_regISter(6 DOWNTO 0) & '0'; --ShIFt through SPI_DATA
					shIFt_counter <= shIFt_counter + 1; --Keep track OF what bit it IS on
				elsIF(clk_divided = '1') THEN --on SCLK high reset the falling flag
					falling <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
END Behavioral;

