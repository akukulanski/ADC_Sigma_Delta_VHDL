library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity integrator_TB is
end entity integrator_TB;

architecture RTL of integrator_TB is
	constant N : natural := 2;
	constant M : natural := 20;

	signal input : std_logic_vector(N - 1 downto 0) := std_logic_vector(to_unsigned(0, N));
	signal res   : std_logic_vector(M - 1 downto 0) := (others => '0');
	signal ce    : std_logic                        := '0';
	signal clk   : std_logic                        := '0';
	signal rst   : std_logic                        := '0';

begin
	tb : entity work.integrator
		generic map(
			N => N,
			M => M
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
	begin
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		wait for 10 ns;
		ce <= '1';

		loop
			input <= std_logic_vector(to_unsigned(1, N));

			wait for 200 ns;

			input <= std_logic_vector(to_unsigned(0, N));

			wait for 200 ns;
		end loop;
		wait;
	end process;

end architecture RTL;
