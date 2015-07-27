library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity decimator is
	generic(
		R : natural := 512
	);
	port(
		ce_in  : in  std_logic;
		ce_out : out std_logic;
		clk    : in  std_logic;
		rst    : in  std_logic
	);
end entity decimator;

architecture RTL of decimator is
	constant B      : natural := log2(R); -- se redondea log2(R) para arriba
	signal count    : unsigned(B - 1 downto 0); --counter
	signal ce_out_i : std_logic;
begin
	ce_out <= ce_out_i;
	ce_decimate : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				count    <= (others => '0');
				ce_out_i <= '0';
			else
				if ce_in = '1' then
					count <= count + to_unsigned(1, B);
					if count = (to_unsigned(R - 1, B)) then
						ce_out_i <= '1';
					else
						ce_out_i <= '0';
					end if;
				end if;
			end if;
		end if;
	end process ce_decimate;

end architecture RTL;

