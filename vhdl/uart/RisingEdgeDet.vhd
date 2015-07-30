----------------------------------------------------------------------------------
-- Company: DPLAB
-- Engineer: Andres Demski
-- 
-- Create Date:    14:25:07 08/29/2014 
-- Design Name: Detector de Flanco
-- Module Name:    RisingEdgeDet - Behavioral 
-- Project Name: UART
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

entity RisingEdgeDet is
	port (
				i : in std_logic;
				q : out std_logic;
				rst : in std_logic;
				clk : in std_logic;
				CE : in std_logic
			);
end RisingEdgeDet;

architecture Behavioral of RisingEdgeDet is
	signal ii :std_logic :='0';
begin
	process (clk)
	begin
		if (rising_edge (clk)) then
			if (rst='1') then
				ii <='0';
			elsif (CE = '1') then
				ii <= i;
			end if;
		end if;	
	end process;
	q <= (not ii) and i;
end Behavioral;
