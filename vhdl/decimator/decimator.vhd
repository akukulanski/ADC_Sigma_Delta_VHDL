library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

--- Nota: el ce_out retrasa un clock

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
	signal count    : unsigned(B - 1 downto 0) := (others=>'1'); --counter

begin

	




		
	ce_out <= ce_in when (count=to_unsigned(0,B) or B=0) else
			  '0';

	ce_decimate : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				count    <= (others => '1');
			else
				if ce_in = '1' then
					count <= count + to_unsigned(1, B);
				end if;
			end if;
		end if;
	end process ce_decimate;

end architecture RTL;

