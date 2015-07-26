library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_TB is
end entity fir_TB;

architecture RTL of fir_TB is
	constant N : integer := 17;
	constant M : integer := 48;
	constant TAPS : integer := 8;

	signal clk,rst,ce,we,oe: std_logic;
	signal data_in: std_logic_vector(N-1 downto 0);
	signal data_out: std_logic_vector(M-1 downto 0);
	
	constant init: std_logic_vector(N-2 downto 0) := (others => '0');
	signal cont: std_logic_vector(N-1 downto 0):= '1' & init;
	signal entrada_legible: std_logic_vector(N-1 downto 0);

begin
	tb : entity work.fir
		generic map(
			N => N,
			M => M,
			TAPS => TAPS
		)
		port map(
			data_in => data_in,
			data_out => data_out,
			we => we,
			oe => oe,
			ce     => ce,
			clk    => clk,
			rst    => rst
		);
	
	data_in <= cont;
	entrada_legible <= not(cont(N-1)) & cont(N-2 downto 0);
	
	CLOCK : process is
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		cont <= std_logic_vector(unsigned(cont) + to_unsigned(1, N));
		wait for 10 ns;
	end process;

	RST_EN : process is
		
	begin
		rst <= '1';
		ce <= '1';
		we <= '0';
		wait for 30 ns;
		rst <= '0';
		wait for 20 ns;
		we <= '1';
		for I in 0 to 30 loop
			wait for 20 ns;
			we <= '0';
			wait for 300 ns;		
			we <= '1';
		end loop;
		wait;
	end process;

end architecture RTL;
