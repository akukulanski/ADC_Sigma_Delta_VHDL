library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity integrator is
	generic(
		N : natural := 1;               -- N debe ser menor a M
		M : natural := 55
	);
	port(
		input  : in  std_logic_vector(N - 1 downto 0);
		output : out std_logic_vector(M - 1 downto 0);

		ce     : in  std_logic;
		clk    : in  std_logic;
		rst    : in  std_logic
	);
end entity;

architecture RTL of integrator is
	signal output_i  : std_logic_vector(M - 1 downto 0) := (others => '0');
	signal output_ii : std_logic_vector(M - 1 downto 0) := (others => '0');

begin
	output <= output_ii;

	process(clk) is
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				output_ii <= (others => '0');
			else
				if ce = '1' then
					output_ii <= output_i;
				end if;
			end if;
		end if;
	end process;

sum : output_i <= std_logic_vector(unsigned((M - 1 downto N => '0') & input) + unsigned(output_ii));

end architecture RTL;
