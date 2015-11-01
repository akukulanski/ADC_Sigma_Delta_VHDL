library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

-- Nota: POTENCIAS DE DOS!!!!!

entity new_decimator is
	generic(
		R : natural := 512;
		BITS: natural := 16
	);
	port(
		ce_in  : in  std_logic;
		input  : in std_logic_vector(BITS-1 downto 0);
		ce_out : out std_logic:='0';
		output : out std_logic_vector(BITS-1 downto 0);
		clk    : in  std_logic;
		rst    : in  std_logic
	);
end entity new_decimator;

architecture RTL of new_decimator is
	constant B      : natural := log2(R); -- se redondea log2(R) para arriba
	signal count,count_i   : unsigned(B - 1 downto 0) := (others=>'0'); --counter
	signal input_i : std_logic_vector(BITS-1 downto 0):=(others=>'0');

begin

	sec_proc : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				count <= (others => '0');
				output <= (others => '0');
				ce_out <= '0';
			else
				output <= (others => '0');
				ce_out <= '0';
				if ce_in = '1' then
					if (count=0) then
						output <= input_i;
						ce_out <= '1';
					end if;
					count <= count_i;
				end if;
			end if;
		end if;
	end process sec_proc;
	
	next_state: process(count, count_i, input, ce_in)
	begin
		count_i <= count;
		input_i <= (others => '0');
		if ce_in = '1' then
			input_i <= input;
			count_i <= count_i + to_unsigned(1, B);
		end if;
	end process next_state;

end architecture RTL;

