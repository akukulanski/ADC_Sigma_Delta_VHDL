library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity delayline is
	generic(
		N    : natural := 6;            --ancho de palabra
		TAPS : natural := 200           --cantidad de palabras
	);
	port(
		input   : in  std_logic_vector(N - 1 downto 0);
		i_add   : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		output1 : out std_logic_vector(N - 1 downto 0);
		output2 : out std_logic_vector(N - 1 downto 0);

		o_add1  : in  std_logic_vector(log2(TAPS) - 1 downto 0);
		o_add2  : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		we      : in  std_logic;        -- write enable

		ce      : in  std_logic;
		clk     : in  std_logic;
		rst     : in  std_logic
	);

end delayline;

architecture RTL of delayline is
	type ram_type is array (TAPS downto 0) of std_logic_vector(N - 1 downto 0);
	signal RAM      : ram_type := (others => (others => '0'));
	signal ram_add1 : std_logic_vector(log2(TAPS) - 1 downto 0);
	signal ram_add2 : std_logic_vector(log2(TAPS) - 1 downto 0);

begin
	process(clk)
	begin
		if rising_edge(clk) then
			if (we = '1') then
				RAM(to_integer(unsigned(ram_add1))) <= input;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				ram_add1 <= (others => '0');
				ram_add2 <= (others => '0');
			else
				if (ce = '1') then
					if (we = '0') then
						ram_add1 <= i_add;
					else
						ram_add1 <= o_add1;
						ram_add2 <= o_add2;
					end if;
				end if;
			end if;

		end if;
	end process;

	output1 <= RAM(to_integer(unsigned(ram_add1)));
	output2 <= RAM(to_integer(unsigned(ram_add2)));

end architecture;