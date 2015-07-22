library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comb_TB is
end entity comb_TB;

architecture RTL of comb_TB is
	constant N : integer := 10;

	signal input : std_logic_vector(N - 1 downto 0) := std_logic_vector(to_unsigned(0, N));
	signal res   : std_logic_vector(N - 1 downto 0) := (others => '0');
	signal ce    : std_logic                        := '0';
	signal clk   : std_logic                        := '0';
	signal rst   : std_logic                        := '0';

begin
	tb : entity work.comb
		generic map(
			N     => N,
			DELAY => 2
		)
		port map(
			input  => input,
			output => res,
			ce     => ce,
			clk    => clk,
			rst    => rst
		);

	CLOCK : process is
	begin
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
	end process;

	RST_EN : process is
		variable i : integer := 0;
	begin
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		wait for 10 ns;
		ce <= '1';

		loop
			input <= std_logic_vector(to_unsigned(2 ** i, N));

			i := i + 1;
			wait for 20 ns;

		end loop;
		wait;
	end process;

end architecture RTL;
