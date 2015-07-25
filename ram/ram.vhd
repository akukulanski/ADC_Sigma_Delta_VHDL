library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity ram is
	generic(
		N    : natural := 6;            --ancho de palabra
		TAPS : natural := 128           --cantidad de palabras
	);
	port(
		input   : in  std_logic_vector(N - 1 downto 0);
		i_addr  : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		output1 : out std_logic_vector(N - 1 downto 0);
		output2 : out std_logic_vector(N - 1 downto 0);

		o_addr1 : in  std_logic_vector(log2(TAPS) - 1 downto 0);
		o_addr2 : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		we      : in  std_logic;        -- write enable

		ce      : in  std_logic;
		clk     : in  std_logic;
		rst     : in  std_logic
	);

end ram;

architecture RTL of ram is
	type ram_type is array (TAPS downto 0) of std_logic_vector(N - 1 downto 0);
	signal RAM         : ram_type := (others => (others => '0'));
	signal ram_addr1   : std_logic_vector(log2(TAPS) - 1 downto 0);
	signal ram_addr2   : std_logic_vector(log2(TAPS) - 1 downto 0);
	signal ram_addr1_i : std_logic_vector(log2(TAPS) - 1 downto 0);

begin
	process(clk)
	begin
		if rising_edge(clk) then
			if (we = '1') then
				RAM(to_integer(unsigned(ram_addr1_i))) <= input;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				ram_addr1 <= (others => '0');
				ram_addr2 <= (others => '0');
			else
				if (ce = '1') then
					ram_addr1 <= o_addr1;
					ram_addr2 <= o_addr2;
				end if;
			end if;

		end if;
	end process;

	ram_addr1_i <= i_addr when we = '1' else ram_addr1;

	output1 <= RAM(to_integer(unsigned(ram_addr1_i)));
	output2 <= RAM(to_integer(unsigned(ram_addr2)));

end architecture;