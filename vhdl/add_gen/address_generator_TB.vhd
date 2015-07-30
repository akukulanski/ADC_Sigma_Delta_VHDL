library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity address_generator_TB is
end entity address_generator_TB;

architecture RTL of address_generator_TB is
	constant TAPS                       : natural                                   := 8;
	signal write_address, read_address1, read_address2 : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal coef_address : std_logic_vector(log2(TAPS/2) - 1 downto 0) := (others => '0');
	signal we, clk, ce, rst, o_we, enable_mac_new_input: std_logic      := '0';
begin
	tb : entity work.address_generator
		generic map(
			TAPS => TAPS
		)
		port map(
			write_address  => write_address,
			read_address1 => read_address1,
			read_address2 => read_address2,
			coef_address  => coef_address,
			enable_mac_new_input=> enable_mac_new_input,
			we     => we,
			o_we   => o_we,
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
		we <= '1';
		wait for 20 ns;
		we <= '0';
		ce <= '1';
		loop
			wait for 200 ns;
			we <= '1';
			wait for 20 ns;
			we <= '0';
		end loop;
		
		wait;
	end process;

end architecture RTL;
