----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:26:55 09/19/2013 
-- Design Name: 
-- Module Name:    stopwatch - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stopwatch is
GENERIC (	clock_freq: INTEGER := 100000000 );

Port ( Led : out  STD_LOGIC_VECTOR (3 downto 0);
           sw : in  STD_LOGIC_VECTOR (7 downto 0);
                          an : out STD_LOGIC_VECTOR (3 downto 0) := "0000";
                          seg : out STD_LOGIC_VECTOR (7 downto 0);
                          btn : IN STD_LOGIC_VECTOR (3 downto 0);
                          clk : in STD_LOGIC);

end stopwatch;

ARCHITECTURE Behavioral OF stopwatch IS
-------------------------------GLOBAL SIGNALS------------------------------
SIGNAL millis : INTEGER := 0;
SIGNAL t_millis : INTEGER := 0;
SIGNAL h_millis : INTEGER := 0;
SIGNAL secs : INTEGER := 0;
SIGNAL t_secs : INTEGER := 0;
SIGNAL ssd_millis: STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111111";
SIGNAL ssd_t_millis: STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111111";
SIGNAL ssd_h_millis: STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111111";
SIGNAL ssd_secs: STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111111";
SIGNAL led_t_secs: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
SIGNAL m_clk: STD_LOGIC := '0';
SIGNAL millis_divisor : INTEGER := clock_freq/1000;
SIGNAL clk_counter :INTEGER := 0;
SIGNAL counter : INTEGER := 0;
SIGNAL en : STD_LOGIC := '1';
SIGNAL inc : STD_LOGIC := '0';
SIGNAL stop : STD_LOGIC := '0';
SIGNAL start : STD_LOGIC := '0';
SIGNAL rst : STD_LOGIC := '0';
SIGNAL incstate : INTEGER := 0;
---------------------------------------------------------------------------
BEGIN
--millis_divisor <= 1000;	-- Debug purposes
-------------------------------CLOCK DIVIDER-------------------------------
PROCESS (clk)
BEGIN
	IF (clk'EVENT and clk = '1') THEN
		IF (clk_counter = millis_divisor) THEN
			clk_counter <= 0;
			m_clk <= '1';
		ELSE
			clk_counter <= clk_counter + 1;
			m_clk <= '0';
		END IF;	
	END IF;
END PROCESS;
--------------------------------------------------------------------------	
-------------------------------COUNTERS-----------------------------------
PROCESS (m_clk, en, rst)
BEGIN
	IF (rst = '1') THEN
		millis <= 0;
		t_millis <= 0;
		h_millis <= 0;
		secs <= 0;
		t_secs <= 0;
	ELSIF(m_clk'EVENT and m_clk = '1') THEN
		IF (en = '1') THEN
			millis <= millis + 1;
			IF (millis = 9) THEN -- Why 9 and not 10? Ask someone about this.
				millis <= 0;
				t_millis <= t_millis + 1;
				IF (t_millis = 9) THEN
					t_millis <= 0;
					h_millis <= h_millis + 1;
					IF (h_millis = 9) THEN
						secs <= secs + 1;
						h_millis <= 0;
						IF (secs = 9) THEN
							t_secs <= t_secs + 1;
							secs <= 0;
							IF (t_secs = 15) THEN
								t_secs <= 0;	-- Max count reached, reset t_secs
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		ELSIF(inc = '1' AND (incstate = 0)) THEN	-- Messy bit of code for inc button
			incstate <= incstate + 1;
			millis <= millis + 1;
			IF (millis = 9) THEN -- Why 9 and not 10? Ask someone about this.
				millis <= 0;
				t_millis <= t_millis + 1;
				IF (t_millis = 9) THEN
					t_millis <= 0;
					h_millis <= h_millis + 1;
					IF (h_millis = 9) THEN
						secs <= secs + 1;
						h_millis <= 0;
						IF (secs = 9) THEN
							t_secs <= t_secs + 1;
							secs <= 0;
							IF (t_secs = 15) THEN
								t_secs <= 0;	-- Max count reached, reset t_secs
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
			ELSIF (inc = '1' AND (incstate > 0) AND (incstate < 30)) THEN
				incstate <= incstate + 1;
			ELSIF (inc = '0' AND (incstate > 0)) THEN
				incstate <= incstate - 1;
		END IF;
	END IF;
END PROCESS;
--------------------------------------------------------------------------	
------------------------------Decoders------------------------------------	
WITH millis SELECT
	ssd_millis <=
		"11000000" when 0,
		"11111001" when 1,
		"10100100" when 2,
		"10110000" when 3,
		"10011001" when 4,
		"10010010" when 5,
		"10000010" when 6,
		"11111000" when 7,
		"10000000" when 8,
		"10010000" when 9,
		"10000110" WHEN OTHERS;
WITH t_millis SELECT
	ssd_t_millis <=
		"11000000" when 0,
		"11111001" when 1,
		"10100100" when 2,
		"10110000" when 3,
		"10011001" when 4,
		"10010010" when 5,
		"10000010" when 6,
		"11111000" when 7,
		"10000000" when 8,
		"10010000" when 9,
		"10000110" WHEN OTHERS;
WITH h_millis SELECT
	ssd_h_millis <=
		"11000000" when 0,
		"11111001" when 1,
		"10100100" when 2,
		"10110000" when 3,
		"10011001" when 4,
		"10010010" when 5,
		"10000010" when 6,
		"11111000" when 7,
		"10000000" when 8,
		"10010000" when 9,
		"10000110" WHEN OTHERS;
WITH secs SELECT
	ssd_secs <=
		"11000000" when 0,
		"11111001" when 1,
		"10100100" when 2,
		"10110000" when 3,
		"10011001" when 4,
		"10010010" when 5,
		"10000010" when 6,
		"11111000" when 7,
		"10000000" when 8,
		"10010000" when 9,
		"10000110" WHEN OTHERS;
WITH t_secs SELECT
	led_t_secs <= 
		"0000" when 0,
		"0001" when 1,
		"0010" when 2,
		"0011" when 3,
		"0100" when 4,
		"0101" when 5,
		"0110" when 6,
		"0111" when 7,
		"1000" when 8,
		"1001" when 9,
		"1010" when 10,
		"1011" when 11,
		"1100" when 12,
		"1101" when 13,
		"1110" when 14,
		"1111" when 15,
		"1111" WHEN OTHERS;
--------------------------------------------------------------------------	
------------------------------7SEG DRIVER---------------------------------
-- Start messy code from previous project --
PROCESS(clk)
BEGIN
	an <= "1111";
        IF (clk'EVENT AND clk='1') THEN
        counter <= counter + 1;

        IF(counter > 150 and counter < 200) THEN
        -- Display first digit
        seg <= ssd_secs AND "01111111";
        an <= "0111";

        ELSIF (counter > 250 and counter < 300) THEN
        -- Display second digit
        seg <= ssd_h_millis;
        an <= "1011";

        ELSIF (counter > 350 and counter < 400) THEN
        -- Display third digit
        seg <= ssd_t_millis;
        an <= "1101";

        ELSIF (counter > 450 and counter < 500) THEN
        -- Display fourth digit
        seg <= ssd_millis;
        an <= "1110";

        ELSIF (counter >499) THEN
        counter <= 1;

        ELSE
        an <= "1111";
        seg <= "11111111";
        END IF;
        END IF;
END PROCESS;
--------------------------------------------------------------------------
-------------------------------INPUT LOGIC--------------------------------
PROCESS (clk)
BEGIN
	IF (clk'EVENT and clk = '1') THEN
		IF (start = '1' AND stop = '0') THEN
			en <= '1';
		ELSIF (stop = '1' AND start = '0') THEN
			en <= '0';
		ELSE
			en <= en;
		END IF;
	END IF;
END PROCESS;

--------------------------------------------------------------------------
---------------------------COMBINATIONAL LOGIC----------------------------
Led <= led_t_secs;
start <= btn(0);
stop <= btn(1);
inc <= btn(2);
rst <= btn(3);
--------------------------------------------------------------------------
END Behavioral;

