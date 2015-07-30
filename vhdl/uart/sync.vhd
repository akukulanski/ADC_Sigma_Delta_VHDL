----------------------------------------------------------------------------------
-- Company: DPLAB
-- Engineer: Andres Demski
-- 
-- Create Date:    15:42:56 06/24/2014 
-- Design Name: Sincronismo
-- Module Name:    sync - Behavioral 
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

entity sync is
	port (
			meta_data : in std_logic;  -- IN
			sync_data : out std_logic;  -- SYNC OUT
			clk : in std_logic;  -- CLK
			rst: in std_logic  -- Rst
			);
end sync;

architecture Behavioral of sync is
	signal aux : std_logic;
begin
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst='1') then
				sync_data <= '1';
			else 
				aux <= meta_data;
				sync_data <= aux;
			end if;
			
		end if;
	end process;

end Behavioral;

