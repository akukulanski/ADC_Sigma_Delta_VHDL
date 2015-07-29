----------------------------------------------------------------------------------
-- Company: DPLAB	
-- Engineer: Andres Demski	
-- 
-- Create Date:    17:05:10 08/24/2014 
-- Design Name: Contador
-- Module Name:    Counter - Behavioral 
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

entity Counter is
	generic (
				N : integer := 3
				);
	port (
			Finish : out std_logic;
			Enable : in std_logic;
			Rst : in std_logic;
			Cmp : in std_logic_vector (N-1 downto 0);
			Clk : in std_logic;
			CE : in std_logic
			);
end Counter;

architecture Behavioral of Counter is

component Sumador is
	generic (
					N: integer := 8 );
	port (
				ci : in std_logic;
				a : in std_logic_vector (N-1 downto 0);
				b : in std_logic_vector (N-1 downto 0) ;
				r : out std_logic_vector (N-1 downto 0);
				co: out std_logic );
end component;

signal count : std_logic_vector (N-1 downto 0):= (others=>'0');
signal tmp_count : std_logic_vector (N-1 downto 0) := (others=>'0');
signal compare : std_logic:='0';

begin

	process (Clk, Rst)
	begin
	if ( Rst = '1') then
			count <= (others=>'0');
			Finish <= '0';
	elsif (rising_edge(Clk)) then
		if (CE = '1') then
			if (Enable = '1') then
				if (count = Cmp) then
					count <= count;
					Finish <= '1';
				else
					count <= tmp_count;
					Finish <= '0';
				end if;
			end if;
		end if;
	end if;

	end process;
	

	add : Sumador generic map (N => N )
						port map(
									ci => '1',
									a => count,
									b => (others=>'0'),
									r => tmp_count,
									co => open 
									);



end Behavioral;

