library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity ram_TB is
end entity ram_TB;

architecture RTL of ram_TB is
	constant N                                         : natural                                   := 16;
	constant TAPS                                      : natural                                   := 4;
	signal input, output1, output2                     : std_logic_vector(N - 1 downto 0)          := (others => '0');
	signal write_address, read_address1, read_address2 : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal we, clk, ce, rst                            : std_logic                                 := '0';

begin
	tb : entity work.ram
		generic map(
			N    => N,
			TAPS => TAPS
		)
		port map(
			input         => input,
			write_address => write_address,
			output1       => output1,
			output2       => output2,
			read_address1 => read_address1,
			read_address2 => read_address2,
			we            => we,
			ce            => ce,
			clk           => clk,
			rst           => rst

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
		we  <= '0';
		rst <= '1';
		ce  <= '1';
		wait for 20 ns;
		rst <= '0';

		wait for 11 ns;
		we            <= '1';
		input         <= std_logic_vector(to_unsigned(1, 16));
		write_address <= "00";
		wait for 20 ns;
		we            <= '0';
		read_address1 <= "00";
		read_address2 <= "01";
		wait for 20 ns;
		read_address1 <= "11";
		read_address2 <= "10";
		wait for 20 ns;
		we            <= '1';
		input         <= std_logic_vector(to_unsigned(2, 16));
		write_address <= "01";
		wait for 20 ns;
		we            <= '0';
		read_address1 <= "01";
		read_address2 <= "10";
		wait for 20 ns;
		read_address1 <= "00";
		read_address2 <= "11";

-- 		wait for 10 ns;
-- 		ce <= '1';
-- 		wait for 10 ns;
-- 		we     <= '1';
-- 		i_addr <= "0000000";
-- 		input  <= "0011110011110011";
-- 		wait for 20 ns;
-- 		i_addr <= "0000001";
-- 		input  <= "0011110011110010";
-- 		wait for 20 ns;
-- 		we      <= '0';
-- 		o_addr1 <= "0000000";
-- 		o_addr2 <= "0000001";
		wait;

	end process;

end architecture RTL;
