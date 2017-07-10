-- 2017 Universidade Federal de Minas Gerais
--
-- Developed by:
-- 	Italo Lelis de Carvalho
-- 	Thiago Rinco da Silveira
--
-- Instructor: Luciano Cunha de Araujo Pimenta
--
-- Development Kit: Altera DE2 (EP2C35F672C6)
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity cassino is
	generic(
		-- Set the minimal and maximum numbers to be picked
		--- Must be within 0 and 9
		constant min : integer := 0;
		constant max : integer := 9
	);
	port(
		clk		: in	std_logic; -- Clock
		input		: in	std_logic; -- Select button
		start		: in	std_logic; -- Start button
		reset		: in	std_logic; -- Reset button
		output	: out	std_logic_vector(1 downto 0); -- LED indicator
		
		-- 7 segments display
		A: out std_logic_vector(6 downto 0); -- 4th 7 segment display
		B: out std_logic_vector(6 downto 0); -- 3rd 7 segment display
		C: out std_logic_vector(6 downto 0); -- 2nd 7 segment display
		D: out std_logic_vector(6 downto 0)  -- 1st 7 segment display (turn off)
	);

end entity;

architecture rtl of cassino is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3, compare, win, lose, s1p, s2p, s3p, clear);
	-- s0: Initial State, clear and setup values
	-- s1: Sum value #1
	-- s1p: Pick and print value #1
	-- s2: Sum value #2
	-- s2p: Pick and print value #2
	-- s3: Sum value #3
	-- s3p: Pick and print value #2
	-- compare: Compare if #1=#2=#3
	-- win: Turn LED on to indicate they are equal
	-- lose: Turn LED off to indicate they are not equal
	-- clear: Clear and setup values

	-- Register to hold the current state
	signal state   : state_type;
	
	-- Create variables to store random numbers
	shared variable i1 : integer range 0 to max; -- Value #1
	shared variable i2 : integer range 0 to max; -- Value #2
	shared variable i3 : integer range 0 to max; -- Value #3

begin

	-- State Machine
	process (input, clk, start, reset)
	begin
		-- Reset State Machine
		if reset = '0' then
			state <= s0;
		-- Run State Machine operations on the rising edge of clock
		elsif (rising_edge(clk)) then
			case state is
				
			---s0---
				when s0=>
					-- Clear values
					i1 := min;
					i2 := min;
					i3 := min;
					output <= "00";
					-- Print dash
					A <= "0111111";
					B <= "0111111";
					C <= "0111111";
					-- Turn off 4th display
					D <= "1111111";
					--change state
					if start = '0' then
						state <= s1;
					else
						state <= s0;
					end if;
			---s1---
				when s1=>
					-- Create an effect of PWM in the display
					if	(i1 = 0) then C <= "0111111";
					elsif	(i1 = 1) then C <= "0011111";
					elsif	(i1 = 2) then C <= "0101111";
					elsif	(i1 = 3) then C <= "0110111";
					elsif	(i1 = 4) then C <= "0111011";
					elsif	(i1 = 5) then C <= "0111101";
					elsif	(i1 = 6) then C <= "0111110";
					elsif	(i1 = 7) then C <= "0111111";
					elsif	(i1 = 8) then C <= "0101111";
					elsif	(i1 = 9) then C <= "0110111";
					-- Show three dashses to indicate out of boundary
					else C <= "0110110";
					end if;
					-- Simulate a random equation
					--- x=x+1, x>max := x=min
					if i1 = max then
						i1 := min;
					else
						i1 := i1 + 1;
					end if;
					--change state
					if input = '0' then
						state <= s1p;
					else
						state <= s1;
					end if;
			---s2---
				when s2=>
					-- Create an effect of PWM in the display
					if	(i2 = 0) then B <= "0111111";
					elsif	(i2 = 1) then B <= "0011111";
					elsif	(i2 = 2) then B <= "0101111";
					elsif	(i2 = 3) then B <= "0110111";
					elsif	(i2 = 4) then B <= "0111011";
					elsif	(i2 = 5) then B <= "0111101";
					elsif	(i2 = 6) then B <= "0111110";
					elsif	(i2 = 7) then B <= "0111111";
					elsif	(i2 = 8) then B <= "0101111";
					elsif	(i2 = 9) then B <= "0110111";
					-- Show three dashses to indicate out of boundary
					else B <= "0110110";
					end if;
					-- Simulate a random equation
					--- x=x+1, x>max := x=min
					if i2 = max then
						i2 := min;
					else
						i2 := i2 + 1;
					end if;
					--change state
					if input = '0' then
						state <= s2p;
					else
						state <= s2;
					end if;
			---s3---
				when s3 =>
					-- Create an effect of PWM in the display
					if	(i3 = 0) then A <= "0111111";
					elsif	(i3 = 1) then A <= "0011111";
					elsif	(i3 = 2) then A <= "0101111";
					elsif	(i3 = 3) then A <= "0110111";
					elsif	(i3 = 4) then A <= "0111011";
					elsif	(i3 = 5) then A <= "0111101";
					elsif	(i3 = 6) then A <= "0111110";
					elsif	(i3 = 7) then A <= "0111111";
					elsif	(i3 = 8) then A <= "0101111";
					elsif	(i3 = 9) then A <= "0110111";
					-- Show three dashses to indicate out of boundary
					else A <= "0110110";
					end if;
					-- Simulate a random equation
					--- x=x+1, x>max := x=min
					if i3 = max then
						i3 := min;
					else
						i3 := i3 + 1;
					end if;
					--change state
					if input = '0' then
						state <= s3p;
					else
						state <= s3;
					end if;
					
					
			---compare---
				when compare =>
					-- Compare if the picked values are equal
					--change state
					if ((i1 = i2) and (i2 = i3)) then
						state <= win;
					else
						state <= lose;
					end if;
			---win---
				when win =>
					-- Turn LED on (indicating they are equal)
					output <= "11";
					--change state
					if start = '0' then
						state <= clear;
					else
						state <= win;
					end if;
			---lose---
				when lose =>
					-- Turn LED off (indicating they are not equal)
					output <= "00";
					--change state
					if start = '0' then
						state <= clear;
					else
						state <= lose;
					end if;
			---clear---
				when clear=>
					-- Clear values
					i1 := min;
					i2 := min;
					i3 := min;
					-- Print dash
					output <= "00";
					A <= "0111111";
					B <= "0111111";
					C <= "0111111";
					-- Turn off 4th display
					D <= "1111111";
					--change state
					state <= s1;
			
			
			---s1p---print(s1)---
				when s1p =>
					-- Print picked number (0 to 9)
					if	(i1 = 0) then C <= "1000000";
					elsif	(i1 = 1) then C <= "1111001";
					elsif	(i1 = 2) then C <= "0100100";
					elsif	(i1 = 3) then C <= "0110000";
					elsif	(i1 = 4) then C <= "0011001";
					elsif	(i1 = 5) then C <= "0010010";
					elsif	(i1 = 6) then C <= "0000010";
					elsif	(i1 = 7) then C <= "1111000";
					elsif	(i1 = 8) then C <= "0000000";
					elsif	(i1 = 9) then C <= "0010000";
					-- Show 'E' to indicate out of boundary
					else C <= "0000110";
					end if;
					--change state
					if input = '1' then
						state <= s2;
					else
						state <= s1p;
					end if;
			---s2p---print(s2)---
				when s2p =>
					-- Print picked number (0 to 9)
					if	(i2 = 0) then B <= "1000000";
					elsif	(i2 = 1) then B <= "1111001";
					elsif	(i2 = 2) then B <= "0100100";
					elsif	(i2 = 3) then B <= "0110000";
					elsif	(i2 = 4) then B <= "0011001";
					elsif	(i2 = 5) then B <= "0010010";
					elsif	(i2 = 6) then B <= "0000010";
					elsif	(i2 = 7) then B <= "1111000";
					elsif	(i2 = 8) then B <= "0000000";
					elsif	(i2 = 9) then B <= "0010000";
					-- Show 'E' to indicate out of boundary
					else B <= "0000110";
					end if;
					--change state
					if input = '1' then
						state <= s3;
					else
						state <= s2p;
					end if;
			---s3p---print(s3)---
				when s3p =>
					-- Print picked number (0 to 9)
					if	(i3 = 0) then A <= "1000000";
					elsif	(i3 = 1) then A <= "1111001";
					elsif	(i3 = 2) then A <= "0100100";
					elsif	(i3 = 3) then A <= "0110000";
					elsif	(i3 = 4) then A <= "0011001";
					elsif	(i3 = 5) then A <= "0010010";
					elsif	(i3 = 6) then A <= "0000010";
					elsif	(i3 = 7) then A <= "1111000";
					elsif	(i3 = 8) then A <= "0000000";
					elsif	(i3 = 9) then A <= "0010000";
					-- Show 'E' to indicate out of boundary
					else A <= "0000110";
					end if;
					--change state
					if input = '1' then
						state <= compare;
					else
						state <= s3p;
					end if;
			end case;
		end if;
	end process;
end rtl;
