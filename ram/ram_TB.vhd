library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity ram_TB is
end entity ram_TB;

architecture RTL of ram_TB is
	constant N: natural:=16;
	constant TAPS: natural:=100;
	signal input,output1,output2: std_logic_vector(N-1 downto 0):= (others =>'0');
	signal i_add,o_add1,o_add2: std_logic_vector (log2(TAPS)-1 downto 0):= (others =>'0');
	signal we,clk,ce,rst: std_logic :='0';
begin
	
	tb : entity work.RAM
		generic map(
			N    => N,
			TAPS => TAPS
		)
		port map(
			input   => input,
			i_add   => i_add,
			output1 => output1,
			output2 => output2,
			o_add1  => o_add1,
			o_add2  => o_add2,
			we      => we,
			ce      => ce,
			clk     => clk,
			rst		=> rst
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
		ce <= '1';
		wait for 10 ns;
		we <= '1';
		i_add<="0000000";
		input<="0011110011110011";
		wait for 20 ns;
		i_add<="0000001";
		input<="0011110011110010";
		wait for 20 ns;
		we<='0';
		o_add1<="0000000";
		o_add2<="0000001";
		wait;
	end process;

end architecture RTL;
