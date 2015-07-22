library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mytypes_pkg.all;

entity cic_TB is
end entity cic_TB;

architecture RTL of cic_TB is
	signal input  : std_logic                         := '0';
	signal output : std_logic_vector(17 - 1 downto 0) := (others => '0');
	signal ce_in  : std_logic                         := '0';
	signal ce_out : std_logic                         := '0';
	signal clk    : std_logic                         := '0';
	signal rst    : std_logic                         := '0';

begin
	tb : entity work.cic
		port map(
			input  => input,
			output => output,
			clk    => clk,
			rst    => rst,
			ce_in  => ce_in,
			ce_out => ce_out
		);

	CLOCK : process is
	begin
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
	end process;

	RST_EN : process is
	begin
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		wait for 10 ns;
		ce_in <= '1';
		
		loop
			wait for 10000 us;
			input <= '1';
			wait for 10000 us;
			input<= '0';
		end loop;
	
		wait;
	end process;
end architecture RTL;
