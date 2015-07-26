library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity addr_gen_TB is
end entity addr_gen_TB;

architecture RTL of addr_gen_TB is
	constant TAPS                       : natural                                   := 128;
	signal i_addr, o_addr1, o_addr2 : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal c_addr : std_logic_vector(log2(TAPS/2) - 1 downto 0) := (others => '0');
	signal we, clk, ce, rst, o_we       : std_logic                                 := '0';
begin
	tb : entity work.addr_gen
		generic map(
			TAPS => TAPS
		)
		port map(
			i_addr  => i_addr,
			o_addr1 => o_addr1,
			o_addr2 => o_addr2,
			c_addr  => c_addr,
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
			wait for 1400 ns;
			we <= '1';
			wait for 20 ns;
			we <= '0';
		end loop;
		
		wait;
	end process;

end architecture RTL;
