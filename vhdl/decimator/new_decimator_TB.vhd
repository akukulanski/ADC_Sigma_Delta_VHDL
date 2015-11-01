library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity new_decimator_TB is
end entity new_decimator_TB;

architecture RTL of new_decimator_TB is
	constant R : natural := 4;
	constant BITS : natural := 16;

	signal ce_in  : std_logic := '0';
	signal ce_out : std_logic := '0';
	signal clk    : std_logic := '0';
	signal rst    : std_logic := '0';
	signal input  : std_logic_vector(BITS-1 downto 0);
	signal output : std_logic_vector(BITS-1 downto 0);

begin
	tb : entity work.new_decimator
		generic map(
			R => R,
			BITS => BITS
		)
		port map(
			ce_in  => ce_in,
			ce_out => ce_out,
			clk    => clk,
			rst    => rst,
			input  => input,
			output => output
		);

	CLOCK : process is
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;

	RST_EN : process is
	begin
		rst <= '1';
		wait for 30 ns;
		rst <= '0';
		wait for 20 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 100 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 100 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 100 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 100 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 100 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 100 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 100 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 20 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 20 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 20 ns;
		ce_in <= '1';
		wait for 20 ns;
		ce_in <= '0';
		wait for 20 ns;
		ce_in <= '1';
		wait for 20 ns;
		wait;
	end process;

end architecture RTL;