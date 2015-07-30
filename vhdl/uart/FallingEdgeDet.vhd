----------------------------------------------------------------------------------
-- Company: DPLAB
-- Engineer: Andres Demski	
-- 
-- Create Date:    12:06:00 08/24/2014 
-- Design Name: Detector de Flanco
-- Module Name:    EdgeDetector - Behavioral 
-- Project Name: UART
-- Target Devices: MOJOv3
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

entity EdgeDetector is
	port (
				i : in std_logic;
				q : out std_logic;
				rst : in std_logic;
				clk : in std_logic;
				CE : in std_logic
			);
end EdgeDetector;

architecture Behavioral of EdgeDetector is
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
	q <= ii and (not i);
end Behavioral;

