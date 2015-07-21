library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decimator_TB is
end entity decimator_TB;

architecture RTL of decimator_TB is
	constant R : integer := 2;

	signal ce_in : std_logic := '0';
	signal ce_out : std_logic := '0';
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';


begin

	tb: entity work.decimator
		generic map(
			R => R
		)
		port map(
			ce_in  => ce_in,
			ce_out => ce_out,
			clk    => clk,
			rst    => rst
		);

	CLOCK: process is
	begin
		wait for 10 ns;
		clk <= '1';		
		wait for 10 ns;
		clk <= '0';	
	end process;


	RST_EN: process is
		
	begin
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		wait for 10 ns;
		ce_in <= '1';		
		wait;	
	end process;

end architecture RTL;