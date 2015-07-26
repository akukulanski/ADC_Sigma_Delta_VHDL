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
		input         : in  std_logic_vector(N - 1 downto 0);
		write_address : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		output1       : out std_logic_vector(N - 1 downto 0)  := (others => '0');
		output2       : out std_logic_vector(N - 1 downto 0)  := (others => '0');

		read_address1 : in  std_logic_vector(log2(TAPS) - 1 downto 0);
		read_address2 : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		we            : in  std_logic;  -- write enable
		ce            : in  std_logic;
		clk           : in  std_logic;
		rst           : in  std_logic
	);

end ram;

architecture RTL of ram is
	type ram_type is array (TAPS-1 downto 0) of std_logic_vector(N - 1 downto 0);--cambiado, estaba (TAPS downto 0)
	signal RAM               : ram_type := (others => (others => '0'));
	signal ram_read_address1 : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal ram_read_address2 : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal ram_write_address : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');

begin

	-- por qué el condicional?
	--ram_write_address <= write_address when we='1' else ram_read_address1;
	ram_write_address <= write_address;

	--output1 <= RAM(to_integer(unsigned(ram_write_address)));
	output1 <= RAM(to_integer(unsigned(ram_read_address1)));
	output2 <= RAM(to_integer(unsigned(ram_read_address2)));

	WRITE_PROCESS : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				RAM <= (others => (others => '0'));
			else
				if (ce = '1') and (we = '1') then
						RAM(to_integer(unsigned(ram_write_address))) <= input;
						--RAM(to_integer(unsigned(ram_addr1_i))) <= input;
				end if;
			end if;
		end if;
	end process;

	READ_PROCESS : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				ram_read_address1 <= (others => '0');
				ram_read_address2 <= (others => '0');
			else
				if (ce = '1') then
					ram_read_address1 <= read_address1;
					ram_read_address2 <= read_address2;
				end if;
			end if;
		end if;
	end process;

end architecture;